terraform {
  source = "github.com/insight-infrastructure/terraform-aws-ec2-airflow.git?ref=${local.vars.versions.airflow-vm}"
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
    dependency.network.outputs.sg_bastion_private_id,
    dependency.network.outputs.sg_rds_id,
    dependency.network.outputs.sg_redshift_id,
    dependency.network.outputs.sg_prometheus_id,
  ]

  instance_type = "m5.xlarge"
  create_s3_output_bucket = false
  root_volume_size = 200

  open_ports = [
    22,
    2049,
    8080,
    80,
    443
  ]

  playbook_vars = {
    airflow_executor = "LocalExecutor"
  }

  //  dags_dependencies = [
  //    {name: "scikit-learn", version: "0.23.2"}
  //  ]
}


//inputs = {
//
////  s3_output_bucket_name = ""
//
//  vpc_id = dependency.network.outputs.vpc_id
//  subnet_id = dependency.network.outputs.public_subnets[0]
//  additional_security_groups = [
//    dependency.network.outputs.sg_bastion_private_id,
//    dependency.network.outputs.sg_rds_id,
//    dependency.network.outputs.sg_redshift_id,
//    dependency.network.outputs.sg_prometheus_id,
//  ]
//
//  instance_type = "m5.xlarge"
//  create_s3_output_bucket = false
//  root_volume_size = 200
//
//  open_ports = [
//    22,
//    2049,
//    8080,
//    80,
//    443]
//
//  //  TODO: Change to airflow DB
////  airflow_database_conn = "postgres://${local.vars.secrets.airflow_username}:${local.vars.secrets.airflow_password}@${dependency.rds.outputs.this_db_instance_address}:5432/${local.vars.secrets.airflow_db}"
////  airflow_executor = "SequentialExecutor"
//  dags_dependencies = [
//    {name: "scikit-learn", version: "0.23.2"}
//  ]
//
//  playbook_vars = {
//    airflow_executor = "LocalExecutor"
//  }
//
////  dags_dependencies = [
////    {name: "scikit-learn", version: "0.23.2"}
////  ]
//}
