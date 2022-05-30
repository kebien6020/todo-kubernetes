resource "aws_vpc" "vpc" {
  cidr_block = "172.32.0.0/16"
}

resource "aws_subnet" "pub-a" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-east-1a"
  cidr_block        = "172.32.0.0/20"
}

resource "aws_subnet" "pub-b" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-east-1b"
  cidr_block        = "172.32.16.0/20"
}

resource "aws_route_table_association" "pub-a" {
  subnet_id      = aws_subnet.pub-a.id
  route_table_id = aws_route_table.pub.id
}

resource "aws_route_table_association" "pub-b" {
  subnet_id      = aws_subnet.pub-b.id
  route_table_id = aws_route_table.pub.id
}

resource "aws_route_table" "pub" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.vpc.id
}
