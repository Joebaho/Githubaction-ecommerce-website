variable "aws_region" {
  description = "AWS region for all infrastructure."
  default     = "us-west-2"
}

variable "cluster_name" {
  description = "EKS cluster name."
  default     = "ecommerce-eks"
}
