This document is meant to help anyone who wants to perform analytics on the ICON blockchain.  Readers should have working experience with SQL and Python. If you intend on running long term jobs will want to run it on AWS, otherwise there are docker based deployments for local setup. This document is meant to help new users adopt the process and contribute additional analytics to support the chain in a variety of capacities.

### Overview 

To analyze the ICON Blockchain, data must be loaded into a relational database where analytics queries can be run. To extract the data, we built a tool called icon-etl which was adopted from blockchain-etl, the leading blockchain analytics github organization. This tool extracts events via HTTP requests and outputs the results into a CSV file.  This file is then loaded into postgres which builds a series of tables that can be queried with SQL and analytics performed.  The results can then be displayed in a dashboard or output to a reporting scheme (emails etc) and updated on a predefined schedule. 

If you are serious about doing analytics on ICON, please contact the Insight team for more information on running the setup. 

![](https://raw.githubusercontent.com/insight-icon/terragrunt-icon-analytics/master/docs/stack-diagram.png)

### Components 

| Component | Description | 
| :--- | :--- | 
| **Block Extractor** | Uses [icon-etl](https://github.com/blockchain-etl/icon-etl) to run looped HTTP requests against a node to pull data between block ranges and output them to a CSV or JSON file. Extracts [these tables](#tables) section. |
| **Object Storage (S3)** | Transient data writes between block extractor and output for reports. | 
| **[Apache Airflow](https://airflow.apache.org/)** | Workflow orchestrator that assembles steps in data pipelines in a collection of tasks.  Pipeline are written in python and can be as simple as running a series of SQL queries in order for report generation. |
| **Postgres / Redshift** | Main transaction DB for storing records. This DB is larger than the chain itself and takes over a week to sync.  Please get in touch with Insight team to get copy / access.  Redshift populated by Airflow.  Mind costs when using.  Postgres is generally good enough. |
| **[Apache Superset](https://superset.apache.org/)** | Open source dashboarding tool that connects to relational backends to produce high quality charts and interactive dashboards.  There are many tools to build visualizations (ie d3.js, plotly, etc) which are great and might be a better fit for your use case.  This tool was chosen as it is an open source alternative to Tableau and allows for the charts to be embedded via iframes into any other tools used in the ecosystem. |

### Schema 
#### Base Tables and Data Types

##### blocks

| Field            	| Type   	|
|------------------	|--------	|
| number           	| bigint 	|
| hash             	| string 	|
| parent_hash      	| string 	|
| merkle_root_hash 	| string 	|
| timestamp        	| bigint 	|
| version          	| string 	|
| peer_id          	| string 	|
| signature        	| string 	|
| next_leader      	| string 	|

##### transactions

| Field             	| Type           	|
|-------------------	|----------------	|
| version           	| string         	|
| from_address      	| string         	|
| to_address        	| string         	|
| value             	| numeric(38,0)  	|
| step_limit        	| numeric(38,0)  	|
| timestamp         	| bigint         	|
| nid               	| int            	|
| nonce             	| numeric(100,0) 	|
| **hash**          	| **string**     	|
| transaction_index 	| bigint         	|
| block_hash        	| string         	|
| block_number      	| bigint         	|
| fee               	| numeric(38,0)  	|
| signature         	| string         	|
| data_type         	| string         	|
| data              	| string         	|

##### logs

| Field                 	| Type       	|
|-----------------------	|------------	|
| **log_index**         	| **int**    	|
| **transaction_hash**  	| **string** 	|
| **transaction_index** 	| **int**    	|
| block_hash            	| string     	|
| block_number          	| int        	|
| address               	| string     	|
| data                  	| string     	|
| indexed               	| string     	|

##### receipts

| Field                 	| Type          	|
|-----------------------	|---------------	|
| **transaction_hash**  	| **string**    	|
| **transaction_index** 	| **int**       	|
| block_hash            	| string        	|
| block_number          	| int           	|
| cumulative_step_used  	| numeric(38,0) 	|
| step_used             	| numeric(38,0) 	|
| step_price            	| numeric(38,0) 	|
| score_address         	| string        	|
| status                	| string        	|

#### Materialized Views
##### Wallet Balance Calculations

The first two materialized views are used to generate the third view, which provides a current balance for every wallet. 

- debits
- credits
- balances

Most of the analytics processes require that the transaction data be reduced down into a smaller subset of columns, and then further reduced down in time.
First, the _reduced_trans_ view is created/updated with a subset of columns.
Secondly, the _current_period_ and _previous_period_ views are created/updated to provide the last 30 and the last 60 (minus the last 30) days worth of transaction data.


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
#### From scratch
To build a new DAG from scratch, create a new Python file at the root of the _dags_ folder.

#### Running SQL
To run SQL queries in your DAG, you will need to import _PostgresHook_ from _airflow.hooks.postgres_hook_.
Briefly, to use this hook and to make a query, you can use the following:

```python
sql = "SELECT *"
pg_hook = PostgresHook("postgres")
pg_cursor = pg_hook.get_cursor()
pg_cursor.execute(sql)
result = pg_cursor.fetchall()
```

Keep in mind that this will return the entire result of the query as the _result_ object, and you will need to do something with it afterwards.
You can use the csv writer module to write the output to a file, as in the following example.

```python
with open(os.path.join(output_path, "output_file_name.csv"), "w") as out_file:
    wr = csv.writer(out_file, quoting=csv.QUOTE_ALL)
    wr.writerows(result)
```

Using the _writerows()_ function will output the whole _result_ object at once.

#### Running SQL as a nightly report
Included in the base distribution in the Airflow repo is a DAG that will run reports every night and store them into S3.
To use this, all you will need to do is create a new SQL file containing your query and place it into the _nightly_report_scripts_ folder as a _*.sql_ file.
Once you have placed your new files into this directory, the next time the DAG runs, it will collect all of the files in the directory and run them as part of the batch.
The resulting CSV files will be placed in the S3 bucket used for block outputs in the _reports_ folder.

### Creating New Dashboards 

While there are many ways to make visualizations and easier to use commercial tools (Tableau etc), an emerging open source alternative is emerging called Apache Superset which we decided to adopt.  This tool has a learning curve but with SQL knowledge you will be able to make dashboards from any connected database.  To bootstrap connections to databases and example charts, follow the configuration steps in the deployment [README](https://github.com/insight-icon/terragrunt-icon-analytics#configuring-applications). 
