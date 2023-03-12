provider "aws" {
  region = "us-east-1"
}

resource "aws_lambda_function" "current_time_lambda" {
  filename         = "lambda.zip"
  function_name    = "udacity_lambda_function"
  role             = aws_iam_role.lambda.arn
  handler          = "lambda.lambda_handler"
  source_code_hash = filebase64sha256("lambda.zip")
  runtime          = "python3.8"
}

resource "aws_iam_role" "lambda" {
  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda" {
  name       = "lambda_attachment"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  roles      = [aws_iam_role.lambda.name]
}

resource "aws_apigatewayv2_api" "udacity_api_gateway" {
  name          = "udacity_api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "udacity_lambda_integration" {
  api_id             = aws_apigatewayv2_api.udacity_api_gateway.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.current_time_lambda.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "udacity_lambda_route" {
  api_id    = aws_apigatewayv2_api.udacity_api_gateway.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.udacity_lambda_integration.id}"
}

resource "aws_dynamodb_table" "udacity_dynamodb_table" {
  name           = "udacity"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  attribute {
    name = "id"
    type = "S"
  }
}