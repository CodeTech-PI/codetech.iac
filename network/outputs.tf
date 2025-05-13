output "jump_sg_id" {
  value = aws_security_group.security_public.id
}

output "private_sg_id" {
  value = aws_security_group.security_private.id
}

output "vpc_id" {
  value = aws_vpc.codetech_vpc.id
}

output "subnet_publica_id" {
  value = aws_subnet.subnet_publica.id
}

output "subnet_private_id" {
  value = aws_subnet.subnet_private.id
}

output "security_public_id" {
  value = aws_security_group.security_public.id
}

output "security_private_id" {
  value = aws_security_group.security_private.id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat_gw.id
}

output "eip_nat_id" {
  value = aws_eip.nat_eip.id
}