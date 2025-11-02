#!/bin/bash

# Script para destruir toda a infraestrutura AWS criada pelo Terraform

set -e

echo "=== Destruição da POC AWS Glue ===="

# Verificar se estamos no diretório correto
if [ ! -d "terraform" ]; then
    echo "❌ Execute este script a partir do diretório raiz do projeto"
    exit 1
fi

# Ir para o diretório do Terraform
cd terraform

# Verificar se existe state do Terraform
if [ ! -f "terraform.tfstate" ]; then
    echo "⚠️  Nenhum state do Terraform encontrado. Nada para destruir."
    exit 0
fi

echo "⚠️  ATENÇÃO: Esta operação irá DESTRUIR TODOS os recursos AWS criados!"
echo "   - Bucket S3 e todos os arquivos"
echo "   - Job do AWS Glue"
echo "   - Roles e policies IAM"
echo ""

# Confirmar destruição (apenas se não for executado em modo automático)
if [ "$1" != "--auto" ]; then
    read -p "Deseja continuar? (Digite 'sim' para confirmar): " confirmacao
    if [ "$confirmacao" != "sim" ]; then
        echo "❌ Operação cancelada"
        exit 1
    fi
fi

echo "🔄 Planejando destruição..."
terraform plan -destroy

echo "🔄 Destruindo recursos..."
terraform destroy -auto-approve

echo "✅ Todos os recursos foram destruídos!"
echo ""
echo "=== Limpeza adicional ==="
echo "🔄 Removendo arquivos de state local..."

# Limpar arquivos do Terraform (opcional)
read -p "Deseja remover os arquivos de state do Terraform? (s/n): " limpar_state
if [ "$limpar_state" = "s" ] || [ "$limpar_state" = "S" ]; then
    rm -f terraform.tfstate*
    rm -f tfplan
    rm -rf .terraform/
    echo "✅ Arquivos de state removidos"
else
    echo "ℹ️  Arquivos de state mantidos para possível recuperação"
fi

echo ""
echo "✅ Destruição concluída!"