# POC AWS Glue - CSV Merger

Esta é uma Prova de Conceito (POC) para demonstrar como usar AWS Glue para processar e combinar arquivos CSV usando Terraform para infraestrutura como código.

## 📋 Descrição

O projeto cria um job AWS Glue que:
- Lê 2 arquivos CSV de um bucket S3
- Combina os arquivos pelas colunas comuns (`id` e `categoria`)
- Salva o resultado em um novo arquivo CSV no S3
- Suporte para testes locais usando pandas

## 💰 Calculadora de Custos AWS Glue

Este repositório inclui uma **calculadora interativa de custos** para estimar o valor de execução de jobs AWS Glue, disponível via GitHub Pages.

### 🌐 Acessar a Calculadora

A calculadora está disponível em: **[GitHub Pages - Calculadora de Custos](https://yourusername.github.io/poc-glue-tests/)**

*(Substitua `yourusername` pelo seu nome de usuário do GitHub)*

### ✨ Funcionalidades da Calculadora

A calculadora permite estimar custos considerando:

- ⏱️ **Tempo de execução** do job (em minutos)
- 🖥️ **Tipo de Worker** (G.025X, G.1X, G.2X, G.4X, G.8X)
- 👥 **Número de Workers**
- 🔄 **Tipo de Execução** (Standard ou FLEX com desconto)
- 🌍 **Região AWS**
- 📊 **Custos adicionais**:
  - Data Catalog (objetos armazenados)
  - Crawlers (tempo de execução)

### 📊 Como Funciona

A calculadora utiliza os preços oficiais da AWS:
- **$0.44 por DPU-Hora** (faturado por segundo, mínimo de 1 minuto)
- **Desconto FLEX**: até 40% de economia (média)
- **Data Catalog**: Primeiro 1 milhão de objetos gratuito, depois $1.00 por 100.000 objetos/mês
- **Crawlers**: Mesmo preço que ETL jobs, mínimo de 10 minutos

### 🚀 Configurar GitHub Pages

Para disponibilizar a calculadora no GitHub Pages:

1. **Ativar GitHub Pages no repositório**:
   - Vá em `Settings` → `Pages`
   - Em `Source`, selecione `Deploy from a branch`
   - Escolha a branch `main` e a pasta `/docs`
   - Clique em `Save`

2. **Acessar a calculadora**:
   - A URL será: `https://yourusername.github.io/poc-glue-tests/`
   - Pode levar alguns minutos para ficar disponível após a primeira configuração

### 📁 Estrutura da Calculadora

```
docs/
├── index.html      # Interface da calculadora
├── styles.css      # Estilos e design responsivo
├── calculator.js   # Lógica de cálculo
└── .nojekyll       # Configuração para GitHub Pages
```

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
├── docs/                # GitHub Pages - Calculadora de Custos
│   ├── index.html      # Interface da calculadora
│   ├── styles.css      # Estilos e design responsivo
│   ├── calculator.js   # Lógica de cálculo
│   └── .nojekyll       # Configuração para GitHub Pages
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

## ⚡ Resumo Rápido

```bash
# 1. Setup inicial
./scripts/setup-dev.sh

# 2. Teste local
./scripts/test-local.sh

# 3. Deploy na AWS
./scripts/deploy.sh

# 4. Executar no AWS Glue
./scripts/run-glue-job.sh

# 5. Limpar recursos (quando terminar)
./scripts/destroy.sh
```

## 🚀 Como Usar

### Pré-requisitos

1. **AWS CLI configurado**:
   ```bash
   aws configure
   # Configure: Access Key, Secret Key, Region (recomendado: us-east-1), Output format
   ```

2. **Terraform instalado**:
   ```bash
   # macOS
   brew install terraform
   
   # Ubuntu/Debian
   sudo apt-get update && sudo apt-get install -y terraform
   
   # Ou baixe de: https://terraform.io/downloads
   ```

3. **Python 3** (para testes locais) - Será configurado automaticamente com venv

### 🔧 Fluxo Completo de Uso

#### **Passo 0: Configurar Ambiente de Desenvolvimento (primeira vez)**

```bash
./scripts/setup-dev.sh
```

#### **Passo 1: Teste Local**

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

#### **Passo 2: Deploy na AWS**

#### **Primeira vez ou mudanças na infraestrutura:**
```bash
./scripts/deploy.sh
```

Este comando irá:
- ✅ Verificar pré-requisitos (Terraform, AWS CLI)
- ✅ Inicializar Terraform
- ✅ Criar bucket S3 único
- ✅ Fazer upload do script Python atualizado
- ✅ Fazer upload dos arquivos CSV de exemplo
- ✅ Criar job AWS Glue com configuração otimizada para baixo custo
- ✅ Criar roles e políticas IAM necessárias
- ✅ Exibir informações do deployment

#### **Atualizar apenas o script Python:**
```bash
cd terraform
terraform apply -auto-approve
```

#### **Passo 3: Executar Job AWS Glue**

```bash
./scripts/run-glue-job.sh
```

Este script irá:
- 🚀 Iniciar o job no AWS Glue
- 📊 Monitorar a execução em tempo real
- ✅ Informar quando concluído
- 📁 Mostrar onde encontrar os resultados

#### **Passo 4: Baixar Resultados (Opcional)**

```bash
# Obter nome do bucket e baixar resultados
cd terraform
BUCKET_NAME=$(terraform output -raw s3_bucket_name)
aws s3 cp s3://$BUCKET_NAME/output/ ./output/ --recursive
```

#### **Passo 5: Verificar Configuração AWS (Se Necessário)**

```bash
# Verificar se AWS CLI está configurado
aws sts get-caller-identity

# Se não estiver configurado:
aws configure
```

#### **Passo 6: Destruir Infraestrutura (Quando Finalizar)**

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

**Arquitetura do Script:**

O script `glue_job.py` foi projetado com uma arquitetura que garante **idêntica lógica de processamento** em ambos os ambientes:

```
┌─────────────────────────────────────────────────────────────┐
│                    AMBIENTE LOCAL                           │
├─────────────────────────────────────────────────────────────┤
│ load_data_local() → process_data() → save_data_local()      │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    AMBIENTE AWS GLUE                        │ 
├─────────────────────────────────────────────────────────────┤
│ load_data_glue() → process_data() → save_data_glue()        │
└─────────────────────────────────────────────────────────────┘
```

- **`process_data()`**: Contém 100% da lógica de negócio usando pandas
- **Input/Output**: Apenas estas funções diferem entre ambientes
- **Garantia**: Mesmas regras executadas independente do ambiente

**Execução Local:**
```bash
# Usando parâmetro
python3 src/glue_job.py local

# Usando variável de ambiente  
ENVIRONMENT=local python3 src/glue_job.py
```

**Execução no AWS Glue:**
- Detecta automaticamente o ambiente AWS Glue
- Converte Spark DataFrames para pandas para usar a mesma lógica
- Reconverte para Spark apenas no momento de salvar

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