# What is this?

This is a bunch of bicep scripts to create an environment for a web app hosted on Azure functions.

# What do I need to run this?

1. go to infra directory, populate the parameters in deploy.sh and main.bicepparam
2. run deploy.sh

I've also created a sample app function in the App directory. You can deploy this (note, the deployed components will be behind the vnet, you'll need to temporarily open the vnet to access the function app). 

Also, the database will be empty so you might want to create an employee table.

