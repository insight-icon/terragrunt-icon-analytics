This document is meant to help anyone who wants to perform analytics on the ICON blockchain.  Readers should have working experience with SQL and Python. If you intend on running long term jobs will want to run it on AWS, otherwise there are docker based deployments for local setup. This document is meant to help new users adopt the process and contribute additional analytics to support the chain in a variety of capacities.

### Overview 

To analyze the ICON Blockchain, data must be loaded into a relational database where analytics queries can be run. To extract the data, we built a tool called icon-etl which was adopted from blockchain-etl, the leading blockchain analytics github organization. This tool extracts events via HTTP requests and outputs the results into a CSV file.  This file is then loaded into postgres which builds a series of tables that can be queried with SQL and analytics performed.  The results can then be displayed in a dashboard or output to a reporting scheme (emails etc) and updated on a predefined schedule. 

If you are serious about doing analytics on ICON, please contact the Insight team for more information on running the setup. 

![](https://raw.githubusercontent.com/insight-icon/terragrunt-icon-analytics/master/docs/stack-diagram.png)

### Components 

| Component | Description | 
| :--- | :--- | 
| **Block Extractor** | Runs looped HTTP requests against a node to pull data between block ranges and output them to a CSV or JSON file. Extracts [] |
| **Object Storage (S3)** | Transient data writes between block extractor and output for reports. | 
| **[Apache Airflow](https://airflow.apache.org/)** | Workflow orchestrator that assembles steps in data pipelines in a collection of tasks.  Pipeline are written in python and can be as simple as running a series of SQL queries in order for report generation. |
| **Postgres / Redshift** | Main transaction DB for storing records. This DB is larger than the chain itself and takes over a week to sync.  Please get in touch with Insight team to get copy / access.  Redshift populated by Airflow.  Mind costs when using.  Postgres is generally good enough. |
| **[Apache Superset](https://superset.apache.org/)** | Open source dashboarding tool that connects to relational backends to produce high quality charts and interactive dashboards.  There are many tools to build visualizations (ie d3.js, plotly, etc) which are great and might be a better fit for your use case.  This tool was chosen as it is an open source alternative to Tableau and allows for the charts to be embedded via iframes into any other tools used in the ecosystem. |

### Relevant Repos 

| Repo | Component | Description | 
| :--- | :--- | :--- | 
| [terragrun-icon-analytics](https://github.com/insight-icon/terragrunt-icon-analytics) | N/A | Main reference architecture for deploying all the components on AWS | 
| [icon-etl](https://github.com/blockchain-etl/icon-etl) | Block parser | CLI tool to retrieve data via HTTP requests from an endpoint and output the data in various formats, currently csv and json with other direct connects to other middleware possible. |
| [icon-etl-airflow](https://github.com/blockchain-etl/icon-etl-airflow) | Airflow | Airflow DAGs (data pipelines) to perform analytics on |
| [superset-docker-compose](https://github.com/insight-infrastructure/superset-docker-compose) | Superset | Dashboards for analytics - Use this repo to run locally |
| [airflow-docker-compose](https://github.com/insight-infrastructure/airflow-docker-compose) | Airflow | Data pipelines - Use this repo to run Airflow locally  | 
| [terraform-aws-superset-docker](https://github.com/insight-infrastructure/terraform-aws-superset-docker) | Superset | Terraform module to deploy superset on AWS without docker |
| [terraform-icon-analytics-aws-network](https://github.com/insight-icon/terraform-icon-analytics-aws-network) | N/A | Terraform module to deploy the network on AWS | 
| [terraform-aws-superset-docker](https://github.com/insight-infrastructure/terraform-aws-superset-docker) | | Terraform module to deploy superset on AWS with docker on a VM |
| [ansible-role-superset-docker](https://github.com/insight-infrastructure/ansible-role-superset-docker) | Superset | Ansible role to setup superset with docker |
| [terraform-aws-airflow-docker](https://github.com/insight-infrastructure/terraform-aws-airflow-docker) | Airflow | Terraform module to run superset with docker on AWS |

### Infrastructure Setup 

To setup the required infrastructure, clone the `terragrunt-icon-analytics` repo and follow the README to bootstrap the infrastructure setup.  Each component is deployed individually.  You will not need all the components depending on what you are doing. 

### Building New Dags 
[Richard]

### Creating New Dashboards 

While there are many ways to make visualizations and easier to use commercial tools (Tableau etc), an emerging open source alternative is emerging called Apache Superset which we decided to adopt.  This tool has a learning curve but with SQL knowledge you will be able to make dashboards from any connected database.  To bootstrap connections to databases and example charts, follow the configuration steps in the deployment [README](https://github.com/insight-icon/terragrunt-icon-analytics#configuring-applications). 
