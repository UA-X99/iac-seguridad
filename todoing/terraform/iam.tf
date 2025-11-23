# ========================================
# IAM Roles para App Runner - Fase 1
# ========================================

# Rol de acceso para App Runner
resource "aws_iam_role" "apprunner_access" {
  name = "${var.project_name}-apprunner-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "build.apprunner.amazonaws.com"
      }
    }]
  })

  tags = {
    Name    = "${var.project_name}-apprunner-access-role"
    Project = var.project_name
  }
}

# Policy para acceder a ECR
resource "aws_iam_role_policy_attachment" "apprunner_ecr_access" {
  role       = aws_iam_role.apprunner_access.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

# Rol de instancia para App Runner
resource "aws_iam_role" "apprunner_instance" {
  name = "${var.project_name}-apprunner-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "tasks.apprunner.amazonaws.com"
      }
    }]
  })

  tags = {
    Name    = "${var.project_name}-apprunner-instance-role"
    Project = var.project_name
  }
}