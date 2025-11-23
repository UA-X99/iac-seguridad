# ========================================
# App Runner Service - Fase 2
# RENOMBRAR a apprunner.tf después de subir imagen
# ========================================

resource "aws_apprunner_service" "app" {
  service_name = var.app_runner_service_name

  source_configuration {
    image_repository {
      image_identifier      = "${aws_ecr_repository.app.repository_url}:latest"
      image_repository_type = "ECR"
      
      image_configuration {
        port = var.app_port
        
        runtime_environment_variables = {
          MONGODB_URI      = var.mongodb_atlas_uri
          MONGODB_DATABASE = var.mongodb_database
        }
      }
    }

    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_access.arn
    }

    auto_deployments_enabled = false
  }

  instance_configuration {
    cpu               = var.app_runner_cpu
    memory            = var.app_runner_memory
    instance_role_arn = aws_iam_role.apprunner_instance.arn
  }

  health_check_configuration {
    protocol            = "HTTP"
    path                = "/"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 1
    unhealthy_threshold = 5
  }

  tags = {
    Name    = var.app_runner_service_name
    Project = var.project_name
  }

  depends_on = [
    aws_iam_role_policy_attachment.apprunner_ecr_access
  ]
}