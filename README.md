# POC AWS Glue - CSV Merger

Esta é uma Prova de Conceito (POC) para demonstrar como usar AWS Glue para processar e combinar arquivos CSV usando Terraform para infraestrutura como código.

## 📋 Descrição

O projeto cria um job AWS Glue que:
- Lê 2 arquivos CSV de um bucket S3
- Combina os arquivos pelas colunas comuns (`id` e `categoria`)
- Salva o resultado em um novo arquivo CSV no S3
- Suporte para testes locais usando pandas

## 🏗️ Arquitetura

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   S3 Bucket     │    │   AWS Glue      │    │   S3 Bucket     │
│                 │    │                 │    │                 │
│  input/         │───▶│  CSV Merger Job │───▶│  output/        │
│  ├─ vendas.csv  │    │                 │    │  └─ merged.csv  │
│  └─ clientes.csv│    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 📁 Estrutura do Projeto

```
poc-glue-tests/
├── src/
│   └── glue_job.py       # Script principal do Glue (funciona local + AWS)
├── tests/
│   └── files/
│       ├── vendas.csv    # Arquivo CSV de exemplo (5 colunas)
│       └── clientes.csv  # Arquivo CSV de exemplo (6 colunas)
├── terraform/
│   ├── main.tf          # Configuração principal
│   ├── variables.tf     # Variáveis
│   └── outputs.tf       # Outputs
├── scripts/
│   ├── setup-dev.sh     # Configurar ambiente de desenvolvimento
│   ├── deploy.sh        # Script de deploy
│   ├── destroy.sh       # Script de destruição
│   ├── test-local.sh    # Script de teste local
│   └── run-glue-job.sh  # Script para executar job
├── venv/                # Ambiente virtual Python (criado automaticamente)
├── output/              # Pasta para resultados locais
├── requirements.txt     # Dependências Python
├── .gitignore          # Arquivos ignorados pelo Git
└── README.md
```

## 📊 Dados de Exemplo

### vendas.csv (5 colunas)
- `id`, `produto`, `categoria`, `preco`, `quantidade`

### clientes.csv (6 colunas)  
- `id`, `nome`, `email`, `categoria`, `regiao`, `data_cadastro`

### Colunas Comuns para Join
- `id` e `categoria`

## 🚀 Como Usar

### Pré-requisitos

1. **AWS CLI configurado**:
   ```bash
   aws configure
   ```

2. **Terraform instalado**:
   ```bash
   # macOS
   brew install terraform
   
   # Ou baixe de: https://terraform.io/downloads
   ```

3. **Python 3** (para testes locais) - Será configurado automaticamente com venv

### 0. Configurar Ambiente de Desenvolvimento (primeira vez)

```bash
./scripts/setup-dev.sh
```

### 1. Teste Local

Execute o processamento localmente para validar a lógica usando o mesmo script do Glue:

```bash
# Usando o script de conveniência (recomendado)
./scripts/test-local.sh

# Ou manualmente ativando o venv
source venv/bin/activate
python src/glue_job.py local
deactivate

# Ou usando variável de ambiente
source venv/bin/activate
ENVIRONMENT=local python src/glue_job.py
deactivate
```

O resultado será salvo em `output/vendas_clientes_merged.csv`.

### 2. Deploy na AWS

```bash
./scripts/deploy.sh
```

Este comando irá:
- Criar bucket S3 único
- Fazer upload dos scripts e arquivos CSV
- Criar job AWS Glue com configuração otimizada para baixo custo
- Criar roles e políticas IAM necessárias

### 3. Executar Job AWS Glue

```bash
./scripts/run-glue-job.sh
```

Este script irá:
- Iniciar o job no AWS Glue
- Monitorar a execução
- Informar quando concluído

### 4. Baixar Resultados

```bash
# Obter nome do bucket
cd terraform
BUCKET_NAME=$(terraform output -raw s3_bucket_name)

# Baixar resultados
aws s3 cp s3://$BUCKET_NAME/output/ ./output/ --recursive
```

### 5. Destruir Infraestrutura

```bash
./scripts/destroy.sh
```

⚠️ **ATENÇÃO**: Este comando remove TODOS os recursos AWS criados, incluindo o bucket S3 e todos os arquivos.

## 💰 Otimização de Custos

A POC está configurada para minimizar custos:

- **Worker Type**: G.1X (menor tipo disponível)
- **Number of Workers**: 2 (mínimo)
- **Timeout**: 5 minutos
- **Job Bookmark**: Desabilitado
- **Auto Scaling**: Desabilitado

**Custo estimado**: ~$0.44 por execução (região us-east-1)

## 🔧 Configuração

### Variáveis Terraform

Edite `terraform/variables.tf` para personalizar:

```hcl
variable "aws_region" {
  default = "us-east-1"  # Altere a região se necessário
}

variable "glue_job_timeout" {
  default = 5  # Timeout em minutos
}

variable "max_capacity" {
  default = 2  # Número de workers
}
```

### Modo de Execução do Script Python

O script `src/glue_job.py` suporta execução em ambos os ambientes usando um único arquivo:

**Execução Local:**
```bash
# Usando parâmetro
python3 src/glue_job.py local

# Usando variável de ambiente
ENVIRONMENT=local python3 src/glue_job.py
```

**Execução no AWS Glue:**
- O script detecta automaticamente quando está sendo executado no AWS Glue
- Usa as bibliotecas do Glue (pyspark, awsglue) quando disponíveis
- Se as bibliotecas não estiverem disponíveis, sugere execução em modo local

## 📝 Logs e Monitoramento

### CloudWatch Logs
```bash
# Ver logs do job
aws logs describe-log-groups --log-group-name-prefix "/aws-glue/jobs"
```

### Status do Job
```bash
# Listar execuções do job
aws glue get-job-runs --job-name csv-merger-job
```

## 🔍 Troubleshooting

### Erro: "Job failed"
1. Verifique os logs no CloudWatch
2. Confirme que os arquivos CSV estão no bucket S3
3. Verifique permissões IAM

### Erro: "Bucket already exists"
- O nome do bucket é gerado aleatoriamente, mas se houver conflito, execute `terraform destroy` e `terraform apply` novamente

### Teste local falha
- Verifique se o pandas está instalado: `pip install pandas`
- Confirme que os arquivos CSV estão em `tests/files/`

## 🎯 Próximos Passos

Para evoluir esta POC:

1. **Adicionar mais transformações**: Limpeza de dados, validações
2. **Implementar particionamento**: Para datasets maiores
3. **Adicionar testes automatizados**: Validação de esquemas
4. **Configurar CI/CD**: Deploy automatizado
5. **Adicionar monitoramento**: Alertas e métricas customizadas
6. **Implementar Data Catalog**: Para descoberta de dados

## 📜 Licença

Este projeto é uma POC para fins educacionais e de demonstração.