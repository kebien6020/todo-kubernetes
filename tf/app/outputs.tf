output "vpc" {
  value = data.aws_vpc.main.arn
}

output "connection_string" {
  sensitive = true
  value = format(
    "postgresql://%s:%s@%s/%s",
    aws_db_instance.main.username,
    urlencode(aws_db_instance.main.password),
    aws_db_instance.main.endpoint,
    aws_db_instance.main.db_name,
  )
}

output "connection_string_ro" {
  sensitive = true
  value = format(
    "postgresql://%s:%s@%s/%s",
    aws_db_instance.main.username,
    urlencode(aws_db_instance.main.password),
    aws_db_instance.main.endpoint, # Change to read-replica when available
    aws_db_instance.main.db_name,
  )
}
