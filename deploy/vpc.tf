data "aws_vpc" "vpc" {
  id = "vpc-cdab70a8"
}

data "aws_subnet_ids" "subnets" {
  vpc_id = data.aws_vpc.vpc.id
}

data "aws_security_group" "security_group" {
  id = "sg-03d2fa33cd06edbdf"
}
