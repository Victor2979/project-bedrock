variable "region" {
  type    = string
  default = "us-east-1"
}

variable "cluster_name" {
  type    = string
  default = "project-bedrock-cluster"
}

variable "cluster_version" {
  type    = string
  default = "1.34"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "student_id" {
  description = "Used to make the assets S3 bucket name unique"
  type        = string
  default     = "alt-soe-025-3228"
}

variable "db_username" {
  type    = string
  default = "bedrockadmin"
}

variable "tags" {
  type = map(string)
  default = {
    Project = "karatu-2025-capstone"
  }
}
