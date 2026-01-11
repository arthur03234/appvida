# 🚀 Deploy Rápido - 3 Passos

## ✅ O que já está pronto

- ✅ 4 repositórios ECR criados
- ✅ Usuário IAM criado com permissões
- ✅ Role IAM para App Runner criado
- ✅ Workflows GitHub Actions configurados
- ✅ Dockerfiles prontos

## 📋 O que você precisa fazer

### 1️⃣ Adicionar Secrets no GitHub (2 minutos)

Acesse: https://github.com/arthur03234/appvida/settings/secrets/actions

Adicione estes 7 secrets:

| Nome | Descrição |
|------|-----------|
| `AWS_ACCESS_KEY_ID` | Sua AWS Access Key (IAM com permissões ECR) |
| `AWS_SECRET_ACCESS_KEY` | Sua AWS Secret Key |
| `APP_RUNNER_ROLE_ARN` | ARN do role IAM para App Runner |
| `MONGODB_URI` | String de conexão MongoDB Atlas |
| `JWT_SECRET` | Gere com: `openssl rand -base64 32` |
| `AUTH_SERVICE_URL` | `http://localhost:3001` |
| `USER_SERVICE_URL` | `http://localhost:3002` |

### 2️⃣ Fazer Commit e Push

```bash
git add .
git commit -m "Setup deployment with GitHub Actions"
git push origin main
```

### 3️⃣ Acompanhar Deploy

Abra: https://github.com/arthur03234/appvida/actions

Aguarde 10-15 minutos (primeira vez) ou 5-8 minutos (próximas vezes).

No final dos logs você verá a **App Runner URL** do seu serviço! 🎉

---

## 🔍 Como funciona?

- **GitHub Actions** compila e cria imagem Docker
- **ECR** armazena as imagens
- **App Runner** roda os containers automaticamente

**SEM OAUTH!** Tudo via GitHub Actions.

---

## ❓ Dúvidas?

Veja documentação completa: [DEPLOY-GITHUB-ACTIONS.md](./DEPLOY-GITHUB-ACTIONS.md)
