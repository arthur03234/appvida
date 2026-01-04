# Deploy Parcial - AppVida

## Frontend + API Gateway

Vamos fazer deploy do que já está pronto enquanto implementamos os outros serviços!

## O que vamos fazer?

✅ **Frontend** (Next.js) → AWS Amplify  
✅ **API Gateway** (NestJS) → AWS App Runner  
⏳ Auth Service - Implementar depois  
⏳ User Service - Implementar depois  

---

## PARTE 1: Deploy do API Gateway

### Passo 1: Acessar AWS App Runner

🔗 Abra: https://sa-east-1.console.aws.amazon.com/apprunner/home?region=sa-east-1#/services

### Passo 2: Criar Serviço

1. Clique no botão **"Create service"** (laranja)

### Passo 3: Configurar Source

**Repository type:**
- ☑️ Selecione: **"Source code repository"**

**Connect to GitHub (primeira vez):**
- Clique em **"Add new"**
- Uma janela do GitHub vai abrir
- Autorize **AWS Connector for GitHub**
- Selecione o repositório: **arthur03234/appvida**
- Clique em **"Install & Authorize"**

**Repository:**
- Repository: `arthur03234/appvida`
- Branch: `main`

**Deployment trigger:**
- ☑️ **Automatic** (deploy a cada push)

### Passo 4: Configurar Build

**Configuration file:**
- ☑️ **Use a configuration file**
- Configuration file path: `infrastructure/app-runner/api-gateway/apprunner.yaml`

Clique em **"Next"**

### Passo 5: Configurar Service

**Service name:**
```
appvida-api-gateway
```

**Virtual CPU & memory:**
- CPU: **1 vCPU**
- Memory: **2 GB**

**Environment variables:**

Clique em **"Add environment variable"** para cada uma:

| Name | Value | Type |
|------|-------|------|
| `NODE_ENV` | `production` | Plaintext |
| `PORT` | `3000` | Plaintext |
| `JWT_SECRET` | `seu-secret-key-aqui` | Secret |
| `AUTH_SERVICE_URL` | `http://localhost:3001` | Plaintext |
| `USER_SERVICE_URL` | `http://localhost:3002` | Plaintext |

**⚠️ Importante:**
- Para `JWT_SECRET`, use um secret forte (ex: `appvida-jwt-2024-super-secret`)
- URLs dos services ficarão como localhost por enquanto (vamos atualizar depois)

**Auto scaling:**
- Min instances: **1**
- Max instances: **5**
- Max concurrency: **100**

**Health check:**
- Protocol: **HTTP**
- Path: `/api/health`
- Interval: **10 seconds**
- Timeout: **5 seconds**
- Healthy threshold: **1**
- Unhealthy threshold: **5**

Clique em **"Next"**

### Passo 6: Review e Create

- Revise todas as configurações
- Clique em **"Create & deploy"**

### Passo 7: Aguardar Deploy

⏱️ Vai levar **5-8 minutos**

Você verá:
1. "Creating service" ⏳
2. "Building" ⏳
3. "Deploying" ⏳
4. "Running" ✅

### Passo 8: Copiar URL

Quando status = **"Running"**:

1. Copie a **"Default domain"**
   - Será algo como: `https://xxxxx.sa-east-1.awsapprunner.com`
2. **GUARDE ESSA URL** - vamos usar no Amplify!

### Passo 9: Testar API Gateway

Abra no navegador:
```
https://xxxxx.sa-east-1.awsapprunner.com/api/health
```

Deve retornar:
```json
{
  "status": "ok",
  "timestamp": "2024-01-04T20:00:00.000Z",
  "uptime": 123.456,
  "memory": {...}
}
```

✅ **API Gateway está rodando!**

---

## PARTE 2: Deploy do Frontend

### Passo 1: Acessar AWS Amplify

🔗 Abra: https://sa-east-1.console.aws.amazon.com/amplify/home?region=sa-east-1#/

### Passo 2: Criar App

1. Clique em **"Create new app"**
2. Selecione **"Host web app"**

### Passo 3: Conectar GitHub

**Select your provider:**
- Selecione **GitHub**
- Clique em **"Continue"**

**Authorize GitHub:**
- Uma janela do GitHub vai abrir
- Clique em **"Authorize aws-amplify-console"**

**Select repository:**
- Repository: `arthur03234/appvida`
- Branch: `main`
- Clique em **"Next"**

### Passo 4: Configurar Build Settings

**App name:**
```
appvida-frontend
```

**Environment:**
- Deixe em branco ou use: `production`

**Build and test settings:**
- ☑️ Amplify detectará automaticamente o `amplify.yml`
- Ou cole manualmente:

```yaml
version: 1
frontend:
  phases:
    preBuild:
      commands:
        - cd frontend
        - npm ci
    build:
      commands:
        - npm run build
  artifacts:
    baseDirectory: frontend/.next
    files:
      - '**/*'
  cache:
    paths:
      - frontend/node_modules/**/*
      - frontend/.next/cache/**/*
```

