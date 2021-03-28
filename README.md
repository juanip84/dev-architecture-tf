# TF AWS scripts

This is a project for showing a small infrastructure scripts managed by terraform.

Services used:
- cloudfront: for serving frontend static files
- s3: for static files (frontend), and a bucket for images of the platform
- ecr: for docker images repository
- ecs: for orchestating dockerized backend
- rds: for mysql db
- security groups: external (https), and internal
- load balancer: for backend
- target group: being between LB and ECS

Services used but not managed by TF:
- ACM Certificate
- Networking: vpc, subnets
- route 53: for dns delegation

## Prerequisites

- terraform installed
- aws cli installed
- tfenv (not mandatory but recommended to able to use make set-version)

## tfstate
Used locally, if needed to be fully maintain will be stored remotely (s3)

## Commands

This version uses a makefile to run. Type make help to see all options.
First must be set the enviroment

For example:
make plan-all
make apply

If needed to set the version of tf use by the project (needed to have tfenv installed and proper tf), do first:
make set-version
