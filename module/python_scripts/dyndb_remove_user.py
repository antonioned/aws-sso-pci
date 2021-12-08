## This Lambda function removes users from the SSOUsersList DynamoDB table. The lambda is triggered when a user is
## deleted from SSO which triggers the DeleteUser event in Cloudtrail.

from pprint import pprint
import boto3
import os
import json

dyndb_table_name = os.getenv('DYNAMODB_TABLE')
identity_store_id = os.getenv('SSO_IDENTITYSTORE_ID')

sso_identitystore = boto3.client('identitystore')
dynamodb = boto3.client('dynamodb')

def get_username(userId):
    
    scan = dynamodb.scan(
        TableName=dyndb_table_name
    )
    for u in scan['Items']:
        if u['UserId']['S'] == userId:
            username = u['Username']['S']
            return username

def remove_user(userId, username):

    response = dynamodb.delete_item(
        TableName=dyndb_table_name,
        Key={
            'UserId': {'S': userId},
            'Username': {'S': username}
        }
    )
    return response

def lambda_handler(event, context):

    userId = event['detail']['requestParameters']['userId']
    username = get_username(userId)
    remove_user(userId, username)
    print("SSO username %s has been removed from the DynamoDB table." % username)