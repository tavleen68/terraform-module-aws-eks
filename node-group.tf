resource "aws_iam_policy" "worker_node_enable_logging" {
  name = "${local.id}-worker-node-policy"
  path = "/"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:PutLogEvents",
          "logs:CreateLogStream",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}


resource "aws_iam_role" "worker-node" {
  name = "${local.id}-terraform-eks-worker-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "worker-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker-node.name
}

resource "aws_iam_role_policy_attachment" "worker-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker-node.name
}

resource "aws_iam_role_policy_attachment" "worker-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker-node.name
}

resource "aws_iam_role_policy_attachment" "worker_node_enable_logging" {
  policy_arn = aws_iam_policy.worker_node_enable_logging.arn
  role       = aws_iam_role.worker-node.name
}

resource "aws_iam_role_policy_attachment" "worker-node-additional-policy-attachments" {
  count = length(var.worker_node_additional_policy_arns) > 0 ? length(var.worker_node_additional_policy_arns) : 1  # Set count based on policy_arns length
  role       = aws_iam_role.worker-node.name
  policy_arn = var.worker_node_additional_policy_arns[count.index]
}

resource "aws_eks_node_group" "worker-node" {
  #for_each = aws_eks_cluster.default
  for_each     = tomap({ for cluster in aws_eks_cluster.default : cluster.name => cluster })
  cluster_name = each.value.name
  #  cluster_name    = aws_eks_cluster.default[count.index].name
  node_group_name = "${local.id}-Node-Group"
  node_role_arn   = aws_iam_role.worker-node.arn
  subnet_ids      = local.subnet_ids
  instance_types  = tolist(var.nodegroup_instance_type) #["t3.large"] ##map for instance type
  disk_size       = var.nodegroup_instance_disk_size    # 300 ##map for disk size
  tags = merge({
    Name = "${local.id}-nodegroup"
    #    "k8s.io/cluster-autoscaler/${aws_eks_cluster.default[count.index].name}" = "owned"
    "k8s.io/cluster-autoscaler/${each.value.name}" = "owned"
    "k8s.io/cluster-autoscaler/enabled"            = "true"
  },
  var.default_tags
  )
  scaling_config {
    desired_size = var.nodegroup_instance_desired_size #2 #var.desired_size
    max_size     = var.nodegroup_instance_max_size     #4 #var.max_size
    min_size     = var.nodegroup_instance_min_size     #2 #var.min_size
  }

  depends_on = [
    aws_iam_role_policy_attachment.worker-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.worker-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.worker-node-AmazonEC2ContainerRegistryReadOnly,
  ]
}
#
#variable "nodegroup_config" {
#  type = object({
#    nodegroup = object({
#      disk_size       = number
#      instance_types  = string
#      desired_size    = number
#      min_size        = number
#      max_size        = number
#    })
#  })
#
#  default = {
#    nodegroup = {
#      disk_size       = 300
#      instance_types  = "t3.large"
#      desired_size    = 2
#      min_size        = 2
#      max_size        = 4
#    }
#  }
#}

resource "aws_autoscaling_group_tag" "mytag" {
  for_each               = aws_eks_node_group.worker-node
  autoscaling_group_name = aws_eks_node_group.worker-node[each.key].resources[0].autoscaling_groups[0].name
  tag {
    key                 = "dynatrace"
    value               = "true"
    propagate_at_launch = true
  }
  depends_on = [aws_eks_node_group.worker-node]
}
resource "aws_autoscaling_group_tag" "mytag1" {
  for_each = aws_eks_node_group.worker-node
  #cluster_name = each.value
  autoscaling_group_name = aws_eks_node_group.worker-node[each.key].resources[0].autoscaling_groups[0].name
  tag {
    key                 = "env"
    value               = var.environment
    propagate_at_launch = true
  }
  depends_on = [aws_eks_node_group.worker-node]
}
