## This Lambda function fetched the list of active SSO users from a DynamoDB table and then checks if those users have
## changed their SSO password in the last 86 days. When a user changes their password in to SSO, they trigger an 
## UpdatePassword event in Cloudtrail. The lambda function then compares the DynamoDB and Cloudtrail lists and 
## outputs the user(s) that need(s) to change the password in SSO.

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
sso_userids_list = []
usernames_need_pass_change_list = []
password_updated_userids_list = []

## Boto3
cloudtrail = boto3.client('cloudtrail')
dynamodb = boto3.client('dynamodb')
sqs = boto3.client('sqs')
ct_paginator = cloudtrail.get_paginator('lookup_events')
dyndb_paginator = dynamodb.get_paginator('scan')

StartingToken = None

# Get SSO userIds list from the DynamoDB table
def get_sso_users_list(StartingToken):
    
    dyndb_items_page_iterator = dyndb_paginator.paginate(
        TableName=dyndb_table_name,
        PaginationConfig={'PageSize':10, 'StartingToken':StartingToken },
    )
    
    for page in dyndb_items_page_iterator:
        for u in page['Items']:
            try: 
                userId = u['UserId']['S']
                sso_userids_list.append(userId)
                StartingToken = page["NextToken"]
            except:
                userId=None
        
    return sso_userids_list
    
# Get SSO users for which the UpdatePassword event has been triggered
def get_password_updated_userids_list(StartingToken):

    pass_change_page_iterator = ct_paginator.paginate(
        LookupAttributes=[{'AttributeKey':'EventName','AttributeValue': 'UpdatePassword'}],
        PaginationConfig={'PageSize':10, 'StartingToken':StartingToken },
        StartTime=check_date,
        EndTime= current_date
    )

    for page in pass_change_page_iterator:
        for event in page['Events']:
            try:
                    json_object = json.loads(event['CloudTrailEvent'])
                    password_updated_userid = json_object['requestParameters']['userId']
                    password_updated_userids_list.append(password_updated_userid)
                    StartingToken = page["NextToken"]              
            except:
                    password_updated_userid=None
        
    return password_updated_userids_list

# Set SSO usernames that need a password change from the userIds_need_pass_change list
def set_usernames_need_pass_change(userIds_need_pass_change, StartingToken):
        
    dyndb_items_page_iterator = dyndb_paginator.paginate(
        TableName=dyndb_table_name,
        PaginationConfig={'PageSize':10, 'StartingToken':StartingToken },
    )
        
    for page in dyndb_items_page_iterator:
        for item in page['Items']:
            for id in userIds_need_pass_change:
                if item['UserId']['S'] == id:
                    try:
                        username = item['Username']['S']
                        usernames_need_pass_change_list.append(username)
                        StartingToken = page["NextToken"]
                    except:
                        username=None
                            
    return usernames_need_pass_change_list


def lambda_handler(event, context):
    
    sso_userids_list = get_sso_users_list(StartingToken)
    password_updated_userIds_list = get_password_updated_userids_list(StartingToken)
    password_updated_userIds_list = list(dict.fromkeys(password_updated_userIds_list))
    userIds_need_pass_change = [userId for userId in sso_userids_list if userId not in password_updated_userIds_list]
    userIds_need_pass_change = list(dict.fromkeys(userIds_need_pass_change))
    usernames_need_pass_change = set_usernames_need_pass_change(userIds_need_pass_change, StartingToken)
    usernames_need_pass_change = list(dict.fromkeys(usernames_need_pass_change))
    json_report = """
    {
        "Records":
            [
                {
                    "eventName" : "PasswordChangeRequired",
                    "userList": """ + '"' + str(usernames_need_pass_change) + '"' + """
                }
            ]
    }
    """
    
    response = sqs.send_message(
        QueueUrl=logging_sqs_queue_url,
        MessageBody=json_report
    )
    
    print('Message sent to SQS queue: %s' % response)