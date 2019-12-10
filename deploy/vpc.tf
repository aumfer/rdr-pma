data "aws_vpc" "vpc" {
  id = "vpc-cdab70a8"
}

data "aws_subnet_ids" "subnets" {
  vpc_id = data.aws_vpc.vpc.id
}

resource "aws_security_group" "security_group" {
  vpc_id = data.aws_vpc.vpc.id
  name   = module.tags.id
  tags   = module.tags.tags
}
