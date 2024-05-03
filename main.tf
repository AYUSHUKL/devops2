provider "aws" {
  region     = "us-east-1"
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
  filename      = "add_employee_lambda.zip" # Updated path
  function_name = "addEmployeeProfile"
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  role          = aws_iam_role.lambda_exec.arn
  
  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.employee_profile.name
    }
  }
}

# Lambda function for getting an employee profile
resource "aws_lambda_function" "getEmployeeProfile" {
  filename      = "get_employee_lambda.zip" # Updated path
  function_name = "getEmployeeProfile"
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  role          = aws_iam_role.lambda_exec.arn
  
  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.employee_profile.name
    }
  }
}

# Rest of your Terraform configuration remains unchanged...
