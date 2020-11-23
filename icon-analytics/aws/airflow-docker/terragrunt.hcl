terraform {
  source = "github.com/insight-infrastructure/terraform-aws-airflow-docker.git?ref=${local.vars.versions.airflow-vm}"
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
  subnet_id = dependency.network.outputs.public_subnets[0]
  additional_security_groups = [
    dependency.network.outputs.sg_rds_id,
    dependency.network.outputs.sg_redshift_id,
  ]

  instance_type = local.vars.environment.airflow_instance_type
  root_volume_size = local.vars.environment.airflow_root_volume_size

  open_ports = [
    22,
    80,
    443,
    8080,
  ]
}
