output "cluster_name" {
  value = module.ecs.cluster_name
}

output "cluster_arn" {
  value = module.ecs.cluster_arn
}

output "app_sg_id" {
  value = module.app_sg.security_group_id
}