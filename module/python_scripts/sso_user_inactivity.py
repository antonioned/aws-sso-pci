## This Lambda function fetched the list of active SSO users from a DynamoDB table and then checks if those users have
## logged in to SSO in the last 86 days. When a user logs on to SSO, they trigger an Authenticate event in Cloudtrail.
## The lambda function then compares the DynamoDB and Cloudtrail lists and outputs the user(s) with no such event.

import boto3
import os
import json
from datetime import datetime, timedelta

# Variables
alert_days = 86
current_date = datetime.now()
check_date = current_date - timedelta(days=alert_days)
dyndb_table_name = os.getenv('DYNAMODB_TABLE')
logging_sqs_queue_url = os.getenv('LOGGING_ACCOUNT_SQS_QUEUE_URL')
sso_usernames_list = []
authenticated_usernames_list = []
unauthenticated_usernames_list = []

## Boto3
cloudtrail = boto3.client('cloudtrail')
dynamodb = boto3.client('dynamodb')
sqs = boto3.client('sqs')
ct_paginator = cloudtrail.get_paginator('lookup_events')
dyndb_paginator = dynamodb.get_paginator('scan')

StartingToken = None

# Get SSO usernames list from the DynamoDB table
def get_sso_usernames_list(StartingToken):
    
    dyndb_items_page_iterator = dyndb_paginator.paginate(
        TableName=dyndb_table_name,
        PaginationConfig={'PageSize':10, 'StartingToken':StartingToken },
    )
    
    for page in dyndb_items_page_iterator:
        for u in page['Items']:
            try: 
                username = u['Username']['S']
                sso_usernames_list.append(username)
                StartingToken = page["NextToken"]
            except:
                username=None
        
    return sso_usernames_list

# Get SSO usernames that have authenticated to SSO portal in the last 85 days.
def get_active_usernames_list(StartingToken):

    auth_page_iterator = ct_paginator.paginate(
        LookupAttributes=[{'AttributeKey':'EventName','AttributeValue': 'Authenticate'}],
        PaginationConfig={'PageSize':10, 'StartingToken':StartingToken },
        StartTime=check_date,
        EndTime= current_date)

    for page in auth_page_iterator:
        for event in page['Events']:
            try:
                    json_object = json.loads(event['CloudTrailEvent'])
                    authenticated_user = json_object['userIdentity']['userName']
                    authenticated_usernames_list.append(authenticated_user)
                    StartingToken = page["NextToken"]              
            except:
                    authenticated_user=None
    
    return authenticated_usernames_list


def lambda_handler(event, context):
            
    sso_usernames_list = get_sso_usernames_list(StartingToken)
    authenticated_usernames_list = get_active_usernames_list(StartingToken)
    authenticated_usernames_list = list(dict.fromkeys(authenticated_usernames_list))
    unauthenticated_usernames = [username for username in sso_usernames_list if username not in authenticated_usernames_list]
    unauthenticated_usernames = list(dict.fromkeys(unauthenticated_usernames))
    
    json_report = """
    {
        "Records":
            [
                {
                    "eventName" : "InactiveUsers",
                    "userList": """ + '"' + str(unauthenticated_usernames) + '"' + """
                }
            ]
    }
    """

    response = sqs.send_message(
        QueueUrl=logging_sqs_queue_url,
        MessageBody=json_report
    )
    
    print('Message sent to SQS queue: %s' % response)