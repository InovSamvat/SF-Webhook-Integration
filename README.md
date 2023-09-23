# Salesforce Webhook Integration with GitHub

This project implements an integration between Salesforce and GitHub. 

## Post Deployment Steps:

- Create a Sites in Salesforce with name "gitHubWebHook"
- Store the Secret value under Custom setting "Git_Secret__c.Secret__c"

## Configure Your GitHUb

- Create a Webhook under repository settings
- Set Payload URL as <Salesforce Sites URL>/services/apexrest/webhooks
- Set Secret value same as stored in Salesforce Custom setting "Git_Secret__c.Secret__c"

## How to Test?

Push the commits to your GitHub repository and verify the records created in Salesforce under "Github Notification" tab
