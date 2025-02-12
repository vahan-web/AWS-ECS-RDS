aws_region      = "us-west-2"
environment     = "production"
vpc_cidr        = "10.0.0.0/16"

# ECS settings
container_image = "nginx:latest"
service_count   = 3
task_cpu        = "512"
task_memory     = "1024"

# RDS settings
engine_version          = "17"
instance_class          = "db.t3.medium"
allocated_storage       = 50
db_name                = "appdb"
db_username            = "dbadmin"
db_password            = "change-this-in-parameter-store"  # Should be changed and stored securely
backup_retention_period = 30