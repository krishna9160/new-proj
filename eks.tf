data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  cluster_name    = "simple-eks"
  

  vpc_id     = data.aws_vpc.default.id
  subnet_ids = data.aws_subnets.default.ids

  # ✅ FORCE PUBLIC API ACCESS
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  # ✅ DO NOT manage aws-auth from Terraform
  manage_aws_auth_configmap = false

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.small"]
      ami_type       = "AL2_x86_64"
      desired_size   = 2
      min_size       = 2
      max_size       = 3
    }
  }
}
