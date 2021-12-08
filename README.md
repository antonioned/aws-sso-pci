# aws-sso-pci #
Repo that makes AWS SSO service PCI compliant.

## Introduction ##

AWS Single Sign-On is the service you want to use when building multi-account architecture in AWS. You log in once and then you have access to as many accounts you want or need. While useful for its core purpose, it has some drawbacks, especially when you need to use it in a PCI compliant infrastracture. 

The two PCI requirements we had issues with and that at the time of writing this SSO did not support are:
- Password expiration policy (users must change password after 90 days)
- User inactivity check (disable users after 90 days of inactivity)

## Prerequisites ##

The setup I use SSO with is always a multi-account strategy built with AWS Organizations and AWS Control Tower. I create all the accounts using terraform, the org. units as well and then run Control Tower to register them all and set up the guardrails mandated by CT. Of course, this is my setup and others are always available and possible to use.

For using this repo you need the following as a prerequisite:

- An AWS Root (Master) account where the Org and SSO will be created
- SSO already set up with permissions and groups (no users, those should be created after this code is executed)
- Appropriate permissions in that account to create resources
- Terraform version 1.0.11
- Python version 3.8

## What it does ##

The repo contains terraform and python code that create the following:

- AWS DynamoDB table to manage the list of SSO users
- Two Lambda functions related to managing that DynamoDB table
- Two Lambda function that monitor Cloudtrail events from SSO and send alerts
- AWS SQS queue where the alerts from the Lambdas will be send
- AWS Cloudwatch log groups for the Lambda logs
- AWS KMS keys to encrypt SQS queue and CW log groups

## Contribution ##

I am fully aware that the code in this repo can be improved (especially the python scripts), so any contribution is welcome. Just open PRs with any changes you see as an improvement and I will check them out. Thanks!