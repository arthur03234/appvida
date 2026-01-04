#!/bin/bash

# AppVida AWS Infrastructure Setup Script

set -e

echo "🚀 AppVida - AWS Infrastructure Setup"
echo "====================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI is not installed${NC}"
    echo "Please install AWS CLI: https://aws.amazon.com/cli/"
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}❌ Terraform is not installed${NC}"
    echo "Please install Terraform: https://www.terraform.io/downloads"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"

# Set variables
REGION="sa-east-1"
PROJECT="appvida"

echo ""
echo "📋 Configuration:"
echo "   Region: $REGION"
echo "   Project: $PROJECT"
echo ""

# Create S3 bucket for Terraform state
echo "📦 Creating S3 bucket for Terraform state..."
BUCKET_NAME="${PROJECT}-terraform-state"

if aws s3 ls "s3://${BUCKET_NAME}" 2>&1 | grep -q 'NoSuchBucket'; then
    aws s3 mb "s3://${BUCKET_NAME}" --region "$REGION"
    
    # Enable versioning
    aws s3api put-bucket-versioning \
        --bucket "${BUCKET_NAME}" \
        --versioning-configuration Status=Enabled
    
    # Enable encryption
    aws s3api put-bucket-encryption \
        --bucket "${BUCKET_NAME}" \
        --server-side-encryption-configuration '{
            "Rules": [{
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }]
        }'
    
    echo -e "${GREEN}✅ S3 bucket created: ${BUCKET_NAME}${NC}"
else
    echo -e "${YELLOW}⚠️  S3 bucket already exists: ${BUCKET_NAME}${NC}"
fi

# Initialize Terraform
echo ""
echo "🔧 Initializing Terraform..."
cd ../terraform
terraform init

echo ""
echo -e "${GREEN}✅ Setup completed!${NC}"
echo ""
echo "Next steps:"
echo "1. Review and update terraform.tfvars"
echo "2. Set sensitive variables:"
echo "   export TF_VAR_mongodb_uri='your-mongodb-uri'"
echo "   export TF_VAR_jwt_secret='your-jwt-secret'"
echo "3. Run: terraform plan"
echo "4. Run: terraform apply"
echo ""
