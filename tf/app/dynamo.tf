resource "aws_dynamodb_table" "todos" {
  name         = "todo-kubernetes_todos"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "username"
  range_key    = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "username"
    type = "S"
  }
}

resource "aws_dynamodb_table" "users" {
  name         = "todo-kubernetes_users"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "username"

  attribute {
    name = "username"
    type = "S"
  }
}
