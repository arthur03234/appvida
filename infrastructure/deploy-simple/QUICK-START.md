# Deploy Rápido - AppVida

## Método 1: Console AWS (1 Clique) ⭐ RECOMENDADO

### Parte 1: API Gateway

🔗 **Clique aqui**: https://console.aws.amazon.com/apprunner/home?region=us-east-1#/create

**Configuração:**

```
Repository type: Source code repository

✅ Connect GitHub:
   - Clique "Add new"
   - Autorize AWS App Runner
   - Selecione: arthur03234/appvida

Repository: arthur03234/appvida
Branch: main

Configuration: Use a configuration file
Path: infrastructure/app-runner/api-gateway/apprunner.yaml

Service name: appvida-api-gateway
CPU: 1 vCPU
Memory: 2 GB

Environment variables:
  NODE_ENV = production
  PORT = 3000
  JWT_SECRET = appvida-secret-2024
  AUTH_SERVICE_URL = http://localhost:3001
  USER_SERVICE_URL = http://localhost:3002
```

**Clique "Create & deploy"**

⏱️ Aguarde 5-8 minutos

✅ Copie a URL quando ficar "Running"

---

### Parte 2: Frontend

🔗 **Clique aqui**: https://console.aws.amazon.com/amplify/home?region=us-east-1#/create

**Configuração:**

```
Provider: GitHub
Repository: arthur03234/appvida
Branch: main

App name: appvida-frontend

Build settings: Auto-detectado (amplify.yml)

Environment variable:
  NEXT_PUBLIC_API_URL = <URL_DO_API_GATEWAY>
```

**Clique "Save and deploy"**

⏱️ Aguarde 8-10 minutos

✅ Acesse seu site!

---

## Método 2: Script Automatizado (AWS CLI)

### Pré-requisitos

```bash
# AWS CLI configurado
aws configure

# Verificar credenciais
aws sts get-caller-identity
```

### Executar Script

```bash
cd infrastructure/deploy-simple
chmod +x deploy-automated.sh
./deploy-automated.sh
```

O script vai:
1. ✅ Criar IAM roles automaticamente
2. 🔗 Gerar links diretos para console
3. 📝 Fornecer comandos prontos

### Depois do Script

Siga os links gerados para:
1. Conectar GitHub (1 clique)
2. Criar serviços (formulários pré-preenchidos)

---

## Método 3: Terraform (Avançado)

Se quiser infraestrutura como código completa:

```bash
cd infrastructure/terraform
terraform init
terraform plan
terraform apply
```

**Custo**: $80+/mês (muito mais caro)  
**Complexidade**: Alta  
**Tempo**: 2+ horas  

⚠️ **Não recomendado para início**

---

## Comparação de Métodos

| Método | Tempo | Custo/mês | Dificuldade |
|---------|-------|------------|-------------|
| Console AWS | 15 min | $6-12 | Fácil |
| Script CLI | 20 min | $6-12 | Médio |
| Terraform | 2+ horas | $80+ | Difícil |

---

## URLs Após Deploy

```
API Gateway:  https://xxxxx.us-east-1.awsapprunner.com
Frontend:     https://main.xxxxx.amplifyapp.com

Health Check: https://xxxxx.us-east-1.awsapprunner.com/api/health
```

---

## Troubleshooting

### Erro ao conectar GitHub

1. Verifique se autorizou AWS App Runner/Amplify no GitHub
2. Tente desconectar e reconectar
3. Use conta pessoal do GitHub (não organization)

### Build falha

1. Verifique logs no console
2. Teste build localmente: `npm install && npm run build`
3. Verifique `package.json` tem scripts corretos

### Serviço não inicia

1. Verifique variáveis de ambiente
2. Verifique logs do CloudWatch
3. Teste health check: `curl <url>/api/health`

---

## Custos Reais

**App Runner** (API Gateway):
- Provisioned: $5/mês
- Requests: $1-2/mês
- **Total: $6-7/mês**

**Amplify** (Frontend):
- Build: Grátis (1000 min/mês)
- Hosting: Grátis (15GB)
- **Total: $0**

**Total Geral: $6-7/mês** 🎉

---

## Próximos Passos

Após deploy parcial:

1. ✅ Frontend funcionando
2. ✅ API Gateway funcionando
3. ⏳ Implementar Auth Service
4. ⏳ Implementar User Service
5. ⏳ Deploy completo

---

## Suporte

Se encontrar problemas:

1. Verifique `DEPLOY-NOW.md` para guia detalhado
2. Verifique `GUIDE.md` para documentação completa
3. Veja logs no console AWS
4. Abra issue no GitHub
