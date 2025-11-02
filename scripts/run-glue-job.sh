#!/bin/bash

# Script para executar o job do Glue na AWS

set -e

echo "=== Execução do Job AWS Glue ===="

# Verificar se estamos no diretório correto
if [ ! -d "terraform" ]; then
    echo "❌ Execute este script a partir do diretório raiz do projeto"
    exit 1
fi

# Ir para o diretório do Terraform para obter outputs
cd terraform

# Verificar se a infraestrutura foi deployada
if [ ! -f "terraform.tfstate" ]; then
    echo "❌ Infraestrutura não encontrada. Execute primeiro ./scripts/deploy.sh"
    exit 1
fi

# Obter nome do job
JOB_NAME=$(terraform output -raw glue_job_name 2>/dev/null)
if [ -z "$JOB_NAME" ]; then
    echo "❌ Não foi possível obter o nome do job do Glue"
    exit 1
fi

echo "🔄 Executando job: $JOB_NAME"

# Executar o job
JOB_RUN_ID=$(aws glue start-job-run --job-name "$JOB_NAME" --query 'JobRunId' --output text)

if [ $? -eq 0 ]; then
    echo "✅ Job iniciado com sucesso!"
    echo "📊 Job Run ID: $JOB_RUN_ID"
    echo ""
    echo "🔄 Monitorando execução..."
    
    # Monitorar status do job
    while true; do
        STATUS=$(aws glue get-job-run --job-name "$JOB_NAME" --run-id "$JOB_RUN_ID" --query 'JobRun.JobRunState' --output text)
        
        case $STATUS in
            "SUCCEEDED")
                echo "✅ Job concluído com sucesso!"
                break
                ;;
            "FAILED"|"ERROR"|"TIMEOUT")
                echo "❌ Job falhou com status: $STATUS"
                echo "📋 Verifique os logs no CloudWatch para mais detalhes"
                exit 1
                ;;
            "RUNNING"|"STARTING")
                echo "⏳ Status: $STATUS - aguardando..."
                sleep 30
                ;;
            *)
                echo "ℹ️  Status: $STATUS"
                sleep 10
                ;;
        esac
    done
    
    echo ""
    echo "=== Informações do resultado ==="
    BUCKET_NAME=$(terraform output -raw s3_bucket_name)
    echo "📁 Resultado disponível em: s3://$BUCKET_NAME/output/"
    echo ""
    echo "🔍 Para baixar o resultado:"
    echo "   aws s3 cp s3://$BUCKET_NAME/output/ ./output/ --recursive"
    
else
    echo "❌ Falha ao iniciar o job"
    exit 1
fi