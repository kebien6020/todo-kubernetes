resource "aws_db_instance" "main" {
  allocated_storage       = 20
  engine                  = "postgres"
  instance_class          = "db.t3.micro"
  db_name                 = "todo_kubernetes"
  username                = random_pet.db-user.id
  password                = random_password.db-pass.result
  backup_retention_period = 5
  backup_window           = "07:00-09:00"

  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.db.name

  apply_immediately   = true
  skip_final_snapshot = true

  depends_on = [aws_db_subnet_group.db]
}

# resource "aws_db_instance" "read-replica" {
#   replicate_source_db = aws_db_instance.main.identifier
#   instance_class      = "db.t3.micro"
#
#   vpc_security_group_ids = [aws_security_group.db.id]
#   db_subnet_group_name   = aws_db_subnet_group.db.name
#
#   apply_immediately   = true
#   skip_final_snapshot = true
#
#   depends_on = [aws_db_subnet_group.db]
# }

resource "random_pet" "db-user" {
  separator = "_"
}

resource "random_password" "db-pass" {
  length = 32
}

resource "aws_security_group" "db" {
  name        = "todo-kubernetes-db"
  description = "todo-kubernetes project DB"
  vpc_id      = data.aws_vpc.main.id

  # Postgres from nodes
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [data.aws_security_group.kube-nodes.id]
  }

  # Postgres from read replicas
  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    self      = true
  }

  # Allow outbound to internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_security_group" "kube-nodes" {
  name = "kube-cluster-node"
}

resource "aws_db_subnet_group" "db" {
  name       = "todo-kubernetes-db"
  subnet_ids = data.aws_subnets.main.ids
}
