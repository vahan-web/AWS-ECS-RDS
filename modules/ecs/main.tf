data "aws_region" "current" {}

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 5.0"

  cluster_name = "${var.environment}-cluster"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/${var.environment}"
      }
    }
  }

  tags = var.tags
}

module "ecs_service" {
  source = "terraform-aws-modules/ecs/aws//modules/service"
  version = "~> 5.0"

  name          = "${var.environment}-app"
  cluster_arn   = module.ecs.cluster_arn
  desired_count = var.service_count

  requires_compatibilities = ["FARGATE"]
  cpu                     = var.task_cpu
  memory                  = var.task_memory
  network_mode           = "awsvpc"

  container_definitions = {
    app = {
      image    = var.container_image
      cpu      = var.task_cpu
      memory   = var.task_memory
      essential = true

      readonly_root_filesystem = false
      
      port_mappings = [
        {
          containerPort = 80
          protocol     = "tcp"
        }
      ]

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost/ || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }

      log_configuration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.app.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "app"
        }
      }
      environment = [
        {
          name  = "DB_HOST"
          value = var.db_endpoint
        },
        {
          name  = "DB_PORT"
          value = "5432"
        },
        {
          name  = "DB_NAME"
          value = var.db_name
        },
        {
          name  = "DB_USER"
          value = var.db_username
        },
        {
          name  = "DB_PASSWORD"
          value = var.db_password
        }
      ]
    }
  }

  subnet_ids         = var.private_subnets
  security_group_ids = [module.app_sg.security_group_id]

  load_balancer = {
    service = {
      container_name   = "app"
      container_port   = 80
      target_group_arn = var.target_group_arn
    }
  }

  tags = var.tags
}

module "app_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.environment}-app-sg"
  description = "Security group for ECS tasks"
  vpc_id      = var.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      source_security_group_id = var.alb_sg_id
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.environment}-app"
  retention_in_days = 30
  tags              = var.tags
}