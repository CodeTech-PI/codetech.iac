variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}

variable "subnet_publica_id" {
  description = "ID da subrede Pública"
  type        = string
}

variable "subnet_private_id" {
  description = "ID da subrede Privada"
  type        = string
}

variable "security_public_id" {
  description = "ID do SG de Jump"
  type        = string
}

variable "security_private_id" {
  description = "ID do SG Privado"
  type        = string
}

resource "aws_instance" "ec2_privada" {
  ami             = "ami-0f9de6e2d2f067fca"
  instance_type   = "t2.medium"
  subnet_id       = var.subnet_private_id
  key_name        = aws_key_pair.codetech_key.key_name
  security_groups = [var.security_private_id]

  user_data = <<-EOF
    #!/bin/bash -xe

    echo "Iniciando user-data" > /tmp/user_data_test.log

    sudo apt-get update -y >> /tmp/user_data_test.log 2>&1

    sudo apt-get install -y ca-certificates curl gnupg lsb-release >> /tmp/user_data_test.log 2>&1
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update -y >> /tmp/user_data_test.log 2>&1
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >> /tmp/user_data_test.log 2>&1

    sudo systemctl start docker >> /tmp/user_data_test.log 2>&1
    sudo systemctl enable docker >> /tmp/user_data_test.log 2>&1

    DOCKER_COMPOSE_CONTENT = file("./docker-compose.yml")
    echo "$DOCKER_COMPOSE_CONTENT" | sudo tee /home/ubuntu/docker-compose.yml

    sudo docker compose -f /home/ubuntu/docker-compose.yml up -d

  EOF

  tags = {
    Name = "codetech-be"
  }
}

resource "aws_instance" "ec2_publica" {
  ami             = "ami-0f9de6e2d2f067fca"
  instance_type   = "t2.medium"
  subnet_id       = var.subnet_publica_id
  key_name        = aws_key_pair.codetech_key.key_name
  security_groups = [var.security_public_id]

  user_data = <<-EOF2
    #!/bin/bash -xe

    echo "Iniciando user-data" > /tmp/user_data_test.log

    sudo apt-get update -y >> /tmp/user_data_test.log 2>&1
    sudo apt install -y nginx -y >> /tmp/user_data_test.log 2>&1

    sudo apt-get update -y >> /tmp/user_data_test.log 2>&1
    sudo apt-get install -y ca-certificates curl gnupg lsb-release >> /tmp/user_data_test.log 2>&1
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update -y >> /tmp/user_data_test.log 2>&1
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io >> /tmp/user_data_test.log 2>&1

    sudo systemctl start docker >> /tmp/user_data_test.log 2>&1
    sudo systemctl enable docker >> /tmp/user_data_test.log 2>&1

    sudo bash -c "cat > /etc/nginx/nginx.conf" <<EOL_NGINX
      
    events {
      worker_connections 1024;
    }

      http {

        upstream backend_servers {
            least_conn;
            server ${aws_instance.ec2_privada.private_ip}:8080;
            server ${aws_instance.ec2_privada.private_ip}:8081;
        }

        server {
            listen 80;
            server_name _;

            location / {
                proxy_pass http://localhost:3000;
                proxy_set_header Host \$host;
                proxy_set_header X-Real-IP \$remote_addr;
                proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto \$scheme;
            }

            location /lombardi/login {
                proxy_pass http://backend_servers;
                proxy_set_header Host \$host;
                proxy_set_header X-Real-IP \$remote_addr;
                proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto \$scheme;
            }

            location /agendamentos {
                proxy_pass http://backend_servers;
                proxy_set_header Host \$host;
                proxy_set_header X-Real-IP \$remote_addr;
                proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto \$scheme;
            }

            location /ordens-servicos {
                proxy_pass http://backend_servers;
                proxy_set_header Host \$host;
                proxy_set_header X-Real-IP \$remote_addr;
                proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto \$scheme;
            }

            location /faturamentos {
                proxy_pass http://backend_servers;
                proxy_set_header Host \$host;
                proxy_set_header X-Real-IP \$remote_addr;
                proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto \$scheme;
            }

            location /api/events {
                proxy_pass http://backend_servers;
                proxy_set_header Host \$host;
                proxy_set_header X-Real-IP \$remote_addr;
                proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto \$scheme;
            }

            location /usuarios {
                proxy_pass http://backend_servers;
                proxy_set_header Host \$host;
                proxy_set_header X-Real-IP \$remote_addr;
                proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto \$scheme;
            }

            location /categorias {
                proxy_pass http://backend_servers;
                proxy_set_header Host \$host;
                proxy_set_header X-Real-IP \$remote_addr;
                proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto \$scheme;
            }

            location /lista-produtos {
                proxy_pass http://backend_servers;
                proxy_set_header Host \$host;
                proxy_set_header X-Real-IP \$remote_addr;
                proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto \$scheme;
            }

            location /produtos {
                proxy_pass http://backend_servers;
                proxy_set_header Host \$host;
                proxy_set_header X-Real-IP \$remote_addr;
                proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto \$scheme;
            }

            location /unidades {
                proxy_pass http://backend_servers;
                proxy_set_header Host \$host;
                proxy_set_header X-Real-IP \$remote_addr;
                proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto \$scheme;
            }

            location /operacional {
                proxy_pass http://backend_servers;
                proxy_set_header Host \$host;
                proxy_set_header X-Real-IP \$remote_addr;
                proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto \$scheme;
            }

            location /inoperacional {
                proxy_pass http://backend_servers;
                proxy_set_header Host \$host;
                proxy_set_header X-Real-IP \$remote_addr;
                proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto \$scheme;
            }

            location /tornar-operacional {
                proxy_pass http://backend_servers;
                proxy_set_header Host \$host;
                proxy_set_header X-Real-IP \$remote_addr;
                proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto \$scheme;
            }
          }
        }
      
    EOL_NGINX

    sudo systemctl restart nginx >> /tmp/user_data_test.log 2>&1

    sudo docker run --name frontend -p 3000:80 -d gabrielaseverino/codetech.front:latest >> /tmp/user_data_test.log 2>&1
  EOF2

  tags = {
    Name = "codetech-publica"
  }
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "codetech_key" {
  key_name   = "codetech_key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.root}/keys/codetech_key.pem"
  file_permission = "0400"
}

output "public_instance_id" {
  value       = aws_instance.ec2_publica.id
  description = "ID da EC2 pública"
}

output "private_instance_id" {
  value       = aws_instance.ec2_privada.id
  description = "ID da EC2 be"
}


output "public_instance_ip" {
  value       = aws_instance.ec2_publica.public_ip
  description = "IP Publico da instancia EC2 Publica"
}