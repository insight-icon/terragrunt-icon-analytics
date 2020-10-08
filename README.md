# terragrunt-icon-analytics

This is a reference architecture to deploy the analytics platform for use with the ICON-ETL exporter in Airflow.


## Deploying the Stack 

The process involves three steps:

1. Setting up accounts, projects, and API keys on your cloud provider. 
1. Configure the necessary files and ssh keys. 
1. Run the deployment

### Cloud Providers  

Before running on any cloud, signup and provide payment details to create an active account and project.
You will need API keys to any provider that you intend on running on.
For a walkthrough on each provider, please check the following links for setting up your cloud accounts. 
 
 - [AWS](https://www.notion.so/insightx/AWS-API-Keys-Tutorial-175fa12e9b5b43509235a97fca275653)
 - [GCP](https://www.notion.so/insightx/GCP-API-Keys-Tutorial-f4a265539a6b47eeb5a6fc01a0ba3a77)
 
### Deployment Setup
 
 A sample secrets file is provided in the repository for your customization.
 
##### Prerequisites  
 
 To run all the different tools, you will need the following tools:
 
 1. Terraform
 1. Terragrunt 
 1. Ansible (Not supported on windows without WSL)
 
##### SSH Keys

Generate a new SSH keypair and include the file path in the secrets file.

### Running Deployment

Ensure that your cloud credentials are accessible to Terragrunt, either as environment variables, or some other utility (like aws-vault for AWS).
You will need to use Terragrunt to deploy modules in a specific order using the command `terragrunt apply --terragrunt-working-dir /path/to/each/module`.

The order you apply modules is important, with some modules being required and others being optional.
Modules should be applied:

- Network (required)
- RDS (required if loading data into Airflow)
- Postgres (required if using RDS)
- Airflow (required if using Airflow)
- S3 (required if using Airflow)
- Superset (required if using Superset)

For example, if you were to clone a local deployment to `/Users/example/analytics/`, you would need to deploy the network module with `terragrunt apply --terragrunt-working-dir /Users/example/analytics/icon-analytics/aws/network/`

### Destroying Deployment

To destroy the deployment, simply run `terragrunt destroy --terragrunt-working-dir /path/to/each/module` in the reverse order to your deployment.
Make sure that you have activated the appropriate cloud credentials.
Also note that you are running `terragrunt DESTROY` and not `terragrunt APPLY`, as applying the module again would not do anything unless your source has changed.