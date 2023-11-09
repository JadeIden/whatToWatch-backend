locals {
  methods = [
    {
      method = "app.listItems"
      functionName = "whatToWatch_listItems"
      path = "/items"
    },
    {
      method = "app.createItem",
      functionName = "whatToWatch_createItem"
      path = "/items/new"
    },
    {
      method = "app.showItemById",
      functionName = "whatToWatch_showItemById"
      path = "/items/{id}"
    }
  ]
}

data "template_file" "openapi_api_yaml_prod" {
  template = "${file("../api/api.yaml")}"

  vars = {
    listItemsArn = aws_lambda_function.whatToWatch_prod_lambda["whatToWatch_listItems"].arn
    createItemArn = aws_lambda_function.whatToWatch_prod_lambda["whatToWatch_createItem"].arn
    showItemsArn = aws_lambda_function.whatToWatch_prod_lambda["whatToWatch_showItemById"].arn
    aws_region = "us-east-2"
  }
}

data "archive_file" "lambda_backend" {
  type = "zip"

  source_dir = "../src"
  output_path = "../build/source.zip"
}


resource "aws_lambda_function" "whatToWatch_prod_lambda" {
  for_each = {
    for index, item in local.methods:
      item.functionName => item
  }

  filename = data.archive_file.lambda_backend.output_path
  function_name = "${each.value.functionName}_prod"
  role = aws_iam_role.iam_for_lambda.arn
  handler = each.value.method

  source_code_hash = data.archive_file.lambda_backend.output_base64sha256

  runtime = "python3.9"
}

resource "aws_api_gateway_rest_api" "openapi-api-gateway-prod" {
  name           = "WhatToWatch-prod"
  description    = "What to Watch backend -- production environment"
  api_key_source = "HEADER"
  body           = "${data.template_file.openapi_api_yaml_prod.rendered}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_stage" "api-gateway-stage-prod" {
  deployment_id = aws_api_gateway_deployment.api-gateway-deployment-prod.id
  rest_api_id   = aws_api_gateway_rest_api.openapi-api-gateway-prod.id
  stage_name    = "stage1"
}


resource "aws_api_gateway_deployment" "api-gateway-deployment-prod" {
  rest_api_id = aws_api_gateway_rest_api.openapi-api-gateway-prod.id

  lifecycle {
    create_before_destroy = true
  }
}