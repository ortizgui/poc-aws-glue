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

def load_data_local(input_path):
    """Carrega dados usando pandas para ambiente local"""
    vendas_df = pd.read_csv(f"{input_path}/vendas.csv")
    clientes_df = pd.read_csv(f"{input_path}/clientes.csv")
    return vendas_df, clientes_df

def load_data_glue(input_path, spark):
    """Carrega dados usando Spark para ambiente AWS Glue"""
    vendas_path = f"{input_path}/vendas.csv"
    clientes_path = f"{input_path}/clientes.csv"
    
    print(f"Lendo vendas de: {vendas_path}")
    print(f"Lendo clientes de: {clientes_path}")
    
    # Ler usando Spark DataFrame e converter para pandas para unificar a lógica
    vendas_spark = spark.read.option("header", "true").option("inferSchema", "true").csv(vendas_path)
    clientes_spark = spark.read.option("header", "true").option("inferSchema", "true").csv(clientes_path)
    
    # Converter para pandas para usar a mesma lógica de processamento
    vendas_df = vendas_spark.toPandas()
    clientes_df = clientes_spark.toPandas()
    
    return vendas_df, clientes_df

def save_data_local(merged_df, output_path):
    """Salva dados usando pandas para ambiente local"""
    os.makedirs(output_path, exist_ok=True)
    output_file = f"{output_path}/vendas_clientes_merged.csv"
    merged_df.to_csv(output_file, index=False)
    print(f"Arquivo salvo em: {output_file}")
    return output_file

def save_data_glue(merged_df, output_path, spark):
    """Salva dados usando Spark para ambiente AWS Glue"""
    # Converter pandas de volta para Spark DataFrame
    spark_df = spark.createDataFrame(merged_df)
    
    output_file_path = f"{output_path}/vendas_clientes_merged.csv"
    spark_df.coalesce(1).write.mode("overwrite").option("header", "true").csv(output_file_path)
    print(f"Arquivo salvo em: {output_file_path}")
    return output_file_path

def process_data(vendas_df, clientes_df):
    """
    LÓGICA ÚNICA DE PROCESSAMENTO - EXECUTADA EM AMBOS OS AMBIENTES
    Esta função contém toda a regra de negócio e deve ser idêntica 
    independentemente do ambiente (local ou AWS Glue)
    """
    print("=== INICIANDO PROCESSAMENTO DOS DADOS ===")
    
    print(f"Vendas carregadas: {len(vendas_df)} registros")
    print(f"Clientes carregados: {len(clientes_df)} registros")
    
    # Debug: mostrar preview dos dados
    print("\n=== Preview Vendas ===")
    print(vendas_df.head())
    print(f"Colunas: {list(vendas_df.columns)}")
    
    print("\n=== Preview Clientes ===")
    print(clientes_df.head())
    print(f"Colunas: {list(clientes_df.columns)}")
    
    # Verificar valores únicos nas colunas de join
    print(f"\nCategorias em vendas: {vendas_df['categoria'].unique()}")
    print(f"Categorias em clientes: {clientes_df['categoria'].unique()}")
    print(f"IDs em vendas: {sorted(vendas_df['id'].unique())}")
    print(f"IDs em clientes: {sorted(clientes_df['id'].unique())}")
    
    # REGRA DE NEGÓCIO: Fazer o merge pelas colunas comuns (id e categoria)
    print("\n=== EXECUTANDO MERGE ===")
    merged_df = pd.merge(vendas_df, clientes_df, on=['id', 'categoria'], how='inner')
    
    print(f"Registros após merge: {len(merged_df)} registros")
    
    if len(merged_df) > 0:
        print("\n=== Preview do Resultado ===")
        print(merged_df.head())
        print(f"Colunas finais: {list(merged_df.columns)}")
    else:
        print("\n❌ ATENÇÃO: Merge resultou em 0 registros!")
        print("Verificando possíveis problemas...")
        
        # Verificar se há IDs em comum
        common_ids = set(vendas_df['id']) & set(clientes_df['id'])
        print(f"IDs em comum: {sorted(common_ids)}")
        
        # Verificar se há categorias em comum
        common_categories = set(vendas_df['categoria']) & set(clientes_df['categoria'])
        print(f"Categorias em comum: {sorted(common_categories)}")
    
    print("=== PROCESSAMENTO CONCLUÍDO ===")
    return merged_df

def run_local_mode():
    """Executa o processo em modo local"""
    print("🏠 EXECUTANDO EM MODO LOCAL")
    
    # Configuração de input/output local
    input_path = "tests/files"
    output_path = "output"
    
    # Carregar dados (específico do ambiente)
    vendas_df, clientes_df = load_data_local(input_path)
    
    # Processar dados (lógica única)
    merged_df = process_data(vendas_df, clientes_df)
    
    # Salvar dados (específico do ambiente)
    output_file = save_data_local(merged_df, output_path)
    
    return merged_df

def run_glue_mode(bucket_name):
    """Executa o processo no AWS Glue"""
    print("☁️ EXECUTANDO NO AWS GLUE")
    
    if not GLUE_AVAILABLE:
        raise ImportError("AWS Glue libraries não estão disponíveis. Execute em modo local.")
    
    # Configurar Spark e Glue Context
    sc = SparkContext()
    glueContext = GlueContext(sc)
    spark = glueContext.spark_session
    job = Job(glueContext)
    
    # Configuração de input/output S3
    input_path = f"s3://{bucket_name}/input"
    output_path = f"s3://{bucket_name}/output"
    
    # Carregar dados (específico do ambiente)
    vendas_df, clientes_df = load_data_glue(input_path, spark)
    
    # Processar dados (lógica única)
    merged_df = process_data(vendas_df, clientes_df)
    
    # Salvar dados (específico do ambiente)
    output_file = save_data_glue(merged_df, output_path, spark)
    
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