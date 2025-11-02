terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Gerar ID único para o bucket
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Bucket S3 para armazenar dados e scripts
resource "aws_s3_bucket" "glue_data_bucket" {
  bucket = "${var.project_name}-data-${random_id.bucket_suffix.hex}"
  
  tags = {
    Name        = "${var.project_name}-data-bucket"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Configuração de versionamento do bucket
resource "aws_s3_bucket_versioning" "glue_data_bucket_versioning" {
  bucket = aws_s3_bucket.glue_data_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Bloqueio de acesso público
resource "aws_s3_bucket_public_access_block" "glue_data_bucket_pab" {
  bucket = aws_s3_bucket.glue_data_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Upload do script do Glue
resource "aws_s3_object" "glue_script" {
  bucket = aws_s3_bucket.glue_data_bucket.id
  key    = "scripts/glue_job.py"
  source = "../src/glue_job.py"
  etag   = filemd5("../src/glue_job.py")
  
  tags = {
    Name = "glue-script"
  }
}

# Upload dos arquivos CSV de teste
resource "aws_s3_object" "vendas_csv" {
  bucket = aws_s3_bucket.glue_data_bucket.id
  key    = "input/vendas.csv"
  source = "../tests/files/vendas.csv"
  etag   = filemd5("../tests/files/vendas.csv")
}

resource "aws_s3_object" "clientes_csv" {
  bucket = aws_s3_bucket.glue_data_bucket.id
  key    = "input/clientes.csv"
  source = "../tests/files/clientes.csv"
  etag   = filemd5("../tests/files/clientes.csv")
}

# IAM Role para o Glue Job
resource "aws_iam_role" "glue_job_role" {
  name = "${var.project_name}-glue-job-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-glue-job-role"
  }
}

# Policy para acesso ao S3
resource "aws_iam_policy" "glue_s3_policy" {
  name        = "${var.project_name}-glue-s3-policy"
  description = "Policy for Glue job to access S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.glue_data_bucket.arn,
          "${aws_s3_bucket.glue_data_bucket.arn}/*"
        ]
      }
    ]
  })
}

# Anexar policies ao role
resource "aws_iam_role_policy_attachment" "glue_service_role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
  role       = aws_iam_role.glue_job_role.name
}

resource "aws_iam_role_policy_attachment" "glue_s3_policy_attachment" {
  policy_arn = aws_iam_policy.glue_s3_policy.arn
  role       = aws_iam_role.glue_job_role.name
}

# Glue Job
resource "aws_glue_job" "csv_merger_job" {
  name         = var.glue_job_name
  role_arn     = aws_iam_role.glue_job_role.arn
  glue_version = "4.0"
  
  # Configuração para menor custo - usar G.1X workers
  worker_type       = "G.1X"
  number_of_workers = 2
  timeout           = var.glue_job_timeout

  command {
    script_location = "s3://${aws_s3_bucket.glue_data_bucket.id}/scripts/glue_job.py"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"                     = "python"
    "--job-bookmark-option"              = "job-bookmark-disable"
    "--enable-metrics"                   = ""
    "--enable-continuous-cloudwatch-log" = "true"
    "--BUCKET_NAME"                      = aws_s3_bucket.glue_data_bucket.id
  }

  tags = {
    Name        = var.glue_job_name
    Environment = var.environment
    Project     = var.project_name
  }

  depends_on = [aws_s3_object.glue_script]
}