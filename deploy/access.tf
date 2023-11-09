data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "access_dynamodb_from_lambda" {
  name = "lambda-dynamodb-policy"
  role = aws_iam_role.iam_for_lambda.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "AllowLambdaDynamodbAccess",
        "Effect": "Allow",
        "Action": [
          "dynamodb:DescribeTable"
        ]
        "Resource": "${aws_dynamodb_table.items-table-prod.arn}"
      }
    ]
  })
}

resource "aws_lambda_permission" "api-gateway-invoke-lambda-prod" {
  for_each = {
    for idx, item in local.methods:
    item.functionName => item
  }

  statement_id  = "AllowAPIGatewayInvokeProd"
  action        = "lambda:InvokeFunction"
  function_name = "${each.key}_prod"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the specified API Gateway.
  source_arn = "${aws_api_gateway_rest_api.openapi-api-gateway-prod.execution_arn}/*/*"
}