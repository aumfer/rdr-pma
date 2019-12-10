resource "aws_cloudwatch_log_group" "container_logs" {
  name = "${var.repo_name}-${var.branch_name}"
  tags = module.tags.tags
}

module "container_definition" {
  source          = "git::https://github.com/cloudposse/terraform-aws-ecs-container-definition.git?ref=0.7.0"
  container_name  = "${var.repo_name}-${var.branch_name}"
  container_image = "${var.ecr_repo}:${var.repo_name}-${var.branch_name}-${var.source_rev}"

  log_options = {
    "awslogs-group"         = aws_cloudwatch_log_group.container_logs.name
    "awslogs-region"        = var.aws_region
    "awslogs-stream-prefix" = "ecs"
  }

  environment = [
    {
      name  = "app"
      value = var.repo_name
    },
    {
      name  = "env"
      value = var.branch_name
    },
    {
      name  = "sha"
      value = var.source_rev
    },
    {
      name = "REDIS_URL"
      # todo configuration management
      value = "rdr-pmp-git-master.vvthzk.0001.use1.cache.amazonaws.com"
    }
  ]
}

resource "aws_ecs_cluster" "cluster" {
  name = "${var.repo_name}-${var.branch_name}"
}

data "aws_iam_role" "ecs_role" {
  name = "radar"
}

resource "aws_ecs_task_definition" "default" {
  family                   = module.tags.id
  container_definitions    = module.container_definition.json
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = data.aws_iam_role.ecs_role.arn
  task_role_arn            = data.aws_iam_role.ecs_role.arn
  tags                     = module.tags.tags
}

resource "aws_security_group_rule" "allow_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.security_group.id
}

resource "aws_ecs_service" "default" {
  name            = module.tags.id
  task_definition = "${aws_ecs_task_definition.default.family}:${aws_ecs_task_definition.default.revision}"

  desired_count = 1

  launch_type = "FARGATE"

  cluster = aws_ecs_cluster.cluster.arn

  #enable_ecs_managed_tags = true
  tags = module.tags.tags
  propagate_tags = "SERVICE"

  network_configuration {
    security_groups  = ["${aws_security_group.security_group.id}"]
    subnets          = data.aws_subnet_ids.subnets.ids
    assign_public_ip = true
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}
