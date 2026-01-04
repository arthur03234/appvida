# AppVida - AWS Infrastructure

Infraestrutura AWS para o projeto AppVida usando Terraform.

## Arquitetura

```
                    Internet
                       |
                       v
              Application Load Balancer
                       |
         +-------------+-------------+
         |                           |
         v                           v
    API Gateway                  Frontend
    (ECS Fargate)              (ECS Fargate)
         |
    +----+----+
    |         |
    v         v
  Auth     User
 Service  Service
(Fargate)(Fargate)
    |         |
    +---------+
         |
         v
   MongoDB Atlas
```

## Componentes

### Networking
- **VPC** - Virtual Private Cloud em sa-east-1
- **Subnets** - 3 subnets públicas + 3 privadas (multi-AZ)
- **NAT Gateway** - Para acesso à internet das subnets privadas
- **Internet Gateway** - Para acesso externo

### Compute
- **ECS Cluster** - Cluster Fargate para containers
- **ECS Services** - Um serviço para cada microsserviço
- **ECS Tasks** - Definições de tarefas para cada container

### Load Balancing
- **Application Load Balancer** - Balanceador de carga
- **Target Groups** - Um para API Gateway, outro para Frontend
- **Listeners** - Roteamento HTTP (80)

### Container Registry
- **ECR Repositories** - Um repositório para cada serviço
  - appvida/api-gateway
  - appvida/auth-service
  - appvida/user-service
  - appvida/frontend

### Security
- **Security Groups** - Grupos de segurança para ALB e ECS
- **IAM Roles** - Roles para execução de tarefas ECS
- **IAM Policies** - Políticas para acesso a ECR e CloudWatch

### Monitoring
- **CloudWatch Logs** - Logs centralizados
- **CloudWatch Metrics** - Métricas de container
- **Container Insights** - Insights de performance

## Pré-requisitos

1. **AWS CLI** instalado e configurado
   ```bash
   aws configure
   ```

2. **Terraform** >= 1.0
   ```bash
   brew install terraform  # macOS
   # ou
   sudo apt-get install terraform  # Linux
   ```

3. **Docker** para build de imagens

4. **Git** para versionamento

## Setup Inicial

### 1. Executar Script de Setup

```bash
cd infrastructure/scripts
chmod +x setup-aws.sh
./setup-aws.sh
```

Este script irá:
- Verificar pré-requisitos
- Criar bucket S3 para Terraform state
- Inicializar Terraform

### 2. Configurar Variáveis

Copie o arquivo de exemplo:
```bash
cd ../terraform
cp terraform.tfvars.example terraform.tfvars
```

Edite `terraform.tfvars` com suas configurações.

### 3. Definir Variáveis Sensíveis

```bash
export TF_VAR_mongodb_uri="mongodb+srv://..."
export TF_VAR_jwt_secret="your-super-secret-key"
```

### 4. Planejar Infraestrutura

```bash
terraform plan
```

Revise as mudanças que serão aplicadas.

### 5. Aplicar Infraestrutura

```bash
terraform apply
```

Digite `yes` para confirmar.

Tempo estimado: 10-15 minutos.

## Deploy de Aplicações

### Build e Push de Imagens Docker

```bash
cd infrastructure/scripts
chmod +x deploy.sh
./deploy.sh
```

Este script irá:
1. Fazer login no ECR
2. Buildar imagens Docker de todos os serviços
3. Fazer push para ECR
4. Tagear com `latest` e commit hash

### Atualizar Serviços ECS

Após push das imagens:

```bash
# Forçar deployment de todos os serviços
aws ecs update-service --cluster appvida-cluster --service api-gateway --force-new-deployment --region sa-east-1
aws ecs update-service --cluster appvida-cluster --service auth-service --force-new-deployment --region sa-east-1
aws ecs update-service --cluster appvida-cluster --service user-service --force-new-deployment --region sa-east-1
aws ecs update-service --cluster appvida-cluster --service frontend --force-new-deployment --region sa-east-1
```

## Outputs Importantes

Após `terraform apply`, você receberá:

```
alb_url = "http://appvida-alb-123456789.sa-east-1.elb.amazonaws.com"
ecr_api_gateway_repository_url = "123456789.dkr.ecr.sa-east-1.amazonaws.com/appvida/api-gateway"
...
```

### Acessar Aplicação

- **Frontend**: `http://<alb_url>`
- **API**: `http://<alb_url>/api`
- **Health Check**: `http://<alb_url>/api/health`

## Monitoramento

### CloudWatch Logs

```bash
# Ver logs do API Gateway
aws logs tail /ecs/appvida --follow --filter-pattern "api-gateway"

# Ver logs de todos os serviços
aws logs tail /ecs/appvida --follow
```

### Métricas ECS

Acesse o Console AWS:
1. ECS → Clusters → appvida-cluster
2. Visualize métricas de CPU, memória, rede

## Custos Estimados

**Ambiente de Produção** (estimativa mensal):
- ECS Fargate (4 serviços, 2 tasks cada): ~$120
- Application Load Balancer: ~$20
- NAT Gateway (3 AZs): ~$100
- CloudWatch Logs: ~$5
- Data Transfer: ~$10

**Total**: ~$255/mês

**Ambiente de Desenvolvimento** (single NAT, 1 task por serviço):
**Total**: ~$80/mês

## Scaling

### Auto Scaling (a ser implementado)

```hcl
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 10
  min_capacity       = 2
  resource_id        = "service/appvida-cluster/api-gateway"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}
```

## Troubleshooting

### Tasks não iniciam

1. Verificar logs do ECS:
   ```bash
   aws ecs describe-tasks --cluster appvida-cluster --tasks <task-id>
   ```

2. Verificar logs do CloudWatch

3. Verificar Security Groups

### ALB Health Check falha

1. Verificar endpoint de health check
2. Verificar Security Groups
3. Verificar logs da aplicação

## Destruir Infraestrutura

**⚠️ ATENÇÃO: Esta ação é irreversível!**

```bash
cd infrastructure/scripts
chmod +x destroy.sh
./destroy.sh
```

Ou manualmente:

```bash
cd infrastructure/terraform
terraform destroy
```

## Estrutura de Arquivos

```
infrastructure/
├── terraform/
│   ├── main.tf              # Provider e backend
│   ├── variables.tf         # Variáveis
│   ├── outputs.tf           # Outputs
│   ├── vpc.tf              # VPC e networking
│   ├── security-groups.tf  # Security groups
│   ├── ecr.tf              # Container registry
│   ├── iam.tf              # IAM roles e policies
│   ├── ecs.tf              # ECS cluster
│   ├── alb.tf              # Load balancer
│   ├── cloudwatch.tf       # Logs e métricas
│   └── terraform.tfvars    # Valores das variáveis
└── scripts/
    ├── setup-aws.sh        # Setup inicial
    ├── deploy.sh           # Deploy de imagens
    └── destroy.sh          # Destruir infraestrutura
```

## Segurança

- ✅ Tráfego entre containers em rede privada
- ✅ Acesso MongoDB via VPC peering ou IP whitelist
- ✅ Secrets gerenciados via variáveis de ambiente
- ✅ IAM roles com least privilege
- ✅ Security groups restritivos
- ✅ Logs centralizados

## Próximos Passos

- [ ] Adicionar HTTPS com Certificate Manager
- [ ] Implementar Auto Scaling
- [ ] Configurar CloudFront para frontend
- [ ] Adicionar WAF
- [ ] Implementar CI/CD com GitHub Actions
- [ ] Configurar Route53 para domínio customizado
- [ ] Adicionar Redis para cache
- [ ] Implementar Circuit Breaker
