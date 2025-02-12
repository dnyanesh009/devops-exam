
# Configure the Terraform backend with an S3 bucket

terraform {
  backend "s3" {
    bucket = "467.devops.candidate.exam"
    key    = "Ankita.Ghadage1"  # Replace with your full name
    region = "ap-south-1"
  }
}

# -----------------------------
# Network Resources
# -----------------------------
# Private Subnet
resource "aws_subnet" "pvt_subnet" {
  vpc_id            = data.aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = false
  
  tags = {
    Name = "Private Subnet for Lambda"
  }
}

# Route Table for Private Subnet
resource "aws_route_table" "pvt_rt" {
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
  subnet_id      = aws_subnet.pvt_subnet.id
  route_table_id = aws_route_table.pvt_rt.id
}

# -----------------------------
# Security Group
# -----------------------------
# Security Group for Lambda
resource "aws_security_group" "lambda_sg1" {
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

# Archive Lambda function code into a zip
data "archive_file" "create_lambda_pkg" {
  type        = "zip"
  source_dir  = "lambda"  # Directory containing your Lambda code (e.g., lambda/lambda_function.py)
  output_path = "${path.module}/lambda_function.zip"
}

# -----------------------------
# Lambda Function
# -----------------------------

resource "aws_lambda_function" "example_lambda1" {
  filename      = data.archive_file.create_lambda_pkg.output_path
  function_name =  "ankita-ghadage-test1" 
  runtime       = "python3.12"
  role          = data.aws_iam_role.lambda.arn
  handler       = "lambda_function.lambda_handler"
  timeout       = 30
  source_code_hash = data.archive_file.create_lambda_pkg.output_base64sha256

  environment {
    variables = {
      LOG_LEVEL = "INFO"
      PRIVATE_SUBNET_ID = resource.aws_subnet.id
    }
  }

  vpc_config {
    subnet_ids         = [aws_subnet.pvt_subnet.id]
    security_group_ids = [aws_security_group.lambda_sg1.id]
  }

  tags = {
    Name = "Lambda in Private Subnet"
  }
}

# -----------------------------
# Outputs
# -----------------------------
output "subnet_id" {
  value = aws_subnet.pvt_subnet.id
}

output "lambda_arn" {
  value = aws_lambda_function.example_lambda1.arn
}

output "security_group_id" {
  value = aws_security_group.lambda_sg.id
}
