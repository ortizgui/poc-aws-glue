import os
import sys
import pandas as pd

# Importações do AWS Glue - só importa se não estiver em modo local
try:
    from awsglue.transforms import *
    from awsglue.utils import getResolvedOptions
    from pyspark.context import SparkContext
    from awsglue.context import GlueContext
    from awsglue.job import Job
    GLUE_AVAILABLE = True
except ImportError:
    GLUE_AVAILABLE = False

def run_local_mode():
    """Executa o processo em modo local para testes"""
    print("Executando em modo LOCAL")
    
    # Caminhos locais
    input_path = "tests/files"
    output_path = "output"
    
    # Criar diretório de output se não existir
    os.makedirs(output_path, exist_ok=True)
    
    # Ler arquivos CSV
    vendas_df = pd.read_csv(f"{input_path}/vendas.csv")
    clientes_df = pd.read_csv(f"{input_path}/clientes.csv")
    
    print(f"Vendas carregadas: {len(vendas_df)} registros")
    print(f"Clientes carregados: {len(clientes_df)} registros")
    
    # Fazer o merge pelas colunas comuns (id e categoria)
    merged_df = pd.merge(vendas_df, clientes_df, on=['id', 'categoria'], how='inner')
    
    print(f"Registros após merge: {len(merged_df)} registros")
    
    # Salvar resultado
    output_file = f"{output_path}/vendas_clientes_merged.csv"
    merged_df.to_csv(output_file, index=False)
    
    print(f"Arquivo salvo em: {output_file}")
    return merged_df

def run_glue_mode(bucket_name):
    """Executa o processo no AWS Glue"""
    print("Executando no AWS GLUE")
    
    if not GLUE_AVAILABLE:
        raise ImportError("AWS Glue libraries não estão disponíveis. Execute em modo local.")
    
    # Configurar Spark e Glue Context
    sc = SparkContext()
    glueContext = GlueContext(sc)
    spark = glueContext.spark_session
    job = Job(glueContext)
    
    # Caminhos S3
    input_path = f"s3://{bucket_name}/input"
    output_path = f"s3://{bucket_name}/output"
    
    # Ler arquivos CSV do S3 usando pandas via Spark
    vendas_path = f"{input_path}/vendas.csv"
    clientes_path = f"{input_path}/clientes.csv"
    
    print(f"Lendo vendas de: {vendas_path}")
    print(f"Lendo clientes de: {clientes_path}")
    
    # Ler usando Spark DataFrame
    vendas_df = spark.read.option("header", "true").option("inferSchema", "true").csv(vendas_path)
    clientes_df = spark.read.option("header", "true").option("inferSchema", "true").csv(clientes_path)
    
    print(f"Vendas carregadas: {vendas_df.count()} registros")
    print(f"Clientes carregados: {clientes_df.count()} registros")
    
    # Fazer o join pelas colunas comuns
    merged_df = vendas_df.join(clientes_df, on=['id', 'categoria'], how='inner')
    
    print(f"Registros após merge: {merged_df.count()} registros")
    
    # Salvar resultado no S3
    output_file_path = f"{output_path}/vendas_clientes_merged.csv"
    merged_df.coalesce(1).write.mode("overwrite").option("header", "true").csv(output_file_path)
    
    print(f"Arquivo salvo em: {output_file_path}")
    
    job.commit()
    return merged_df

def main():
    """Função principal que decide o modo de execução"""
    
    # Verificar se foi passado o parâmetro 'local'
    if 'local' in sys.argv or os.getenv('ENVIRONMENT', '').lower() == 'local':
        return run_local_mode()
    
    # Modo AWS Glue - verificar se as bibliotecas estão disponíveis
    if not GLUE_AVAILABLE:
        print("❌ AWS Glue libraries não disponíveis.")
        print("💡 Para executar localmente, use: python glue_job.py local")
        sys.exit(1)
    
    # Obter argumentos do Glue
    try:
        args = getResolvedOptions(sys.argv, ['JOB_NAME', 'BUCKET_NAME'])
        bucket_name = args['BUCKET_NAME']
        return run_glue_mode(bucket_name)
    except Exception as e:
        print(f"❌ Erro ao obter argumentos do Glue: {str(e)}")
        print("💡 Para executar localmente, use: python glue_job.py local")
        sys.exit(1)

if __name__ == "__main__":
    try:
        result = main()
        print("Processamento concluído com sucesso!")
    except Exception as e:
        print(f"Erro durante o processamento: {str(e)}")
        sys.exit(1)