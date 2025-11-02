#!/bin/bash

# Script para executar teste local usando o script principal do Glue

set -e

echo "=== Teste Local da POC ===="

# Ir para o diretório raiz do projeto se necessário
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

# Verificar se o Python está instalado
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 não está instalado"
    exit 1
fi

# Criar ambiente virtual se não existir
if [ ! -d "venv" ]; then
    echo "🔄 Criando ambiente virtual..."
    python3 -m venv venv
fi

# Ativar ambiente virtual
echo "🔄 Ativando ambiente virtual..."
source venv/bin/activate

# Instalar dependências
echo "🔄 Instalando dependências..."
pip install --upgrade pip
pip install -r requirements.txt

echo "✅ Pré-requisitos verificados"

# Executar script principal em modo local
echo "🔄 Executando script do Glue em modo local..."
python3 src/glue_job.py local

echo ""
echo "✅ Teste local concluído!"
echo "📁 Verifique o arquivo gerado em: output/vendas_clientes_merged.csv"

# Desativar ambiente virtual
deactivate