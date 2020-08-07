data "archive_file" "test" {
  type        = "zip"
  source_file = "index.js"
  output_path = "${path.module}/test_lambda_function.zip"
}

data "aws_ssm_parameter" "test_api_key" {
  name = "test_api_key"
}

data "aws_ssm_parameter" "test_private_key" {
  name = "test_private_key"
}

resource "aws_lambda_function" "example" {
  filename      = "test_lambda_function.zip"
  function_name = "test_function"
  handler       = "main.handler"
  runtime       = "nodejs10.x"
  role          = aws_iam_role.test_lambda_role.arn
  environment {
    variables = {
      API_KEY     = data.aws_ssm_parameter.test_api_key.value
      PRIVATE_KEY = data.aws_ssm_parameter.test_private_key.value
    }
  }
}

resource "aws_iam_role" "test_lambda_role" {
  name               = "test_lambda_role"
  assume_role_policy = <<EOF
 {
   "Version": "2012-10-17",
   "Statement": [
     {
       "Action": "sts:AssumeRole",
       "Principal": {
         "Service": "lambda.amazonaws.com"
       },
       "Effect": "Allow",
       "Sid": ""
     }
   ]
 }
 
EOF

}

