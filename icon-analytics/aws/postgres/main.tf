
variable "rds_admin_user" {}
variable "rds_admin_password" {}
variable "db_host" {}
variable "airflow_password" {}
variable "airflow_username" {}
variable "airflow_db" {}

provider "postgresql" {
  host            = var.db_host
  port            = 5432
  username        = var.rds_admin_user
  password        = var.rds_admin_password
  superuser = false
//  sslmode         = "require"
//  connect_timeout = 15
}

resource "postgresql_role" "airflow_role" {
  name     = var.airflow_username
  login    = true
  password = var.airflow_password
}

resource "postgresql_database" "my_db" {
  name              = var.airflow_db
  owner             = postgresql_role.airflow_role.name
  template          = "template0"
  lc_collate        = "C"
  connection_limit  = -1
  allow_connections = true
}

