
# Configure the Terraform backend with an S3 bucket

terraform {
  backend "s3" {
    bucket = "467.devops.candidate.exam"
    key    = "Ankita.Ghadage"  # Replace with your full name
    region = "ap-south-1"
  }
}

# -----------------------------
# Data Sources
# -----------------------------
# NAT Gateway
data "aws_nat_gateway" "nat" {
  id = "nat-0a34a8efd5e420945"
}

# VPC
data "aws_vpc" "vpc" {
  id = "vpc-06b326e20d7db55f9"
}

# Lambda IAM Role
data "aws_iam_role" "lambda" {
  name = "DevOps-Candidate-Lambda-Role"
}

# -----------------------------
# Network Resources
# -----------------------------
# Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = data.aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = false
  
  tags = {
    Name = "Private Subnet for Lambda"
  }
}

# Route Table for Private Subnet
resource "aws_route_table" "private_rt" {
  vpc_id = data.aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_nat_gateway.nat.id
  }
  
  tags = {
    Name = "Private Route Table"
  }
}

# Route Table Association
resource "aws_route_table_association" "private_rt_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

# -----------------------------
# Security Group
# -----------------------------
# Security Group for Lambda
resource "aws_security_group" "lambda_sg" {
  vpc_id      = data.aws_vpc.vpc.id
  name        = "lambda-sg"
  description = "Allow Lambda to access NAT Gateway"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Lambda Security Group"
  }
}

# -----------------------------
# Lambda Function
# -----------------------------
resource "aws_lambda_function" "example_lambda" {
  function_name = "PrivateSubnetLambda"
  runtime       = "python3.9"
  role          = data.aws_iam_role.lambda.arn
  handler       = "lambda_function.lambda_handler"
  timeout       = 30

  # Lambda code (simple hello world)
  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {
      LOG_LEVEL = "INFO"
    }
  }

  vpc_config {
    subnet_ids         = [aws_subnet.private_subnet.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  tags = {
    Name = "Lambda in Private Subnet"
  }
}

# -----------------------------
# Outputs
# -----------------------------
output "subnet_id" {
  value = aws_subnet.private_subnet.id
}

output "lambda_arn" {
  value = aws_lambda_function.example_lambda.arn
}

output "security_group_id" {
  value = aws_security_group.lambda_sg.id
}
