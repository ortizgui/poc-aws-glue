output "s3_bucket_name" {
  description = "Nome do bucket S3 criado"
  value       = aws_s3_bucket.glue_data_bucket.id
}

output "s3_bucket_arn" {
  description = "ARN do bucket S3"
  value       = aws_s3_bucket.glue_data_bucket.arn
}

output "glue_job_name" {
  description = "Nome do job do Glue"
  value       = aws_glue_job.csv_merger_job.name
}

output "glue_job_arn" {
  description = "ARN do job do Glue"
  value       = aws_glue_job.csv_merger_job.arn
}

output "glue_role_arn" {
  description = "ARN do role do Glue"
  value       = aws_iam_role.glue_job_role.arn
}

output "input_s3_path" {
  description = "Caminho S3 para arquivos de entrada"
  value       = "s3://${aws_s3_bucket.glue_data_bucket.id}/input/"
}

output "output_s3_path" {
  description = "Caminho S3 para arquivos de saída"
  value       = "s3://${aws_s3_bucket.glue_data_bucket.id}/output/"
}

output "aws_region" {
  description = "Região AWS utilizada"
  value       = var.aws_region
}