module "www" {
  source           = "git::https://github.com/cloudposse/terraform-aws-route53-alias.git?ref=0.3.0"
  aliases          = ["${var.branch_name}.${var.repo_name}.alteredco.com"]
  parent_zone_name = "alteredco.com."
  target_dns_name  = aws_lb.main.dns_name
  target_zone_id   = aws_lb.main.zone_id
}
