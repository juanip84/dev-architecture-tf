####SET REGION #############################################
provider "aws" {
  region = "us-east-2"
}

#### Network ####
variable vpc-id {
  type    = string
  default = "vpc-41f1da29"
}

variable subnet-a {
  type    = string
  default = "subnet-824c11ea"
}

variable subnet-b {
  type    = string
  default = "subnet-a75bd0dd"
}

### DB config
variable rds_db_type {
  type    = string
  default = "db.t2.micro"
}

variable rds_db_iops {
  type    = string
  default = "0"
}

variable rds_db_storage_type {
  type    = string
  default = "gp2"
}

variable db_root_username {
  type    = string
  default = "photopremium_root"
}

variable db_root_password {
  type    = string
  default = "AA**123456"
}

variable db_az {
  type    = string
  default = "us-east-2b"
}

variable db_multi_az {
  type    = string
  default = "false"
}

variable db_storage {
  type    = string
  default = "200"
}

variable db_publicly_accessible {
  type    = string
  default = "true"
}

####VARIABLES CERTIFICATES#############
variable certificate_arn_front {
  type    = string
  default = "arn:aws:acm:us-east-1:001565017283:certificate/cf2d2bf4-0a8d-47f2-a0f0-220d422c583c"
}

variable certificate_arn_back {
  type    = string
  default = "arn:aws:acm:us-east-2:001565017283:certificate/6359e8bd-e8da-445e-94a3-40219f39614b"
}

## s3
variable images-s3-name {
  type    = string
  default = "photopremium-dev-images"
}

### backend-api vars
variable NODE_ENV {
  type    = string
  default = "dev"
}

variable BACK_DB_MAIN_USER {
  type    = string
  default = "api_user"
}

variable BACK_DB_MAIN_PASS {
  type    = string
  default = "user_AA**123456"
}

variable BACK_DB_MAIN_NAME {
  type    = string
  default = "photopremium"
}

variable BACK_TOKEN_SECRET {
  type    = string
  default = "kfgqwersdfg"
}

variable BACK_API_CPU {
  type    = string
  default = "1024"
}

variable BACK_API_MEMORY {
  type    = string
  default = "2048"
}

// cloudfront dns
variable cloudfront_dns {
  type    = string
  default = "photopremium.outsidecube.com"
}

// bucket acl
variable s3_bucket_acl {
  type    = string
  default = "private"
}