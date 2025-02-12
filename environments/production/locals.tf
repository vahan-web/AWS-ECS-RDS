locals {
  tags = {
    Environment = var.environment
    Project     = "myapp"
    Terraform   = "true"
    ManagedBy   = "terraform"
  }
}