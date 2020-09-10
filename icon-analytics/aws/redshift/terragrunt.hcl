terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-redshift.git?ref=${local.vars.versions.redshift}"
}

include {
  path = find_in_parent_folders()
}

locals {
  vars = read_terragrunt_config(find_in_parent_folders("variables.hcl")).locals
  network = find_in_parent_folders("network")
}

dependencies {
  paths = [local.network]
}

dependency "network" {
  config_path = local.network
}

inputs = {
  vpc_id = dependency.network.outputs.vpc_id

  cluster_identifier      = local.vars.id
  final_snapshot_identifier = local.vars.id

  cluster_number_of_nodes = 1

  cluster_database_name   = "icon"
  cluster_master_username = local.vars.secrets.redshift_admin_user
  cluster_master_password = local.vars.secrets.redshift_admin_password
  # Group parameters
  wlm_json_configuration = "[{\"query_concurrency\": 5}]"

  # DB Subnet Group Inputs
  vpc_security_group_ids = [dependency.network.outputs.sg_redshift_id]
  subnets = dependency.network.outputs.public_subnets
}
