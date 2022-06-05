data "aws_vpc" "main" {
  tags = {
    "project" = "cluster-1"
  }
}

data "aws_subnets" "main" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}
