locals {
  env = "prod"
  region = "us-east-1"

  secrets = yamldecode(file(find_in_parent_folders("secrets.yml")))[local.env]
  versions = yamldecode(file("versions.yaml"))[local.env]

  environment = {
    dev = {
      airflow_instance_type = "r5.large"
      airflow_root_volume_size = 200
      superset_instance_type = "t2.medium"
      cluster_node_type = "dc1.large" # redshift
    }
    prod = {
      airflow_instance_type = "t3.large" # Could run out of memory on mainnet
      airflow_root_volume_size = 200
      superset_instance_type = "t2.small"
      cluster_node_type = "dc1.large" # redshift
    }
  }[local.env]

  # Labels
  name = "icon-analytics-${local.env}"
  id = "icon-analytics-${local.env}"
  tags = {
    "Name" = local.name
    "Environment" = local.env
  }

  # Remote State
  remote_state_path = "icon/analytics/${local.env}/${local.region}"
}