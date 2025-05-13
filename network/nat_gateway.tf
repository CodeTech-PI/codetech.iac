resource "aws_eip" "nat_eip" {
  vpc = true

  tags = {
    Name = "codetech-nat-elasticIP"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.subnet_publica.id

  tags = {
    Name = "codetech-nat-gateway"
  }
}
