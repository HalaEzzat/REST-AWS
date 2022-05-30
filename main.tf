terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda-function-executor"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
// zip the code
data "archive_file" "zip" {
  type        = "zip"
  source_file = "output/main"
  output_path = "output/function.zip"
}
resource "aws_lambda_function" "hello-world" {
  function_name     = "gettingstarted"
  handler           = "main"
  runtime           = "go1.x"
  role              = aws_iam_role.lambda_exec.arn
  filename          = data.archive_file.zip.output_path
  source_code_hash  = data.archive_file.zip.output_base64sha256
  memory_size       = 128
  timeout           = 10
}
resource "aws_lambda_permission" "allow_api" {
  statement_id  = "AllowAPIgatewayInvokation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello-world.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_api_gateway_rest_api" "helloapi" {
  name = "apitest"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "hello" {
  rest_api_id = aws_api_gateway_rest_api.helloapi.id
  parent_id   = aws_api_gateway_rest_api.helloapi.root_resource_id
  path_part   = "hello"
}

// POST
resource "aws_api_gateway_method" "post" {
  rest_api_id       = aws_api_gateway_rest_api.helloapi.id
  resource_id       = aws_api_gateway_resource.hello.id
  http_method       = "POST"
  authorization     = "NONE"
  api_key_required  = false
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.helloapi.id
  resource_id             = aws_api_gateway_resource.hello.id
  http_method             = aws_api_gateway_method.post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.hello-world.invoke_arn
}
// GET
resource "aws_api_gateway_method" "get" {
  rest_api_id       = aws_api_gateway_rest_api.helloapi.id
  resource_id       = aws_api_gateway_resource.hello.id
  http_method       = "GET"
  authorization     = "NONE"
  api_key_required  = false
}

resource "aws_api_gateway_integration" "integration-get" {
  rest_api_id             = aws_api_gateway_rest_api.helloapi.id
  resource_id             = aws_api_gateway_resource.hello.id
  http_method             = aws_api_gateway_method.get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.hello-world.invoke_arn
}
resource "aws_api_gateway_deployment" "deployment1" {
  rest_api_id = aws_api_gateway_rest_api.helloapi.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.helloapi.body))
  }

  depends_on = [aws_api_gateway_integration.integration]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "example" {
  deployment_id = aws_api_gateway_deployment.deployment1.id
  rest_api_id   = aws_api_gateway_rest_api.helloapi.id
  stage_name    = "dev-01"
}
output "complete_unvoke_url"   {value = "${aws_api_gateway_deployment.deployment1.invoke_url}${aws_api_gateway_stage.example.stage_name}/${aws_api_gateway_resource.hello.path_part}"}
