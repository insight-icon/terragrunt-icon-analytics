terraform {
  source = "."
}

include {
  path = find_in_parent_folders()
}

locals {
  vars = read_terragrunt_config(find_in_parent_folders("variables.hcl")).locals
  rds = find_in_parent_folders("rds")
}

dependencies {
  paths = [local.rds]
}

dependency "rds" {
  config_path = local.rds
}

inputs = {
  db_host = dependency.rds.outputs.this_db_instance_address
  username = local.vars.secrets.rds_admin_user
  password = local.vars.secrets.rds_admin_password
}


