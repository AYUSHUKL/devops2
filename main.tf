provider "aws" {
  region = "us-east-1"
  access_key = "AKIAZI2LDMNXXVZVYFY2"
  secret_key = "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"
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
  filename      = "path/to/your/add_employee_lambda.zip" # Update with the path to your Lambda function code
  function_name = "addEmployeeProfile"
  handler       = "index.handler"
  runtime       = "nodejs14.x" # Update with your runtime
  role          = aws_iam_role.lambda_exec.arn
  
  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.employee_profile.name
    }
  }
}

# Lambda function for getting an employee profile
resource "aws_lambda_function" "getEmployeeProfile" {
  filename      = "path/to/your/get_employee_lambda.zip" # Update with the path to your Lambda function code
  function_name = "getEmployeeProfile"
  handler       = "index.handler"
  runtime       = "nodejs14.x" # Update with your runtime
  role          = aws_iam_role.lambda_exec.arn
  
  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.employee_profile.name
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
  integration_http_method = "POST"
  uri                     = aws_lambda_function.getEmployeeProfile.invoke_arn
type                    = "AWS_PROXY"  # Add this line
}

# API Gateway method for addEmployeeProfile function
resource "aws_api_gateway_method" "add_employee_method" {
  rest_api_id   = aws_api_gateway_rest_api.employee_api.id
  resource_id   = aws_api_gateway_resource.add_employee_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# API Gateway method for getEmployeeProfile function
resource "aws_api_gateway_method" "get_employee_method" {
  rest_api_id   = aws_api_gateway_rest_api.employee_api.id
  resource_id   = aws_api_gateway_resource.get_employee_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# API Gateway deployment
resource "aws_api_gateway_deployment" "employee_api_deployment" {
  depends_on   = [aws_api_gateway_integration.add_employee_integration, aws_api_gateway_integration.get_employee_integration]
  rest_api_id  = aws_api_gateway_rest_api.employee_api.id
  stage_name   = "dev"
}

# IAM role for Lambda execution
resource "aws_iam_role" "lambda_exec" {
  name               = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action    = "sts:AssumeRole"
      },
    ]
  })
}

# IAM policy for Lambda execution role
resource "aws_iam_policy" "lambda_exec_policy" {
  name        = "lambda_exec_policy"
  description = "Policy for Lambda execution role"
  
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "dynamodb:PutItem"
        Resource = aws_dynamodb_table.employee_profile.arn
      },
      {
        Effect   = "Allow"
        Action   = "dynamodb:GetItem"
        Resource = aws_dynamodb_table.employee_profile.arn
      },
      # Add more permissions as needed
    ]
  })
}

# Attach policy to Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_exec_policy_attachment" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_exec_policy.arn
}

