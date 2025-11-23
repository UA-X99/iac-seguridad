# ToDoing - Infraestructura como Código (IaC)

[![Terraform](https://img.shields.io/badge/Terraform-1.0+-623CE4?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-App_Runner_+_ECR-FF9900?logo=amazon-aws)](https://aws.amazon.com/)
[![MongoDB](https://img.shields.io/badge/MongoDB-Atlas-47A248?logo=mongodb)](https://www.mongodb.com/cloud/atlas)

Despliegue automatizado de la aplicación [ToDoing](https://github.com/EdgarAntonioTorres/Dooing) en AWS usando Terraform para provisionar infraestructura con App Runner y ECR.

---

## 📋 Tabla de contenidos

- [Arquitectura](#-arquitectura)
- [Requisitos previos](#-requisitos-previos)
- [Configuración inicial](#-configuración-inicial)
- [Despliegue en 2 fases](#-despliegue-en-2-fases)
- [Comandos útiles](#-comandos-útiles)
- [Limpieza de recursos](#-limpieza-de-recursos)
- [Estructura del proyecto](#-estructura-del-proyecto)
- [Troubleshooting](#-troubleshooting)

---

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────┐
│          AWS Account (us-east-2)            │
│                                             │
│  ┌──────────────────────────────────────┐  │
│  │  Amazon ECR                          │  │
│  │  └── todoing:latest                  │  │
│  │      (Imagen Docker privada)         │  │
│  └──────────────────────────────────────┘  │
│                    ↓                        │
│  ┌──────────────────────────────────────┐  │
│  │  AWS App Runner                      │  │
│  │  ├── CPU: 1 vCPU                     │  │
│  │  ├── Memory: 2 GB                    │  │
│  │  ├── Port: 80                        │  │
│  │  ├── Health Check: HTTP /            │  │
│  │  └── Auto HTTPS habilitado           │  │
│  └──────────────────────────────────────┘  │
│                    ↓                        │
│      https://xxxxx.awsapprunner.com        │
└─────────────────────────────────────────────┘
                     ↓ (internet)
         ┌──────────────────────────┐
         │   MongoDB Atlas (Cloud)  │
         │   └── todo_app database  │
         └──────────────────────────┘
```

### Recursos AWS creados por Terraform:

- **Amazon ECR**: Repositorio privado para la imagen Docker
- **IAM Roles**: Permisos para que App Runner acceda a ECR
- **AWS App Runner**: Servicio que ejecuta el contenedor con auto-scaling

---

## 📋 Requisitos previos

### 1. Herramientas instaladas

- [AWS CLI](https://aws.amazon.com/cli/) >= 2.0
- [Terraform](https://www.terraform.io/downloads) >= 1.0
- [Docker](https://www.docker.com/get-started) >= 20.0
- Git

### 2. Cuentas necesarias

- ✅ Cuenta de AWS (con acceso a ECR y App Runner)
- ✅ Cuenta de MongoDB Atlas (gratuita M0)

### 3. Credenciales configuradas

**AWS CLI:**
```bash
aws configure
```

Ingresa:
- AWS Access Key ID
- AWS Secret Access Key  
- Default region: `us-east-2` (Ohio) - o la región que prefieras
- Default output format: `json`

Verifica:
```bash
aws sts get-caller-identity
```

---

## 🔧 Configuración inicial

### Paso 1: Clonar el repositorio

```bash
git clone <URL_DE_ESTE_REPO>
cd todoing-iac
```

### Paso 2: Configurar MongoDB Atlas

1. Crea una cuenta en [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
2. Crea un cluster gratuito (M0)
3. Crea un usuario de base de datos:
   - Username: `mongoadmin` (o el que prefieras)
   - Password: (anota tu contraseña)
4. Configura Network Access: Agrega `0.0.0.0/0` para permitir acceso desde App Runner
5. Obtén tu **Connection String**:
   ```
   mongodb+srv://usuario:password@cluster.mongodb.net/?retryWrites=true&w=majority
   ```

### Paso 3: Configurar variables de Terraform

Edita `terraform/terraform.tfvars`:

```hcl
# Región de AWS (cambiar según tu aws configure)
aws_region = "us-east-2"

# MongoDB Atlas - IMPORTANTE: Cambia con tu connection string real
mongodb_atlas_uri = "mongodb+srv://usuario:password@cluster.mongodb.net/?retryWrites=true&w=majority"
mongodb_database  = "todo_app"

# Configuración de recursos (opcional, ajustar según necesidades)
app_runner_cpu    = "1024"  # 1 vCPU
app_runner_memory = "2048"  # 2 GB
```

---

## 🚀 Despliegue en 2 fases

> **⚠️ IMPORTANTE:** El despliegue se realiza en 2 fases porque App Runner necesita que la imagen ya exista en ECR antes de crear el servicio.

### 📦 FASE 1: Crear ECR y subir imagen

#### 1.1 Inicializar Terraform

```bash
cd terraform
terraform init
terraform validate
```

#### 1.2 Crear repositorio ECR e IAM Roles

En esta fase, el archivo `apprunner.tf` debe tener extensión `.disabled` para que no se intente crear el servicio todavía.

```bash
terraform plan
terraform apply
```

Escribe `yes` cuando pregunte.

**Outputs esperados:**
- `ecr_repository_url`: URL del repositorio ECR creado
- `access_role_arn`: ARN del rol IAM para App Runner
- `docker_push_commands`: Comandos para subir la imagen

#### 1.3 Subir imagen a ECR

```bash
cd ../scripts
chmod +x push-to-ecr.sh
./push-to-ecr.sh
```

Este script:
1. ✅ Autentica Docker con ECR
2. ✅ Etiqueta tu imagen local
3. ✅ Sube la imagen a ECR

⏳ **Tiempo estimado:** 5-10 minutos (depende de tu conexión).

---

### 🚀 FASE 2: Crear App Runner

#### 2.1 Activar archivo de App Runner

```bash
cd ../terraform
mv apprunner.tf.disabled apprunner.tf
```

#### 2.2 Descomentar outputs de App Runner

Edita `terraform/outputs.tf` y **descomenta** estas líneas (aproximadamente líneas 39-57):

```hcl
# ANTES (comentado):
# output "apprunner_service_url" {
#   description = "URL pública del servicio App Runner"
#   value       = "https://${aws_apprunner_service.app.service_url}"
# }

# DESPUÉS (descomentado):
output "apprunner_service_url" {
  description = "URL pública del servicio App Runner"
  value       = "https://${aws_apprunner_service.app.service_url}"
}
```

Descomenta estos 4 outputs:
- `apprunner_service_id`
- `apprunner_service_arn`
- `apprunner_service_url`
- `apprunner_service_status`

#### 2.3 Crear servicio App Runner

```bash
terraform validate
terraform plan
terraform apply
```

Escribe `yes` cuando pregunte.

⏳ **Tiempo estimado:** 3-5 minutos.

#### 2.4 Obtener URL de la aplicación

```bash
terraform output apprunner_service_url
```

**Output esperado:**
```
https://xxxxx.us-east-2.awsapprunner.com
```

---

## 🌐 Acceder a la aplicación

Abre la URL en tu navegador:

```
https://xxxxx.us-east-2.awsapprunner.com
```

⏳ **Espera 1-2 minutos** la primera vez mientras el contenedor inicia completamente.

### Funcionalidades disponibles:

- ✅ Registro de usuarios
- ✅ Inicio de sesión
- ✅ Crear tareas
- ✅ Editar tareas
- ✅ Marcar tareas como completadas
- ✅ Filtrar por estado y prioridad

---

## 📊 Comandos útiles

### Ver todos los outputs

```bash
cd terraform
terraform output
```

### Ver solo la URL de la aplicación

```bash
terraform output apprunner_service_url
```

### Ver estado actual de la infraestructura

```bash
terraform show
```

### Actualizar la aplicación (nueva versión)

Si actualizas el código de la aplicación:

1. Construye nueva imagen:
   ```bash
   docker build -t adriangc22/todoing:latest .
   ```

2. Sube a ECR:
   ```bash
   cd scripts
   ./push-to-ecr.sh
   ```

3. Actualiza App Runner:
   ```bash
   cd ../terraform
   terraform apply -auto-approve
   ```

### Ver logs en AWS Console

1. Ve a [AWS App Runner Console](https://console.aws.amazon.com/apprunner/)
2. Selecciona tu servicio `todoing-service`
3. Tab **"Logs"** para ver logs en tiempo real

---

## 🗑️ Limpieza de recursos

Para eliminar toda la infraestructura creada:

```bash
cd terraform
terraform destroy
```

Escribe `yes` cuando pregunte.

Esto eliminará:
- ✅ Servicio App Runner
- ✅ Repositorio ECR (con todas las imágenes)
- ✅ Roles IAM
- ✅ Policies

**⚠️ Nota:** MongoDB Atlas NO se eliminará automáticamente. Debes eliminarlo manualmente desde su consola si ya no lo necesitas.

---

## 📁 Estructura del proyecto

```
todoing-iac/
├── terraform/
│   ├── provider.tf           # Configuración de providers (AWS)
│   ├── variables.tf          # Definición de variables
│   ├── terraform.tfvars      # Valores de variables (personalizar)
│   ├── ecr.tf               # Repositorio ECR
│   ├── iam.tf               # Roles y policies IAM
│   ├── apprunner.tf         # Servicio App Runner (Fase 2)
│   └── outputs.tf           # Outputs del despliegue
├── scripts/
│   └── push-to-ecr.sh       # Script para subir imagen a ECR
└── README.md                # Esta documentación
```

---

## 🐛 Troubleshooting

### Error: "Unable to locate credentials"

**Problema:** AWS CLI no está configurado.

**Solución:**
```bash
aws configure
```

### Error: "Image not found in ECR"

**Problema:** Intentaste crear App Runner antes de subir la imagen.

**Solución:**
1. Asegúrate de completar FASE 1 primero
2. Ejecuta `./scripts/push-to-ecr.sh`
3. Verifica que la imagen existe:
   ```bash
   aws ecr describe-images --repository-name todoing --region us-east-2
   ```

### Error: "Access Denied" al subir imagen

**Problema:** El usuario de AWS no tiene permisos para ECR.

**Solución:** Asigna la política `AmazonEC2ContainerRegistryFullAccess` a tu usuario de AWS.

### App Runner no inicia correctamente

**Problema:** Variables de entorno incorrectas o MongoDB Atlas inaccesible.

**Solución:**
1. Verifica el connection string en `terraform.tfvars`
2. Confirma que MongoDB Atlas permite acceso desde `0.0.0.0/0`
3. Revisa logs en AWS Console → App Runner → Logs

### Error: "Repository already exists"

**Problema:** El repositorio ECR ya existe de un despliegue anterior.

**Solución:**
```bash
# Opción 1: Importar recurso existente
terraform import aws_ecr_repository.app todoing

# Opción 2: Eliminar repositorio manualmente
aws ecr delete-repository --repository-name todoing --region us-east-2 --force
```

### Error al validar outputs

**Problema:** Los outputs de App Runner están descomentados en FASE 1.

**Solución:** En FASE 1, esos outputs deben estar comentados. Solo se descomientan en FASE 2 después de renombrar `apprunner.tf.disabled` a `apprunner.tf`.

---

## 📚 Referencias

- [AWS App Runner Documentation](https://docs.aws.amazon.com/apprunner/)
- [AWS ECR Documentation](https://docs.aws.amazon.com/ecr/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [MongoDB Atlas Documentation](https://www.mongodb.com/docs/atlas/)
- [Aplicación ToDoing (código fuente)](https://github.com/EdgarAntonioTorres/Dooing)

---

## 👥 Autores

**Proyecto Integrador - IaC y Seguridad**

- **Gerardo Martínez Puente** - Líder de Desarrollo y Contenerización
- **Adrián Alejandro Gaspar Corona** - Ingeniero de DevOps y Despliegue
- **Uriel Alejandro Hernández Hernández** - Especialista en QA y CI

---

## 📄 Licencia

Este proyecto es parte de un trabajo académico para el curso de IaC y Seguridad.

---

## 🎯 Resumen rápido

```bash
# FASE 1: Crear ECR y subir imagen
cd terraform
terraform init
terraform apply                    # Con apprunner.tf.disabled
cd ../scripts && ./push-to-ecr.sh

# FASE 2: Crear App Runner
cd ../terraform
mv apprunner.tf.disabled apprunner.tf
# Descomentar outputs en outputs.tf
terraform apply

# Acceder a la app
terraform output apprunner_service_url
```