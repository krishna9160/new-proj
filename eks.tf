############################
# Use default VPC
############################
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

############################
# EKS Cluster
############################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  cluster_name    = "simple-eks"
  cluster_version = "1.29"

  vpc_id     = data.aws_vpc.default.id
  subnet_ids = data.aws_subnets.default.ids

  # ✅ Public endpoint (kubectl works)
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  # ✅ Avoid KMS permission issues
  create_kms_key = false

  # ✅ Terraform manages aws-auth
  manage_aws_auth_configmap = true

  # ✅ Give kubectl admin access automatically
  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::486036174583:user/admin-user"
      username = "admin-user"
      groups   = ["system:masters"]
    }
  ]

  ############################
  # Node Group
  ############################
  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.small"]
      ami_type       = "AL2_x86_64"
      desired_size   = 2
      min_size       = 1
      max_size       = 3
    }
  }
}
``
