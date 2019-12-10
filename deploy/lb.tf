module "lb_logs" {
  source          = "git::https://github.com/cloudposse/terraform-aws-lb-s3-bucket.git?ref=0.2.0"
  name      = "${var.repo_name}-${var.branch_name}-lb"
  namespace = local.namespace
  stage     = local.stage
  region = var.aws_region

  force_destroy = "true"

  tags = module.tags.tags
}

resource "aws_lb" "main" {
  name            = "${var.repo_name}-${var.branch_name}"
  security_groups = [aws_security_group.security_group.id]
  subnets         = data.aws_subnet_ids.subnets.ids
  # todo internal only
  internal        = false

  # todo https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/enable-access-logs.html#attach-bucket-policy
  access_logs {
    enabled = true
    bucket  = module.lb_logs.bucket_id
  }

  tags   = module.tags.tags
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

#data "aws_acm_certificate" "cert" {
#  domain   = "*.alteredco.com"
#}

resource "aws_lb_listener" "https" {
  load_balancer_arn = "${aws_lb.main.arn}"
  port              = "443"
  protocol          = "HTTPS"
  #certificate_arn   = data.aws_acm_certificate.cert.arn
  certificate_arn = "arn:aws:acm:us-east-1:021370510137:certificate/b5933088-78d3-46b4-bf44-efd582040c14"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.ecs_https.arn
  }
}