provider "aws" {
	profile = "default"
	region = "ap-south-1"
}

resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_eks_cluster" "aws_eks" {
	name = "hari_eks_cluster"
	role_arn = aws_iam_role.eks_cluster.arn
	
	vpc_config {
		subnet_ids = ["subnet-9a548ce1","subnet-3df06171","subnet-db0828b3"]
	}
	
	tags = {
		Name = "Hari_EKS"
	}
}

resource "aws_iam_role" "eks_nodes" {
  name = "eks-node-group-iam"

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

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_eks_node_group" "eks_nodes_1" {
	cluster_name = aws_eks_cluster.aws_eks.name
	node_group_name = "nodes_1"
	node_role_arn = aws_iam_role.eks_nodes.arn
	subnet_ids = ["subnet-9a548ce1","subnet-3df06171","subnet-db0828b3"]
  instance_types = ["t2.micro"]
  tags = {
    "Name" = "hari_eks_node_1"
  }
	
	scaling_config {
		desired_size = 1
		max_size = 2
		min_size = 1
	}
}

resource "aws_eks_node_group" "eks_nodes_2" {
	cluster_name = aws_eks_cluster.aws_eks.name
	node_group_name = "nodes_2"
	node_role_arn = aws_iam_role.eks_nodes.arn
	subnet_ids = ["subnet-9a548ce1","subnet-3df06171","subnet-db0828b3"]
  instance_types = ["t2.micro"]
  tags = {
    "Name" = "hari_eks_node_2"
  }
	
	scaling_config {
		desired_size = 1
		max_size = 1
		min_size = 1
	}
}

output "eks_cluster_endpoint" {
	value = aws_eks_cluster.aws_eks.endpoint
}

output "eks_cluster_certificate_authority" {
	value = aws_eks_cluster.aws_eks.certificate_authority
}
