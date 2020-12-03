# terragrunt-icon-analytics

This is a reference architecture to deploy the analytics platform for use with the ICON-ETL exporter in Airflow.

To perform analytics on ICON, you will first need the infrastructure deployed with this repo. To create new analytics pipelines, you will need to modify the [airflow dags](https://github.com/blockchain-etl/icon-etl-airflow) repo. Best practice would be to fork that repo, ssh into the airflow machine, and replace the dags folder (~/airflow/dags) with your fork. 

A supplemental deployment guide can be found [here](https://docs.google.com/document/d/10Dv2dbULjBCm3Qyt7jYekn1tTyWQV78XtPUGlrchvYk/edit?usp=sharing).

## Deploying the Stack 

The process involves four steps:

1. Setting up accounts, projects, and API keys on your cloud provider. 
1. Configure the necessary files and ssh keys. 
1. Run the deployment
1. Configure applications (Superset and Airflow)

After these steps, you will then be able to run the Airflow DAGs linked above to build data pipelines 

### Account Setup   

Before running on any cloud, signup and provide payment details to create an active account and project.
You will need API keys to any provider that you intend on running on.
For a walkthrough on each provider, please check the following links for setting up your cloud accounts. 
 
 - [AWS](https://www.notion.so/insightx/AWS-API-Keys-Tutorial-175fa12e9b5b43509235a97fca275653)
 - [GCP](https://www.notion.so/insightx/GCP-API-Keys-Tutorial-f4a265539a6b47eeb5a6fc01a0ba3a77)
 
### Deployment Setup
 
A sample secrets file is provided in the repository for your customization. Make a copy of the `secrets.yml.example` and name `secrets.yml`. Edit the file to your needs.  You are able to run a dev and prod setup.  

You will also need ssh keys. If you put a password on the SSH key, you will be prompted for it on deployment.  

```shell script
# Generate ssh key 
ssh-keygen -b 4096
```
Take note of the path and insert it into secrets.yml file for the `public_key_path` (*.pub) and `private_key_path`. 
 
##### Prerequisites  
 
To run all the different tools, you will need the following tools:
 
1. terraform - version 0.13+
1. terragrunt - version 0.25.x (not newest 0.26)
1. ansible (Not supported on windows without WSL) 

### Running Deployment

**Preflight** 

Before running the deployment, ensure that your cloud credentials are accessible to Terragrunt, either as environment variables, or some other utility (like aws-vault for AWS). You will also may want to modify various settings like DB / instance sizes before deploying. To do this, in the `icon-analytics/aws/variables.tf` file, modify [the fields in the environment](https://github.com/insight-icon/terragrunt-icon-analytics/blob/master/icon-analytics/aws/variables.hcl#L16) (prod by default) that you need. 

**Deploying** 

You will need to use Terragrunt to deploy modules in a specific order using the command `terragrunt apply --terragrunt-working-dir /path/to/each/module`.

The order you apply modules is important, with some modules being required and others being optional.

- Network 
- RDS
    - Take note of output `this_db_instance_address` which is needed by Airflow post-deployment and Superset pre-deployment.  
- Redshift (optional)
- Airflow (ETL)
    - For a VM based deployment, apply `airflow`.  For docker (preferred), apply `airflow-docker`. 
- S3 
    - Creates buckets for Airflow to push data.  Take note of the bucket name, you will need it later. 
- Superset (visualizations)
    - To bootstrap the database connection, the `db_instance_address` needs to be populated in the `superset/sources/database_sources.yaml` by copying the `database_sources.example` and filling out the appropriate details along with items from the `secrets.yaml`. 

For example, if you were to clone a local deployment to `/Users/example/analytics/`, you would need to deploy the network module with `terragrunt apply --terragrunt-working-dir /Users/example/analytics/icon-analytics/aws/network/`

Additional DB settings can be applied with `postgres` and `redshift-config` directories. 

##### Destroying Deployment

To destroy the deployment, simply run `terragrunt destroy --terragrunt-working-dir /path/to/each/module` in the reverse order to your deployment.
Make sure that you have activated the appropriate cloud credentials.
Also note that you are running `terragrunt DESTROY` and not `terragrunt APPLY`, as applying the module again would not do anything unless your source has changed.

##### Running Multiple Environments 

To run multiple environments, put a new key in the `secrets.yml` file like the `prod` section. Then in the `icon-analytics/aws/variables.tf` file, change the `env` field to your environment. You will also find environment specific options there. 

### Configuring Applications 

After deploying the applications, navigate to the UI and follow these steps.

**Airflow** 

After deploying Airflow, navigate to `airflow.yourdomain.com` and login with the credentials from your `secrets.yaml`. You will need to set some variables in order to run the DAGs. 

- Navigate the the variables tab inside `Admin`
- Fill in the appropriate values in the `/airflow/variables.json` per the s3 bucket you created 
- Choose import from file and navigate to the `/airflow/variables.json`
- Go to the `Connections` tab in `Admin`
- Create a `postgres` connection with the details from deploying the `rds` module. 
    - If using redshift, populate this connection as well. 
- Your dags at this point should sync from the `icon-etl-airflow` repository.  If you want to make modifications, ssh into the airflow instance and change the `DAGS_REPO` in the `.env` file to point to your own fork of the dags repo. Syncing happens automatically on a schedule per the `git-sync` service in the docker-compose.

**Superset**

After deploying superset, navigate to `superset.yourdomain.com` and login with the credentials from your `secrets.yaml`. You will need to first connect to your backends.  

You can either populate these connection values manually into superset or import them via a config file provided. To import it via file, make a copy of the `./superset/sources/database_sources.yaml.example` and remove the `.example` suffix.  Then you will need to change the values in line 6 for the `sqlalchemy_uri` to reflect the outputs of the corresponding backend (`this_db_instance_address`) and username / password from the `secrets.yaml`. 

To import charts, import them from the `superset/charts` directory.  

### Relevant Repos

**Analytics** 
- [blockchain-etl/icon-etl](https://github.com/blockchain-etl/icon-etl)
    - Parser for the blockchain
- [blockchain-etl/icon-etl-airflow](https://github.com/blockchain-etl/icon-etl-airflow)
    - Airflow DAGs (data pipelines) to perform analytics on 
    
**Deployment** 
- [insight-infrastructure/superset-docker-compose](https://github.com/insight-infrastructure/superset-docker-compose)
    - Use this repo to run Superset locally 
- [insight-infrastructure/airflow-docker-compose](https://github.com/insight-infrastructure/airflow-docker-compose)
    - Use this repo to run Airflow locally 
- [insight-infrastructure/terraform-aws-superset-docker](https://github.com/insight-infrastructure/terraform-aws-superset-docker) 
- [insight-icon/terraform-icon-analytics-aws-network](https://github.com/insight-icon/terraform-icon-analytics-aws-network)
- [insight-infrastructure/terraform-aws-superset-docker](https://github.com/insight-infrastructure/terraform-aws-superset-docker)
- [insight-infrastructure/ansible-role-superset-docker](https://github.com/insight-infrastructure/ansible-role-superset-docker)
- [terraform-aws-redshift](https://github.com/terraform-aws-modules/terraform-aws-redshift)
- [terraform-aws-airflow-docker](https://github.com/insight-infrastructure/terraform-aws-airflow-docker)

### Development 

For development:
- npm
- meta
    - `npm i -g meta`
    - Run `meta git clone .` at the base of the repo to clone the modules into the `modules` directory

