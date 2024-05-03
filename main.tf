provider "aws" {
  region = "us-east-1"
  access_key = "AKIAZI2LDMNXXVZVYFY2"
  secret_key = "lLINm2VF5caGBP6bAUzPShVnYtFYElBar837gQGk"
}

# Define AWS provider
provider "aws" {
  region = "us-east-1"
  access_key = "YOUR_ACCESS_KEY"
  secret_key = "YOUR_SECRET_KEY"
}

# DynamoDB table for employee profiles
resource "aws_dynamodb_table" "employee_profile" {
  name         = "employee_profile"
  billing_mode = "PAY_PER_REQUEST"
  
  hash_key = "employee_id"
  
  attribute {
    name = "employee_id"
    type = "S"
  }
}

# Lambda function for adding an employee
resource "aws_lambda_function" "addEmployeeProfile" {
  filename      = "devops2/add_employee_lambda.zip" # Path to your Lambda function code
  function_name = "addEmployeeProfile"
  handler       = "index.handler"
  runtime       = "nodejs14.x" # Update with your runtime
  role          = aws_iam_role.lambda_exec.arn
  
  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.employee_profile.name
    }
  }
}

# Lambda function for getting an employee profile
resource "aws_lambda_function" "getEmployeeProfile" {
  filename      = "devops2/get_employee_lambda.zip" # Path to your Lambda function code
  function_name = "getEmployeeProfile"
  handler       = "index.getempprofile"
  runtime       = "nodejs14.x" # Update with your runtime
  role          = aws_iam_role.lambda_exec.arn
  
  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.employee_profile.name
    }
  }
}

# API Gateway REST API
resource "aws_api_gateway_rest_api" "employee_api" {
  name = "employee_api"
}

# API Gateway resource for addEmployeeProfile function
resource "aws_api_gateway_resource" "add_employee_resource" {
  rest_api_id = aws_api_gateway_rest_api.employee_api.id
  parent_id   = aws_api_gateway_rest_api.employee_api.root_resource_id
  path_part   = "addEmployeeProfile"
}

# API Gateway resource for getEmployeeProfile function
resource "aws_api_gateway_resource" "get_employee_resource" {
  rest_api_id = aws_api_gateway_rest_api.employee_api.id
  parent_id   = aws_api_gateway_rest_api.employee_api.root_resource_id
  path_part   = "getEmployeeProfile"
}

# Integration between addEmployeeProfile Lambda and API Gateway
resource "aws_api_gateway_integration" "add_employee_integration" {
  rest_api_id             = aws_api_gateway_rest_api.employee_api.id
  resource_id             = aws_api_gateway_resource.add_employee_resource.id
  http_method             = "POST"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.addEmployeeProfile.invoke_arn
  type                    = "AWS_PROXY"  # Add this line
}

# Integration between getEmployeeProfile Lambda and API Gateway
resource "aws_api_gateway_integration" "get_employee_integration" {
  rest_api_id             = aws_api_gateway_rest_api.employee_api.id
  resource_id             = aws_api_gateway_resource.get_employee_resource.id
  http_method             = "GET"
  integration_http_me

