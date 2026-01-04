#!/bin/bash

# AppVida - Deploy Automatizado com AWS MCP
# Este script automatiza o máximo possível via AWS CLI

set -e

echo "🤖 AppVida - Deploy Automatizado com AWS CLI"
echo "============================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Configuration
REGION="us-east-1"  # App Runner disponível aqui
PROJECT="appvida"
GITHUB_REPO="arthur03234/appvida"
GITHUB_BRANCH="main"

echo -e "${BLUE}📋 Configuração:${NC}"
echo "   Região: $REGION"
echo "   Projeto: $PROJECT"
echo "   GitHub: $GITHUB_REPO"
echo ""

# Get AWS Account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)

if [ -z "$AWS_ACCOUNT_ID" ]; then
    echo -e "${RED}❌ AWS CLI não configurado${NC}"
    echo "Execute: aws configure"
    exit 1
fi

echo -e "${GREEN}✅ AWS Account: ${AWS_ACCOUNT_ID}${NC}"
echo ""

# Step 1: Create IAM Role for App Runner
echo -e "${BLUE}1️⃣ Criando IAM Role para App Runner...${NC}"

ROLE_NAME="${PROJECT}-apprunner-build-role"

# Check if role exists
if aws iam get-role --role-name "$ROLE_NAME" &> /dev/null; then
    echo -e "${YELLOW}⚠️  Role já existe: ${ROLE_NAME}${NC}"
else
    # Create trust policy
    cat > /tmp/apprunner-trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Service": "build.apprunner.amazonaws.com"
    },
    "Action": "sts:AssumeRole"
  }]
}
EOF

    aws iam create-role \
        --role-name "$ROLE_NAME" \
        --assume-role-policy-document file:///tmp/apprunner-trust-policy.json \
        --description "Role for App Runner to build from source" \
        --region "$REGION" > /dev/null
    
    # Attach managed policy
    aws iam attach-role-policy \
        --role-name "$ROLE_NAME" \
        --policy-arn arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess \
        --region "$REGION"
    
    echo -e "${GREEN}✅ IAM Role criado: ${ROLE_NAME}${NC}"
fi

ROLE_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ROLE_NAME}"
echo -e "   Role ARN: ${ROLE_ARN}"
echo ""

# Step 2: Generate direct links for console
echo -e "${MAGENTA}2️⃣ Próximos Passos (requerem interação manual):${NC}"
echo ""
echo -e "${YELLOW}⚠️  Por segurança, conexões GitHub precisam ser feitas manualmente${NC}"
echo ""

echo -e "${BLUE}==== DEPLOY DO API GATEWAY ====${NC}"
echo ""
echo "1️⃣ Abra este link no navegador:"
echo ""
echo -e "   ${GREEN}https://console.aws.amazon.com/apprunner/home?region=${REGION}#/create${NC}"
echo ""
echo "2️⃣ Configure o serviço:"
echo ""
echo "   Repository type: Source code repository"
echo "   Connect to GitHub: [Clique 'Add new' e autorize]"
echo "   Repository: ${GITHUB_REPO}"
echo "   Branch: ${GITHUB_BRANCH}"
echo "   Configuration: Use a configuration file"
echo "   Config path: infrastructure/app-runner/api-gateway/apprunner.yaml"
echo ""
echo "   Service name: ${PROJECT}-api-gateway"
echo "   CPU: 1 vCPU"
echo "   Memory: 2 GB"
echo ""
echo "   Environment variables:"
echo "     NODE_ENV=production"
echo "     PORT=3000"
echo "     JWT_SECRET=appvida-jwt-secret-2024"
echo "     AUTH_SERVICE_URL=http://localhost:3001"
echo "     USER_SERVICE_URL=http://localhost:3002"
echo ""
echo "   Build role: ${ROLE_ARN}"
echo ""

echo -e "${BLUE}==== DEPLOY DO FRONTEND ====${NC}"
echo ""
echo "1️⃣ Abra este link no navegador:"
echo ""
echo -e "   ${GREEN}https://console.aws.amazon.com/amplify/home?region=${REGION}#/create${NC}"
echo ""
echo "2️⃣ Configure o app:"
echo ""
echo "   Provider: GitHub"
echo "   Repository: ${GITHUB_REPO}"
echo "   Branch: ${GITHUB_BRANCH}"
echo "   App name: ${PROJECT}-frontend"
echo ""
echo "   Build settings: Detectado automaticamente (amplify.yml)"
echo ""
echo "   Environment variable:"
echo "     NEXT_PUBLIC_API_URL=<URL_DO_API_GATEWAY>"
echo "   (Adicione depois de criar o API Gateway)"
echo ""

echo -e "${BLUE}==== COMANDOS ALTERNATIVOS (após conectar GitHub) ====${NC}"
echo ""
echo "Se você preferir CLI após conectar GitHub manualmente:"
echo ""
echo "# 1. Liste conexões para pegar o ARN"
echo "aws apprunner list-connections --region ${REGION}"
echo ""
echo "# 2. Crie o serviço (substitua CONNECTION_ARN)"
echo "aws apprunner create-service \\"
echo "  --service-name ${PROJECT}-api-gateway \\"
echo "  --source-configuration 'SourceType=GITHUB,...' \\"
echo "  --region ${REGION}"
echo ""

echo -e "${GREEN}=============================================${NC}"
echo -e "${GREEN}✅ Setup automatizado concluído!${NC}"
echo ""
echo -e "${BLUE}📝 Recursos criados:${NC}"
echo "   ✅ IAM Role: ${ROLE_NAME}"
echo "   ✅ Links diretos gerados"
echo ""
echo -e "${YELLOW}👆 Siga os passos acima para completar o deploy${NC}"
echo ""
