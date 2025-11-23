#!/bin/bash

# Script para subir imagen de Docker a AWS ECR
# Uso: ./push-to-ecr.sh

set -e

echo "======================================"
echo "Subiendo imagen a AWS ECR"
echo "======================================"

# Variables (se obtienen de los outputs de Terraform)
AWS_REGION="us-east-2"
ECR_REPO_URL=$(cd ../terraform && terraform output -raw ecr_repository_url 2>/dev/null)
LOCAL_IMAGE="adriangc22/todoing:latest"

if [ -z "$ECR_REPO_URL" ]; then
  echo "❌ Error: No se pudo obtener la URL del repositorio ECR."
  echo "   Asegúrate de haber ejecutado 'terraform apply' primero."
  exit 1
fi

echo "📦 Repositorio ECR: $ECR_REPO_URL"
echo "🐳 Imagen local: $LOCAL_IMAGE"
echo ""

# 1. Autenticarse en ECR
echo "🔐 Paso 1/4: Autenticando en ECR..."
aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin $ECR_REPO_URL

# 2. Verificar que la imagen local existe
echo ""
echo "🔍 Paso 2/4: Verificando imagen local..."
if ! docker image inspect $LOCAL_IMAGE > /dev/null 2>&1; then
  echo "❌ Error: La imagen $LOCAL_IMAGE no existe localmente."
  echo "   Ejecuta: docker pull $LOCAL_IMAGE"
  exit 1
fi
echo "✅ Imagen local encontrada"

# 3. Etiquetar imagen
echo ""
echo "🏷️  Paso 3/4: Etiquetando imagen..."
docker tag $LOCAL_IMAGE $ECR_REPO_URL:latest
echo "✅ Imagen etiquetada: $ECR_REPO_URL:latest"

# 4. Subir imagen a ECR
echo ""
echo "⬆️  Paso 4/4: Subiendo imagen a ECR..."
docker push $ECR_REPO_URL:latest

echo ""
echo "======================================"
echo "✅ ¡Imagen subida exitosamente!"
echo "======================================"
echo ""
echo "Imagen en ECR: $ECR_REPO_URL:latest"
echo ""
echo "Para actualizar App Runner, ejecuta:"
echo "  cd ../terraform"
echo "  terraform apply -auto-approve"