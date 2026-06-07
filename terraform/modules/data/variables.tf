variable "cluster_name"        { type = string }
variable "vpc_id"              { type = string }
variable "private_subnets"     { type = list(string) }
variable "node_security_group" { type = string }
variable "db_username"         { type = string }
variable "tags"                { type = map(string) }
