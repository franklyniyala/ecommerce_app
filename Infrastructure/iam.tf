# EKS Cluster Trust Policy
data "aws_iam_policy_document" "eks_cluster_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

# EKS Cluster IAM Role
resource "aws_iam_role" "ecommerce_eks_cluster_role" {
  name               = "ecommerce-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role.json

  tags = {
    Name = "ecommerce-eks-cluster-role"
  }
}

# Attach EKS Cluster Policy
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.ecommerce_eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Worker Node Trust Policy
data "aws_iam_policy_document" "eks_node_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Worker Node IAM Role
resource "aws_iam_role" "ecommerce_eks_node_role" {
  name               = "ecommerce-eks-node-role"
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role.json

  tags = {
    Name = "ecommerce-eks-node-role"
  }
}

# Allow Worker Nodes to Communicate with EKS
resource "aws_iam_role_policy_attachment" "eks_node_policy" {
  role       = aws_iam_role.ecommerce_eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# Allow Worker Nodes to Pull Images from ECR
resource "aws_iam_role_policy_attachment" "eks_ecr_policy" {
  role       = aws_iam_role.ecommerce_eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}

# Allow VPC CNI to Manage Kubernetes Pod Networking
resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.ecommerce_eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}