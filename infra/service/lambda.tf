resource "aws_iam_role" "lambda_role" {
  name = "${var.scope}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment_xray" {
  role = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

variable "lambda_source" {
  default = "../../target/lambda.zip"
}

resource "aws_lambda_function" "lambda" {
  source_code_hash = filebase64sha256(var.lambda_source)
  filename = var.lambda_source
  function_name = "${var.scope}-lambda"
  role = aws_iam_role.lambda_role.arn
  handler = "my_lambda/handler.handle_event"
  runtime = "python3.8"
  memory_size = 512
  timeout = 30
  tracing_config {
    mode = "Active"
  }
  environment {
    variables = {
      SCOPE = var.scope
      COMMITISH = var.commitish
    }
  }
  tags = {
    scope = "${var.scope}"
  }
  depends_on = [
    aws_iam_role_policy_attachment.lambda_policy_attachment
  ]
}
