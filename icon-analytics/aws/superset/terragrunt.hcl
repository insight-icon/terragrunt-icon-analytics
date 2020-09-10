terraform {
  source = "github.com/insight-infrastructure/terraform-aws-superset.git?ref=${local.vars.versions.superset}"
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
  subnet_ids = dependency.network.outputs.public_subnets

  force_create = true

  additional_security_groups = [
    dependency.network.outputs.sg_bastion_private_id,
    dependency.network.outputs.sg_rds_id,
    dependency.network.outputs.sg_redshift_id,
    dependency.network.outputs.sg_prometheus_id,
  ]
  hostname = "superset"
}
