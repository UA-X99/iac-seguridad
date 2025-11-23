output "ecr_repository_url" {
  description = "URL del repositorio ECR"
  value       = aws_ecr_repository.app.repository_url
}

output "ecr_repository_name" {
  description = "Nombre del repositorio ECR"
  value       = aws_ecr_repository.app.name
}

output "access_role_arn" {
  description = "ARN del rol de acceso de App Runner"
  value       = aws_iam_role.apprunner_access.arn
}

output "instance_role_arn" {
  description = "ARN del rol de instancia de App Runner"
  value       = aws_iam_role.apprunner_instance.arn
}

output "docker_push_commands" {
  description = "Comandos para subir imagen a ECR"
  value       = <<-EOT
# 1. Autenticarse en ECR
aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.app.repository_url}

# 2. Etiquetar imagen local
docker tag adriangc22/todoing:latest ${aws_ecr_repository.app.repository_url}:latest

# 3. Subir imagen a ECR
docker push ${aws_ecr_repository.app.repository_url}:latest
EOT
}

# ========================================
# Outputs de App Runner (Descomentar en Fase 2)
# ========================================

# output "apprunner_service_id" {
#   description = "ID del servicio App Runner"
#   value       = aws_apprunner_service.app.service_id
# }

# output "apprunner_service_arn" {
#   description = "ARN del servicio App Runner"
#   value       = aws_apprunner_service.app.arn
# }

# output "apprunner_service_url" {
#   description = "URL pública del servicio App Runner"
#   value       = "https://${aws_apprunner_service.app.service_url}"
# }

# output "apprunner_service_status" {
#   description = "Estado del servicio App Runner"
#   value       = aws_apprunner_service.app.status
# }