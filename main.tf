# Define AWS provider
provider "aws" {
  region = "us-east-1"
}

# Define DynamoDB table for employee profiles
resource "aws_dynamodb_table" "employee_profile" {
  name           = "EmployeeProfiles"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "employee_id"
  attribute {
    name = "employee_id"
    type = "S"
  }
  # Add more attributes as needed
}

# Define API Gateway REST API
resource "aws_api_gateway_rest_api" "employee_api" {
  name        = "EmployeeAPI"
  description = "API for managing employee profiles"
}

# Define API Gateway resources
resource "aws_api_gateway_resource" "add_employee_resource" {
  rest_api_id = aws_api_gateway_rest_api.employee_api.id
  parent_id   = aws_api_gateway_rest_api.employee_api.root_resource_id
  path_part   = "addEmployee"
}

resource "aws_api_gateway_resource" "get_employee_resource" {
  rest_api_id = aws_api_gateway_rest_api.employee_api.id
  parent_id   = aws_api_gateway_rest_api.employee_api.root_resource_id
  path_part   = "getEmployee"
}

# Define API Gateway methods
resource "aws_api_gateway_method" "add_employee_method" {
  rest_api_id   = aws_api_gateway_rest_api.employee_api.id
  resource_id   = aws_api_gateway_resource.add_employee_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "get_employee_method" {
  rest_api_id   = aws_api_gateway_rest_api.employee_api.id
  resource_id   = aws_api_gateway_resource.get_employee_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# Define API Gateway deployment
resource "aws_api_gateway_deployment" "employee_api_deployment" {
  depends_on   = [aws_api_gateway_method.add_employee_method, aws_api_gateway_method.get_employee_method]
  rest_api_id  = aws_api_gateway_rest_api.employee_api.id
  stage_name   = "dev"
}

# Add more resources and configurations as needed
