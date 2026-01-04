#!/bin/bash

# AppVida Infrastructure Destruction Script

set -e

echo "⚠️  AppVida - Infrastructure Destruction"
echo "========================================="
echo ""
echo "This will destroy ALL AWS infrastructure for AppVida."
echo "This action CANNOT be undone!"
echo ""

read -p "Are you sure you want to continue? (type 'yes' to confirm): " confirmation

if [ "$confirmation" != "yes" ]; then
    echo "Destruction cancelled."
    exit 0
fi

echo ""
read -p "Please type the project name 'appvida' to confirm: " project_confirm

if [ "$project_confirm" != "appvida" ]; then
    echo "Project name mismatch. Destruction cancelled."
    exit 0
fi

echo ""
echo "🔥 Destroying infrastructure..."
echo ""

cd ../terraform

# Destroy infrastructure
terraform destroy -auto-approve

echo ""
echo "✅ Infrastructure destroyed."
echo ""
echo "Note: The S3 bucket for Terraform state still exists."
echo "To remove it manually, run:"
echo "  aws s3 rb s3://appvida-terraform-state --force"
echo ""
