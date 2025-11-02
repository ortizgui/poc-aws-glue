#!/bin/bash

# Script para configurar ambiente de desenvolvimento

set -e

echo "=== Configuração do Ambiente de Desenvolvimento ===="

# Verificar se o Python está instalado
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 não está instalado"
    echo "💡 Instale Python3 primeiro: https://python.org/downloads/"
    exit 1
fi

echo "✅ Python3 encontrado: $(python3 --version)"

# Criar ambiente virtual se não existir
if [ ! -d "venv" ]; then
    echo "🔄 Criando ambiente virtual..."
    python3 -m venv venv
    echo "✅ Ambiente virtual criado"
else
    echo "✅ Ambiente virtual já existe"
fi

# Ativar ambiente virtual
echo "🔄 Ativando ambiente virtual..."
source venv/bin/activate

# Atualizar pip
echo "🔄 Atualizando pip..."
pip install --upgrade pip

# Instalar dependências
echo "🔄 Instalando dependências..."
pip install -r requirements.txt

echo ""
echo "✅ Configuração concluída!"
echo ""
echo "=== Próximos passos ==="
echo "1. Para ativar o ambiente virtual:"
echo "   source venv/bin/activate"
echo ""
echo "2. Para executar teste local:"
echo "   ./scripts/test-local.sh"
echo ""
echo "3. Para executar diretamente:"
echo "   python src/glue_job.py local"
echo ""
echo "4. Para desativar o ambiente virtual:"
echo "   deactivate"