#!/bin/bash

# AppVida Deployment Script

set -e

echo "🚀 AppVida - Deployment Script"
echo "==============================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
REGION="sa-east-1"
PROJECT="appvida"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

if [ -z "$AWS_ACCOUNT_ID" ]; then
    echo -e "${RED}❌ Failed to get AWS Account ID${NC}"
    exit 1
fi

echo -e "${BLUE}AWS Account: ${AWS_ACCOUNT_ID}${NC}"
echo -e "${BLUE}Region: ${REGION}${NC}"
echo ""

# Function to build and push Docker image
build_and_push() {
    local SERVICE=$1
    local DOCKERFILE_PATH=$2
    local ECR_REPO="${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${PROJECT}/${SERVICE}"
    
    echo -e "${YELLOW}📦 Building ${SERVICE}...${NC}"
    
    # Build image
    docker build -t "${PROJECT}/${SERVICE}:latest" -f "${DOCKERFILE_PATH}/Dockerfile" "${DOCKERFILE_PATH}"
    
    # Tag image
    docker tag "${PROJECT}/${SERVICE}:latest" "${ECR_REPO}:latest"
    docker tag "${PROJECT}/${SERVICE}:latest" "${ECR_REPO}:$(git rev-parse --short HEAD)"
    
    # Push image
    echo -e "${YELLOW}📤 Pushing ${SERVICE} to ECR...${NC}"
    docker push "${ECR_REPO}:latest"
    docker push "${ECR_REPO}:$(git rev-parse --short HEAD)"
    
    echo -e "${GREEN}✅ ${SERVICE} deployed${NC}"
    echo ""
}

# Login to ECR
echo -e "${YELLOW}🔐 Logging in to ECR...${NC}"
aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

echo ""
echo -e "${GREEN}✅ ECR login successful${NC}"
echo ""

# Build and push services
cd ../../

build_and_push "api-gateway" "services/api-gateway"
build_and_push "auth-service" "services/auth-service"
build_and_push "user-service" "services/user-service"
build_and_push "frontend" "frontend"

echo -e "${GREEN}🎉 All services deployed successfully!${NC}"
echo ""
echo "To update ECS services, run:"
echo "  aws ecs update-service --cluster ${PROJECT}-cluster --service <service-name> --force-new-deployment --region ${REGION}"
echo ""
