#!/bin/bash

# AWS App Runner + Amplify Setup Script

set -e

echo "🚀 AppVida - AWS App Runner + Amplify Setup"
echo "============================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
REGION="sa-east-1"
PROJECT="appvida"
GITHUB_REPO="arthur03234/appvida"
GITHUB_BRANCH="main"

echo -e "${BLUE}📋 Configuração:${NC}"
echo "   Região: $REGION"
echo "   Projeto: $PROJECT"
echo "   GitHub: $GITHUB_REPO"
echo ""

# Check AWS CLI
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI não está instalado${NC}"
    exit 1
fi

echo -e "${GREEN}✅ AWS CLI encontrado${NC}"
echo ""

# Get AWS Account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)

if [ -z "$AWS_ACCOUNT_ID" ]; then
    echo -e "${RED}❌ Não foi possível obter AWS Account ID${NC}"
    echo "Por favor, configure suas credenciais AWS:"
    echo "  aws configure"
    exit 1
fi

echo -e "${GREEN}✅ AWS Account ID: ${AWS_ACCOUNT_ID}${NC}"
echo ""

# Check for required environment variables
if [ -z "$MONGODB_URI" ]; then
    echo -e "${YELLOW}⚠️  MONGODB_URI não definido${NC}"
    echo "Por favor, defina a variável de ambiente:"
    echo "  export MONGODB_URI='mongodb+srv://...'"
    exit 1
fi

if [ -z "$JWT_SECRET" ]; then
    echo -e "${YELLOW}⚠️  JWT_SECRET não definido${NC}"
    echo "Por favor, defina a variável de ambiente:"
    echo "  export JWT_SECRET='your-secret-key'"
    exit 1
fi

echo -e "${GREEN}✅ Variáveis de ambiente configuradas${NC}"
echo ""

echo -e "${BLUE}📦 Criando serviços no AWS App Runner...${NC}"
echo ""

# Create IAM role for App Runner
echo "🔐 Criando IAM role para App Runner..."

ROLE_NAME="${PROJECT}-apprunner-role"

# Check if role exists
if aws iam get-role --role-name "$ROLE_NAME" &> /dev/null; then
    echo -e "${YELLOW}⚠️  IAM role já existe${NC}"
else
    # Create trust policy
    cat > /tmp/trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "build.apprunner.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

    aws iam create-role \
        --role-name "$ROLE_NAME" \
        --assume-role-policy-document file:///tmp/trust-policy.json \
        --region "$REGION" > /dev/null
    
    # Attach managed policy for ECR access
    aws iam attach-role-policy \
        --role-name "$ROLE_NAME" \
        --policy-arn arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess \
        --region "$REGION"
    
    echo -e "${GREEN}✅ IAM role criado${NC}"
fi

echo ""
echo -e "${GREEN}✅ Setup inicial concluído!${NC}"
echo ""
echo -e "${BLUE}📝 Próximos passos:${NC}"
echo ""
echo "1. Conecte seu repositório GitHub ao AWS App Runner:"
echo "   - Acesse: https://console.aws.amazon.com/apprunner/"
echo "   - Clique em 'Create service'"
echo "   - Selecione 'Source code repository'"
echo "   - Conecte o GitHub e selecione: $GITHUB_REPO"
echo ""
echo "2. Configure 3 serviços App Runner:"
echo "   - API Gateway (services/api-gateway)"
echo "   - Auth Service (services/auth-service)"
echo "   - User Service (services/user-service)"
echo ""
echo "3. Para cada serviço, adicione as variáveis de ambiente:"
echo "   - MONGODB_URI"
echo "   - JWT_SECRET"
echo "   - AUTH_SERVICE_URL (para API Gateway)"
echo "   - USER_SERVICE_URL (para API Gateway)"
echo ""
echo "4. Configure o frontend no Amplify:"
echo "   - Acesse: https://console.aws.amazon.com/amplify/"
echo "   - Conecte o repositório: $GITHUB_REPO"
echo "   - Branch: $GITHUB_BRANCH"
echo "   - Build settings: use amplify.yml"
echo ""
echo -e "${YELLOW}💡 Ou use o console da AWS para criar via interface gráfica!${NC}"
echo ""
