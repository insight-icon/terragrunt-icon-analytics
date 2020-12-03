terraform {
  source = "."
}

include {
  path = find_in_parent_folders()
}

locals {
  vars = read_terragrunt_config(find_in_parent_folders("variables.hcl")).locals
  airflow = find_in_parent_folders("airflow")
}

dependencies {
  paths = [local.airflow]
}

dependency "airflow" {
  config_path = local.airflow
}

inputs = {
  block_dump_bucket = "${local.vars.secrets.namespace}-icon-block-raw-${local.vars.env}"
  airflow_instance_profile_name = dependency.airflow.outputs.instance_profile_name
}
