# Deploy AppVida com GitHub Actions + ECR + App Runner

Esta é a **solução sem OAuth** que contorna o problema de conexão GitHub-AWS.

## 🎯 Como Funciona

1. **GitHub Actions** compila a aplicação e cria imagens Docker
2. **Push para ECR** (Amazon Elastic Container Registry)
3. **App Runner** automaticamente atualiza os serviços quando nova imagem é detectada

## 📋 Pré-requisitos

- Repositório GitHub: `arthur03234/appvida`
- Conta AWS: `058264284595`
- Credenciais IAM criadas: ✅

## 🔐 Passo 1: Configurar GitHub Secrets

Acesse: https://github.com/arthur03234/appvida/settings/secrets/actions

Clique em **"New repository secret"** e adicione cada um destes secrets:

### Secrets AWS
| Nome | Descrição |
|------|-----------|
| `AWS_ACCESS_KEY_ID` | Access Key do usuário IAM com permissões ECR |
| `AWS_SECRET_ACCESS_KEY` | Secret Key do usuário IAM |
| `APP_RUNNER_ROLE_ARN` | ARN do role IAM para App Runner |

### Secrets de Aplicação
| Nome | Descrição |
|------|-----------|
| `JWT_SECRET` | Segredo para tokens JWT (gerar com: `openssl rand -base64 32`) |
| `MONGODB_URI` | String de conexão do MongoDB Atlas |
| `AUTH_SERVICE_URL` | URL do serviço de autenticação (atualizar após deploy) |
| `USER_SERVICE_URL` | URL do serviço de usuários (atualizar após deploy) |

**Gerar JWT_SECRET:**
```bash
openssl rand -base64 32
```

## 🚀 Passo 2: Fazer Deploy

### Opção A: Deploy via GitHub (Recomendado)

Simplesmente faça commit e push:

```bash
git add .
git commit -m "Setup GitHub Actions deployment"
git push origin main
```

Os workflows serão acionados automaticamente! Acompanhe em:
https://github.com/arthur03234/appvida/actions

### Opção B: Deploy Manual (Workflow Dispatch)

1. Acesse: https://github.com/arthur03234/appvida/actions
2. Selecione o workflow desejado:
   - "Deploy API Gateway to App Runner"
   - "Deploy Frontend to App Runner"
3. Clique em **"Run workflow"**
4. Selecione branch `main`
5. Clique em **"Run workflow"**

## 📦 Repositórios ECR Criados

| Serviço | Repositório ECR |
|---------|-----------------|
| API Gateway | `058264284595.dkr.ecr.us-east-1.amazonaws.com/appvida-api-gateway` |
| Auth Service | `058264284595.dkr.ecr.us-east-1.amazonaws.com/appvida-auth-service` |
| User Service | `058264284595.dkr.ecr.us-east-1.amazonaws.com/appvida-user-service` |
| Frontend | `058264284595.dkr.ecr.us-east-1.amazonaws.com/appvida-frontend` |

## 🔄 O Que Acontece no Workflow

### Deploy API Gateway (`deploy-api-gateway.yml`)

1. **Checkout** do código
2. **Autentica** na AWS usando secrets
3. **Login** no ECR
4. **Build** da imagem Docker em `services/api-gateway`
5. **Push** para ECR com tags `latest` e `{commit-sha}`
6. **Deploy** no App Runner (cria ou atualiza o serviço)
7. **Aguarda** estabilidade do serviço (até 10 minutos)
8. **Exibe** URL do serviço

### Deploy Frontend (`deploy-frontend.yml`)

Mesmo processo, mas para o frontend Next.js na porta 3003.

## 🏃 Passo 3: Verificar Deploy

Após o workflow completar (5-15 minutos):

1. Acesse a aba **Actions** no GitHub
2. Veja os logs do workflow
3. No final dos logs, encontre a **App Runner URL**
4. Teste acessando a URL fornecida

## 🔧 Troubleshooting

### Workflow falha no Login ECR
- Verifique se os secrets `AWS_ACCESS_KEY_ID` e `AWS_SECRET_ACCESS_KEY` estão corretos
- Confirme que o usuário IAM tem a policy `AmazonEC2ContainerRegistryPowerUser`

### Workflow falha no Deploy App Runner
- Verifique se o secret `APP_RUNNER_ROLE_ARN` está correto
- Confirme que o role tem a policy `AWSAppRunnerServicePolicyForECRAccess`
- Na primeira execução, pode levar mais tempo (criação do serviço)

### Serviço App Runner não inicia
- Verifique os logs no Console AWS: https://console.aws.amazon.com/apprunner/home?region=us-east-1#/services
- Confirme que as variáveis de ambiente estão configuradas
- Verifique se a porta está correta (3000 para API, 3003 para frontend)

### Build falha
- Verifique os logs do workflow no GitHub Actions
- Confirme que o Dockerfile está correto
- Teste o build localmente: `docker build -t test .`

## 🎁 Vantagens desta Abordagem

✅ **Sem OAuth** - Não precisa conectar GitHub com AWS manualmente
✅ **Automático** - Deploy acontece a cada push
✅ **Versionado** - Cada imagem é tagueada com commit SHA
✅ **Rastreável** - Logs completos no GitHub Actions
✅ **Rollback fácil** - Pode reverter para imagem anterior
✅ **Custo baixo** - ~$12-20/mês para app simples

## 📊 Custos Estimados

| Serviço | Custo/mês |
|---------|-----------|
| App Runner (API Gateway) | ~$5-8 |
| App Runner (Frontend) | ~$5-8 |
| ECR Storage (primeiros 500MB) | Grátis |
| MongoDB Atlas M0 | Grátis |
| **Total** | **~$10-16/mês** |

## 🔄 Próximos Passos

1. ✅ Configurar GitHub Secrets
2. ✅ Fazer primeiro deploy via push
3. ⏳ Implementar Auth Service
4. ⏳ Implementar User Service
5. ⏳ Atualizar variáveis de ambiente com URLs reais dos serviços
6. ⏳ Configurar domínio customizado (opcional)

## 📝 Notas Importantes

- **Primeira execução**: Pode levar 10-15 minutos (criação de serviços)
- **Execuções seguintes**: 5-8 minutos (apenas atualização)
- **Região**: us-east-1 (App Runner não disponível em sa-east-1)
- **Logs**: Disponíveis no CloudWatch e no console do App Runner
- **Monitoramento**: Métricas disponíveis no App Runner console

## 🔗 Links Úteis

- **GitHub Actions**: https://github.com/arthur03234/appvida/actions
- **App Runner Console**: https://console.aws.amazon.com/apprunner/home?region=us-east-1#/services
- **ECR Console**: https://console.aws.amazon.com/ecr/repositories?region=us-east-1
- **CloudWatch Logs**: https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:log-groups

---

**Pronto!** Agora você tem deploy automático sem precisar de conexão OAuth! 🎉
