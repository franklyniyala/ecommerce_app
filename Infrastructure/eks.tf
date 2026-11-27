# EKS Cluster
resource "aws_eks_cluster" "ecommerce_eks" {
  name     = "ecommerce-eks-cluster"
  role_arn = aws_iam_role.ecommerce_eks_cluster_role.arn
  version  = "1.37"

  vpc_config {
    subnet_ids = [
      aws_subnet.ecommerce_public_subnet.id,
      aws_subnet.ecommerce_public_subnet2.id,
      aws_subnet.ecommerce_private_subnet.id,
      aws_subnet.ecommerce_private_subnet2.id
    ]
    endpoint_private_access = true
    endpoint_public_access  = true

    public_access_cidrs = ["102.88.106.193/32"]

  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true

  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]

  tags = {
    Name = "ecommerce_eks_cluster"
  }
}

# EKS Managed Node Group
resource "aws_eks_node_group" "ecommerce_nodes" {
  cluster_name    = aws_eks_cluster.ecommerce_eks.name
  node_group_name = "ecommerce-worker-nodes"
  node_role_arn   = aws_iam_role.ecommerce_eks_node_role.arn

  subnet_ids = [
    aws_subnet.ecommerce_private_subnet.id,
    aws_subnet.ecommerce_private_subnet2.id
  ]

  instance_types = ["t3.medium"]
  disk_size      = 20
  capacity_type  = "ON_DEMAND"

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 2
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_policy,
    aws_iam_role_policy_attachment.eks_ecr_policy,
    aws_iam_role_policy_attachment.eks_cni_policy
  ]

  tags = {
    Name = "ecommerce-worker-nodes"
  }
}

