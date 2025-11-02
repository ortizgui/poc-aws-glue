variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "poc-glue-tests"
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "glue_job_name" {
  description = "Nome do job do Glue"
  type        = string
  default     = "csv-merger-job"
}

variable "glue_job_timeout" {
  description = "Timeout do job do Glue em minutos"
  type        = number
  default     = 5
}

variable "max_capacity" {
  description = "Capacidade máxima do job (para reduzir custos)"
  type        = number
  default     = 2
}