locals {
  env = "dev"
  region = "us-east-1"

  secrets = yamldecode(file(find_in_parent_folders("secrets.yml")))[local.env]
  versions = yamldecode(file("versions.yaml"))[local.env]

  environment = {
    dev = {
      cluster_node_type = "dc1.large"
    }
    prod = {
      cluster_node_type = "dc1.large"
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