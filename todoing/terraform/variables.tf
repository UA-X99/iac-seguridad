variable "aws_region" {
  description = "Región de AWS donde se desplegará la infraestructura"
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "todoing"
}

variable "app_runner_service_name" {
  description = "Nombre del servicio de App Runner"
  type        = string
  default     = "todoing-service"
}

variable "ecr_repository_name" {
  description = "Nombre del repositorio ECR"
  type        = string
  default     = "todoing"
}

variable "mongodb_atlas_uri" {
  description = "URI de conexión a MongoDB Atlas"
  type        = string
  sensitive   = true
}

variable "mongodb_database" {
  description = "Nombre de la base de datos MongoDB"
  type        = string
  default     = "todo_app"
}

variable "app_runner_cpu" {
  description = "CPU para App Runner (1024 = 1 vCPU)"
  type        = string
  default     = "1024"
}

variable "app_runner_memory" {
  description = "Memoria para App Runner (2048 = 2 GB)"
  type        = string
  default     = "2048"
}

variable "app_port" {
  description = "Puerto de la aplicación"
  type        = string
  default     = "80"
}

variable "dockerhub_image" {
  description = "Imagen de Docker Hub (opcional, si no se usa ECR)"
  type        = string
  default     = "adriangc22/todoing:latest"
}

variable "use_ecr" {
  description = "Usar ECR en lugar de Docker Hub"
  type        = bool
  default     = true
}