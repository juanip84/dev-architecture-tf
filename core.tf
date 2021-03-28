#### Core ####

// cluster
resource "aws_ecs_cluster" "photopremium-cluster" {
  name = "photopremium-cluster"
}

//ROLES
resource "aws_iam_role" "ecs_role" {
  name        = "photopremium_ecs_role"
  description = "Photopremium ecs role"

  assume_role_policy = <<EOF
{
    "Version":"2012-10-17",
    "Statement":[
        {
            "Effect":"Allow",
            "Principal":{"Service":"ec2.amazonaws.com"},
            "Action":"sts:AssumeRole"
            }
    ]
}
  EOF
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name        = "PhotoPremiumEcsTaskExecutionRole"
  description = ""

  assume_role_policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
            "Service": "ecs-tasks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "ecsTaskExecutionRole-policy" {
  name = "photopremiumEcsTaskExecutionRole-policy"
  role = aws_iam_role.ecsTaskExecutionRole.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
  {
      "Effect": "Allow",
      "Action": [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
      ],
      "Resource": "*"
  }
  ]
}
EOF
}

// Security groups
resource "aws_security_group" "group-https" {
    name        = "photopremium-https"
    vpc_id      = var.vpc-id
    description = "https security group"

    tags = {
        Name = "photopremium-https"
    }
}

resource "aws_security_group_rule" "group-https" {
    from_port         = "0"
    security_group_id = aws_security_group.group-https.id
    cidr_blocks       = ["0.0.0.0/0"]
    protocol          = "-1"
    to_port           = "0"
    type              = "egress"
}

resource "aws_security_group_rule" "group-https-1" {
    cidr_blocks       = ["0.0.0.0/0"]
    from_port         = "443"
    security_group_id = aws_security_group.group-https.id
    protocol          = "tcp"
    to_port           = "443"
    type              = "ingress"
}

#### end Core ####

