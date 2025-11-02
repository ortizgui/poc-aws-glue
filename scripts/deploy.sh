#!/bin/bash

# Script para fazer deploy da infraestrutura AWS com Terraform

set -e

echo "=== Deploy da POC AWS Glue ===="

# Verificar se o Terraform está instalado
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform não está instalado. Por favor, instale o Terraform primeiro."
    exit 1
fi

# Verificar se o AWS CLI está configurado
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS CLI não está configurado ou não tem permissões. Configure primeiro:"
    echo "   aws configure"
    exit 1
fi

echo "✅ Pré-requisitos verificados"

# Ir para o diretório do Terraform
cd terraform

echo "🔄 Inicializando Terraform..."
terraform init

echo "🔄 Validando configuração..."
terraform validate

echo "🔄 Planejando deployment..."
terraform plan -out=tfplan

echo "🔄 Aplicando mudanças..."
terraform apply tfplan

echo "✅ Deploy concluído!"
echo ""
echo "=== Informações do deployment ==="
terraform output

echo ""
echo "=== Próximos passos ==="
echo "1. Para testar localmente: python src/local_test.py"
echo "2. Para executar o job no Glue:"
echo "   aws glue start-job-run --job-name \$(terraform output -raw glue_job_name)"
echo "3. Para destruir a infraestrutura: ./scripts/destroy.sh"