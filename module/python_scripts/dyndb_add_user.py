## This Lambda function adds users to the SSOUsersList DynamoDB table. The lambda is triggered when a user is
## created in SSO which triggers the CreateUser event in Cloudtrail.

from pprint import pprint
import boto3
import os
import json

dyndb_table_name = os.getenv('DYNAMODB_TABLE')
identity_store_id = os.getenv('SSO_IDENTITYSTORE_ID')

sso_identitystore = boto3.client('identitystore')

def add_user(userId, username):
    dynamodb = boto3.client('dynamodb')

    response = dynamodb.put_item(
        TableName=dyndb_table_name,
        Item={
            'UserId': {'S': userId},
            'Username': {'S': username}
        }
    )
    return response

def get_username(identity_store_id, userId):

    response = sso_identitystore.describe_user(
                IdentityStoreId=identity_store_id,
                UserId=userId
            )
    username = response['UserName']
    return username


def lambda_handler(event, context):

    userId = event['detail']['responseElements']['user']['userId']
    
    get_username_resp = get_username(identity_store_id, userId)
    print("New SSO username created is: %s" % get_username_resp)
    add_user_resp = add_user(userId, get_username_resp)
    print("New SSO user %s added into DynamoDB table." % get_username_resp)
    pprint(add_user_resp, sort_dicts=False)
