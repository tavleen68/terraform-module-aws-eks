output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.default[0].name
}

output "eks_cluster_arn" {
  description = "The ARN of the EKS cluster"
  value       = aws_eks_cluster.default[0].arn
}