**Advanced settings → Environment variables:**

Clique em **"Add environment variable"**:

| Variable | Value |
|----------|-------|
| `NEXT_PUBLIC_API_URL` | `https://xxxxx.sa-east-1.awsapprunner.com` |

**⚠️ USE A URL DO SEU API GATEWAY** (da Parte 1, Passo 8)

Clique em **"Next"**

### Passo 5: Review e Deploy

- Revise as configurações
- Clique em **"Save and deploy"**

### Passo 6: Aguardar Build

⏱️ Vai levar **5-10 minutos**

Você verá 4 etapas:
1. ✅ Provision
2. ⏳ Build (mais demorado)
3. ⏳ Deploy
4. ⏳ Verify

### Passo 7: Acessar Site

Quando todas as etapas estiverem ✅:

1. Copie a URL do domínio
   - Será algo como: `https://main.xxxxx.amplifyapp.com`
2. Abra no navegador

### Passo 8: Testar Frontend

Você deve ver:
- ✅ Homepage do AppVida
- ✅ Botões "Entrar" e "Criar Conta"
- ✅ Design bonito com Tailwind

**Clique em "Entrar":**
- ✅ Formulário de login aparece

**Teste login (vai falhar, mas é esperado):**
- Email: `teste@email.com`
- Senha: `123456`
- Clique "Entrar"
- ❌ Erro: "Service unavailable" 
  - **NORMAL!** Auth Service ainda não existe

✅ **Frontend está rodando!**

---

## PARTE 3: Verificar Custos

### App Runner (API Gateway)

🔗 https://sa-east-1.console.aws.amazon.com/billing/home?region=sa-east-1#/bills

**Estimativa:**
- Provisioned compute: ~$5/mês
- Active requests: ~$1-2/mês
- **Total: ~$6-7/mês**

### Amplify (Frontend)

**Free tier:**
- ✅ 1000 build minutes/mês grátis
- ✅ 15GB armazenamento grátis
- ✅ 15GB data transfer/mês grátis

**Custo: $0** (se ficar no free tier)

### Total Atual: ~$6-7/mês 🎉

---

## PARTE 4: URLs Importantes

Anote suas URLs:

```
API Gateway:  https://_____.sa-east-1.awsapprunner.com
Frontend:     https://main._____.amplifyapp.com

Health Check: https://_____.sa-east-1.awsapprunner.com/api/health
```

---

## O que funciona agora?

✅ **Frontend**
- Homepage
- Páginas de Login/Registro
- Design completo

✅ **API Gateway**
- Health check (`/api/health`)
- CORS configurado
- Rate limiting ativo

❌ **Não funciona ainda**
- Login/Registro (precisa Auth Service)
- Dashboard (precisa User Service)
- Listagem de usuários (precisa User Service)

---

## Próximos Passos

Para ter app 100% funcional:

1. **Implementar Auth Service** (#4)
   - Login com JWT
   - Registro de usuários
   - Validação de tokens

2. **Implementar User Service** (#5)
   - CRUD de usuários
   - Integração com MongoDB

3. **Criar mais 2 serviços no App Runner**
   - Auth Service
   - User Service

4. **Atualizar variáveis do API Gateway**
   - AUTH_SERVICE_URL
   - USER_SERVICE_URL

---

## Troubleshooting

### API Gateway não inicia

**Verificar logs:**
1. App Runner → Service → Logs
2. Procure por erros

**Comum:**
- Build falhou: Verifique `package.json` em `services/api-gateway`
- Port errada: Deve ser 3000
- Variáveis erradas: Revise environment variables

### Frontend build falha

**Verificar logs:**
1. Amplify → App → Build
2. Clique no build com erro
3. Veja os logs

**Comum:**
- `amplify.yml` não encontrado: Está na raiz do repo
- Erro no build: Tente localmente `cd frontend && npm run build`
- Variável `NEXT_PUBLIC_API_URL` errada

### Frontend não conecta na API

**Verificar:**
1. `NEXT_PUBLIC_API_URL` no Amplify está correto?
2. URL termina com `/api`? REMOVA `/api`, só a base URL!
3. API Gateway está rodando? Teste `/api/health`
4. CORS configurado? Deve estar (já está no código)

---

## Auto Deploy

✅ **Configurado!**

Agora, quando você fizer:

```bash
git add .
git commit -m "update: nova feature"
git push origin main
```

**App Runner** e **Amplify** fazem deploy automático! 🚀

- App Runner: ~5 minutos
- Amplify: ~8 minutos

Você pode ver o progresso nos respectivos consoles.

---

## Parabéns! 🎉

Você tem agora:
- ✅ Frontend rodando na AWS
- ✅ API Gateway rodando na AWS
- ✅ Deploy automático configurado
- ✅ HTTPS grátis
- ✅ Custo baixíssimo (~$7/mês)

Agora é só implementar Auth e User Services para ter o app completo!
