# AppVida - Guia de Deploy Simplificado

## AWS App Runner + Amplify

Solução moderna, simples e barata para deploy do AppVida.

## Custo Estimado

- **AWS App Runner**: ~$12/mês (3 serviços com baixo tráfego)
- **AWS Amplify**: Grátis (até 1000 build minutes/mês)
- **MongoDB Atlas**: Grátis (tier gratuito)

**Total: ~$12/mês** 🎉

## Arquitetura

```
AWS Amplify (Frontend)
      ↓
AWS App Runner (API Gateway)
      ↓
   ┌──┴──┐
Auth   User
Service Service
(App Runner)
   ↓     ↓
MongoDB Atlas
```

## Pré-requisitos

1. ✅ Conta AWS
2. ✅ AWS CLI configurado
3. ✅ Repositório GitHub (já temos)
4. ✅ MongoDB Atlas (já configurado)

## Deploy - Opção 1: Console AWS (Recomendado)

### Passo 1: Conectar GitHub

1. Acesse [AWS App Runner Console](https://console.aws.amazon.com/apprunner/)
2. Clique em **"Create service"**
3. Em **Source**, selecione **"Source code repository"**
4. Clique em **"Add new"** para conectar GitHub
5. Autorize AWS App Runner no GitHub

### Passo 2: Criar API Gateway Service

1. **Repository**: `arthur03234/appvida`
2. **Branch**: `main`
3. **Source directory**: `services/api-gateway`
4. **Runtime**: `Nodejs 20`
5. **Build command**: `npm install && npm run build`
6. **Start command**: `npm run start:prod`
7. **Port**: `3000`

**Variáveis de Ambiente:**
```
NODE_ENV=production
PORT=3000
MONGODB_URI=<sua-connection-string>
JWT_SECRET=<seu-secret>
AUTH_SERVICE_URL=<url-do-auth-service>
USER_SERVICE_URL=<url-do-user-service>
```

### Passo 3: Criar Auth Service

1. **Repository**: `arthur03234/appvida`
2. **Branch**: `main`
3. **Source directory**: `services/auth-service`
4. **Runtime**: `Nodejs 20`
5. **Build command**: `npm install && npm run build`
6. **Start command**: `npm run start:prod`
7. **Port**: `3001`

**Variáveis de Ambiente:**
```
NODE_ENV=production
PORT=3001
MONGODB_URI=<sua-connection-string>
JWT_SECRET=<seu-secret>
```

### Passo 4: Criar User Service

1. **Repository**: `arthur03234/appvida`
2. **Branch**: `main`
3. **Source directory**: `services/user-service`
4. **Runtime**: `Nodejs 20`
5. **Build command**: `npm install && npm run build`
6. **Start command**: `npm run start:prod`
7. **Port**: `3002`

**Variáveis de Ambiente:**
```
NODE_ENV=production
PORT=3002
MONGODB_URI=<sua-connection-string>
```

### Passo 5: Atualizar API Gateway

Depois de criar Auth e User services, volte no API Gateway e atualize as variáveis:

```
AUTH_SERVICE_URL=https://xxx.sa-east-1.awsapprunner.com
USER_SERVICE_URL=https://yyy.sa-east-1.awsapprunner.com
```

### Passo 6: Deploy Frontend no Amplify

1. Acesse [AWS Amplify Console](https://console.aws.amazon.com/amplify/)
2. Clique em **"New app" → "Host web app"**
3. Selecione **GitHub**
4. Autorize e selecione: `arthur03234/appvida`
5. **Branch**: `main`
6. **App root**: `/`
7. Em **Build settings**, use o arquivo `amplify.yml` (já existe no repo)

**Variável de Ambiente:**
```
NEXT_PUBLIC_API_URL=<url-do-api-gateway>
```

Exemplo: `https://api-gateway-xxx.sa-east-1.awsapprunner.com`

### Passo 7: Testar!

1. Acesse a URL do Amplify
2. Teste login/registro
3. Verifique dashboard

## Deploy - Opção 2: AWS CLI (Avançado)

### 1. Executar Script de Setup

```bash
cd infrastructure/deploy-simple
chmod +x setup-app-runner.sh

# Definir variáveis
export MONGODB_URI="mongodb+srv://..."
export JWT_SECRET="your-secret-key"

# Executar
./setup-app-runner.sh
```

### 2. Criar Serviços via CLI

O script fornecerá instruções detalhadas.

## URLs dos Serviços

Após deployment, você terá:

```
Frontend:     https://main.xxxxx.amplifyapp.com
API Gateway:  https://xxxxx.sa-east-1.awsapprunner.com
Auth Service: https://yyyyy.sa-east-1.awsapprunner.com
User Service: https://zzzzz.sa-east-1.awsapprunner.com
```

## Auto Deploy

✅ **App Runner** e **Amplify** fazem deploy automático a cada push no GitHub!

```bash
git add .
git commit -m "update: nova feature"
git push origin main
```

→ Deploy automático acontece em ~5 minutos

## Monitoramento

### App Runner

1. Acesse o serviço no [Console](https://console.aws.amazon.com/apprunner/)
2. Veja **Logs** em tempo real
3. Veja **Metrics** (CPU, Memória, Requests)

### Amplify

1. Acesse o app no [Console](https://console.aws.amazon.com/amplify/)
2. Veja **Build logs**
3. Veja **Access logs**

## Logs via CLI

```bash
# Ver logs do App Runner
aws apprunner list-operations --service-arn <service-arn>

# Ver logs do Amplify
aws amplify get-job --app-id <app-id> --branch-name main --job-id <job-id>
```

## Scaling

### App Runner

- **Auto-scaling**: Automático (0-25 instâncias)
- **Min instances**: 1
- **Max instances**: 25
- **Concurrency**: 100 requests por instância

Para alterar:
1. Vá no serviço
2. **Configuration** → **Edit**
3. Ajuste **Auto scaling**

### Amplify

- Scaling automático
- CDN global (CloudFront)
- Sem limites

## Custos Detalhados

### App Runner (por serviço)

**Baixo tráfego** (< 1000 requests/dia):
- Provisioned: $5/mês
- Requests: ~$1/mês
- **Total por serviço**: ~$6/mês

**3 serviços**: ~$18/mês

### Amplify

**Free tier**:
- Build: 1000 minutos/mês grátis
- Hosting: 15GB armazenamento grátis
- Data transfer: 15GB/mês grátis

**Após free tier**:
- Build: $0.01/minuto
- Hosting: Muito barato

**Estimativa**: Grátis ou ~$2/mês

### Total Real

**Início**: ~$18-20/mês (App Runner + Amplify)
**Com tráfego médio**: ~$25-30/mês

## Domínio Customizado (Opcional)

### Amplify

1. Compre domínio no Route 53 (~$12/ano)
2. No Amplify: **Domain management** → **Add domain**
3. Siga instruções

Resultado: `https://www.appvida.com.br`

### App Runner

1. Crie domínio no Route 53
2. No App Runner: **Custom domains** → **Link domain**
3. Adicione registro CNAME

Resultado: `https://api.appvida.com.br`

## Troubleshooting

### Service não inicia

1. Verifique **Logs** no console
2. Verifique variáveis de ambiente
3. Verifique comandos de build

### Frontend não conecta na API

1. Verifique `NEXT_PUBLIC_API_URL` no Amplify
2. Verifique CORS no API Gateway
3. Teste URL manualmente: `https://<api-url>/api/health`

### Build falha

1. Verifique **Build logs**
2. Teste localmente: `npm install && npm run build`
3. Verifique `package.json`

## Deletar Tudo

### App Runner

```bash
aws apprunner delete-service --service-arn <service-arn>
```

Ou no console: **Delete service**

### Amplify

```bash
aws amplify delete-app --app-id <app-id>
```

Ou no console: **Delete app**

## Comparação: App Runner vs ECS/Fargate

| Feature | App Runner | ECS Fargate (Terraform) |
|---------|------------|-------------------------|
| Setup | 15 minutos | 2+ horas |
| Custo inicial | $18/mês | $80+/mês |
| Complexidade | Baixa | Alta |
| Auto-deploy | ✅ Sim | ❌ Manual |
| Auto-scaling | ✅ Automático | ⚙️ Manual |
| Manutenção | Mínima | Alta |
| Ideal para | Início, MVP | Produção em escala |

## Quando Migrar para ECS?

Considere ECS/Fargate quando:
- Tráfego > 100k requests/dia
- Precisa VPC customizado
- Precisa controle fino de rede
- Múltiplos ambientes (dev/staging/prod)
- Budget > $100/mês

Para AppVida no início, **App Runner é perfeito**! ✅

## Próximos Passos

1. ✅ Deploy no App Runner + Amplify
2. ⏳ Implementar Auth Service
3. ⏳ Implementar User Service
4. ⏳ Testar aplicação
5. ⏳ Adicionar domínio customizado
6. ⏳ Configurar CI/CD com testes
