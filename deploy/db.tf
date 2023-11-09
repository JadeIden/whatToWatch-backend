resource "aws_dynamodb_table" "items-table-prod" {
  name = "Items-prod"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "itemId"

  attribute {
    name = "itemId"
    type = "S"
  }

  tags = {
    Name = "Items-table-prod"
    Environment = "prod"
  }
}