# ========================================
# ECR Repository - Fase 1
# ========================================

resource "aws_ecr_repository" "app" {
  name = var.ecr_repository_name

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  image_tag_mutability = "MUTABLE"

  tags = {
    Name    = "${var.project_name}-ecr"
    Project = var.project_name
  }
}

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 5 images"
      selection = {
        tagStatus     = "any"
        countType     = "imageCountMoreThan"
        countNumber   = 5
      }
      action = {
        type = "expire"
      }
    }]
  })
}