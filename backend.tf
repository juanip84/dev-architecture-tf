#### Backend ####

// Backend SECURITY GROUPS
resource "aws_security_group" "group-backend" {
    name        = "photopremium-backend-api"
    vpc_id      = var.vpc-id
    description = "Photopremium backend API"

    tags = {
    Name = "photopremium-backend-api"
    }
}

resource "aws_security_group_rule" "group-backend1" {
    cidr_blocks       = ["0.0.0.0/0"]
    from_port         = "0"
    security_group_id = aws_security_group.group-backend.id
    protocol          = "-1"
    to_port           = "0"
    type              = "egress"
}

resource "aws_security_group_rule" "group-backend2" {
    from_port         = "3000"
    security_group_id = aws_security_group.group-backend.id
    cidr_blocks       = ["0.0.0.0/0"]
    protocol          = "tcp"
    to_port           = "3000"
    type              = "ingress"
}

// role for backend (using full s3 for now, to be limited later)
resource "aws_iam_role" "backend-api-role" {
  name = "backend-api-role"
  path = "/"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "backend-api-role-att" {
  role       = aws_iam_role.backend-api-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

// s3 bucket for images upload/download (with presigned urls)
resource "aws_s3_bucket" "images-s3" {
  bucket = var.images-s3-name
  acl    = ""

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = [
      "PUT",
      "POST",
      "DELETE",
      "GET",
    ]
    allowed_origins = ["*"]
    expose_headers  = [] 
    max_age_seconds = 0
  }
}

resource "aws_s3_bucket_public_access_block" "images-s3-public-policy" {
  bucket = aws_s3_bucket.images-s3.id

  block_public_acls   = false
  block_public_policy = true
  restrict_public_buckets = true
}

//ECR REPOSITORY
resource "aws_ecr_repository" "ecr-backend" {
    name = "photopremium-backend-api"
}

//LOAD Balancer
resource "aws_lb" "lb-backend-api" {
    name               = "photopremium-backend-api"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.group-https.id]
    subnets            = [var.subnet-a, var.subnet-b]
}

resource "aws_lb_target_group" "ecs-backend-target" {
  name                 = "photopremium-backend-target"
  port                 = 3000
  protocol             = "HTTP"
  target_type          = "ip"
  deregistration_delay = "60"
  vpc_id               = var.vpc-id

  health_check {
    interval            = 30
    path                = "/health"
    port                = "3000"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    protocol            = "HTTP"
    matcher             = "200"
  }
}

resource "aws_lb_listener" "listener_lb-backend-api-https" {
  load_balancer_arn = aws_lb.lb-backend-api.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn_back

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs-backend-target.arn
  }
}


//ECS resources

resource "aws_ecs_service" "backend-api-service" {
  name    = "photopremium-backend-service"
  cluster = aws_ecs_cluster.photopremium-cluster.arn

  task_definition                    = "${aws_ecs_task_definition.backend-task-definition1.family}:${aws_ecs_task_definition.backend-task-definition1.revision}" //"ps-task-definition:9"
  desired_count                      = 1
  launch_type                        = "FARGATE"
  deployment_maximum_percent         = "200"
  deployment_minimum_healthy_percent = "50"

  network_configuration {
    assign_public_ip = true
    subnets         = [var.subnet-a, var.subnet-b]
    security_groups = [aws_security_group.group-backend.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs-backend-target.arn
    container_name   = "backend-container"
    container_port   = 3000
  }

  lifecycle {
    ignore_changes = [placement_strategy]
  }
}

resource "aws_cloudwatch_log_group" "backend-log-group" {
    name = "/ecs/photopremium/photompremium-backend-api-logs"

    tags = {
    Environment = "dev"
    Application = "Backend API"
    }
}

resource "aws_ecs_task_definition" "backend-task-definition1" {
  family                   = "photopremium-backend-api-td"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.BACK_API_CPU
  memory                   = var.BACK_API_MEMORY

  task_role_arn            = aws_iam_role.backend-api-role.arn

  execution_role_arn = aws_iam_role.ecsTaskExecutionRole.arn

  container_definitions = <<DEFINITION
[
{
  "cpu": 0,
  "essential": true,
  "image": "${aws_ecr_repository.ecr-backend.repository_url}:latest",
	"name": "backend-container",
	"essential":true,
	"portMappings":[
	{
        "hostPort": 3000,
        "protocol": "tcp",
        "containerPort": 3000
  }
	],
	"mountPoints":[],
	"volumesFrom":[],
	"logConfiguration": {
		"logDriver":"awslogs",
		"options":{
			"awslogs-group":"/ecs/photopremium/photompremium-backend-api-logs",
			"awslogs-region":"us-east-2",
			"awslogs-stream-prefix":"ecs"
		}
	},
	"environment": [
	      {
          "name": "NODE_ENV",
          "value": "${var.NODE_ENV}"
        },
        {
          "name": "DB_MAIN_HOST",
          "value": "${aws_db_instance.backend-db.address}"
        },
        {
          "name": "DB_MAIN_USER",
          "value": "${var.BACK_DB_MAIN_USER}"
        },
	      {
          "name": "DB_MAIN_PASS",
          "value": "${var.BACK_DB_MAIN_PASS}"
        },
		    {
          "name": "DB_MAIN_NAME",
          "value": "${var.BACK_DB_MAIN_NAME}"
        },
        {
          "name": "TOKEN_SECRET",
          "value": "${var.BACK_TOKEN_SECRET}"
        },
        {
          "name": "S3_URL",
          "value": "http://localhost:4566/"
        },
        {
          "name": "S3_BUCKET_NAME",
          "value": "${var.images-s3-name}"
        }
	]
}		
]
DEFINITION
}

#### End backend ####