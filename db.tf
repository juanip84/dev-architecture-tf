// RDS
resource "aws_security_group" "group-rds" {
  name        = "photopremium-rds-group"
  vpc_id      = var.vpc-id
  description = "photopremium sg group"

  revoke_rules_on_delete = true

  tags = {
    Name = "photopremium-rds-group"
  }

  lifecycle {
    ignore_changes = [name, vpc_id]
  }
}

resource "aws_security_group_rule" "group-rds" {
  from_port         = "3306"
  security_group_id = aws_security_group.group-rds.id
  cidr_blocks       = ["0.0.0.0/0"]
  protocol          = "tcp"
  to_port           = "3306"
  type              = "ingress"
}

resource "aws_security_group_rule" "group-rds-1" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = "0"
  security_group_id = aws_security_group.group-rds.id
  protocol          = "-1"
  to_port           = "0"
  type              = "egress"
}

resource "aws_db_subnet_group" "backend-db-subnet-group" {
  name_prefix = "photopremium-db-subnet-group"
  description = "Database subnet group for backend rds"

  subnet_ids = [
    var.subnet-a,
    var.subnet-b
  ]
}

resource "aws_db_instance" "backend-db" {
  identifier             = "photopremium-db"
  name                   = var.BACK_DB_MAIN_NAME
  username               = var.db_root_username
  password               = var.db_root_password
  engine                 = "mysql"
  instance_class         = var.rds_db_type
  iops                   = var.rds_db_iops
  publicly_accessible    = var.db_publicly_accessible
  skip_final_snapshot    = "true"
  vpc_security_group_ids = [aws_security_group.group-rds.id]
  multi_az               = var.db_multi_az
  availability_zone      = var.db_az
  port                   = 3306
  storage_type           = var.rds_db_storage_type
  allocated_storage      = var.db_storage
  db_subnet_group_name   = aws_db_subnet_group.backend-db-subnet-group.id
}