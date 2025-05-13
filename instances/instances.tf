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

resource "aws_instance" "ec2_publica" {
  ami             = "ami-0f9de6e2d2f067fca"
  instance_type   = "t2.micro"
  subnet_id       = var.subnet_publica_id
  key_name        = aws_key_pair.codetech_key.key_name
  security_groups = [var.security_public_id]


  user_data = <<-EOF2
            #!/bin/bash

            sudo apt-get update -y
            sudo apt install nginx -y

            sudo bash -c 'cat > /etc/nginx/sites-available/default' 
            
            <<EOL

            upstream backend_servers {
                least_conn;
                server ${aws_instance.ec2_privada.private_ip}:8080;
                server ${aws_instance.ec2_privada_2.private_ip}:8080;
            }

            server {
                listen 80;
                server_name _;

                 location /api/ {
                    proxy_pass http://backend_servers;
                    proxy_set_header Host $$host;
                    proxy_set_header X-Real-IP $$remote_addr;
                    proxy_set_header X-Forwarded-For $$proxy_add_x_forwarded_for;
                    proxy_set_header X-Forwarded-Proto $$scheme;
                  }

                 location /lombardi/ {
                    proxy_pass http://backend_servers;
                    proxy_set_header Host $$host;
                    proxy_set_header X-Real-IP $$remote_addr;
                    proxy_set_header X-Forwarded-For $$proxy_add_x_forwarded_for;
                    proxy_set_header X-Forwarded-Proto $$scheme;
                  }

                 location /agendamentos/ {
                    proxy_pass http://backend_servers;
                    proxy_set_header Host $$host;
                    proxy_set_header X-Real-IP $$remote_addr;
                    proxy_set_header X-Forwarded-For $$proxy_add_x_forwarded_for;
                    proxy_set_header X-Forwarded-Proto $$scheme;
                  }

                 location /categorias/ {
                    proxy_pass http://backend_servers;
                    proxy_set_header Host $$host;
                    proxy_set_header X-Real-IP $$remote_addr;
                    proxy_set_header X-Forwarded-For $$proxy_add_x_forwarded_for;
                    proxy_set_header X-Forwarded-Proto $$scheme;
                  }                  

                  location /faturamentos/ {
                    proxy_pass http://backend_servers;
                    proxy_set_header Host $$host;
                    proxy_set_header X-Real-IP $$remote_addr;
                    proxy_set_header X-Forwarded-For $$proxy_add_x_forwarded_for;
                    proxy_set_header X-Forwarded-Proto $$scheme;
                  }

                    location /api/events/ {
                    proxy_pass http://backend_servers;
                    proxy_set_header Host $$host;
                    proxy_set_header X-Real-IP $$remote_addr;
                    proxy_set_header X-Forwarded-For $$proxy_add_x_forwarded_for;
                    proxy_set_header X-Forwarded-Proto $$scheme;
                  }

                    location /lista-produtos/ {
                    proxy_pass http://backend_servers;
                    proxy_set_header Host $$host;
                    proxy_set_header X-Real-IP $$remote_addr;
                    proxy_set_header X-Forwarded-For $$proxy_add_x_forwarded_for;
                    proxy_set_header X-Forwarded-Proto $$scheme;
                  }

                    location /ordens-servicos/ {
                    proxy_pass http://backend_servers;
                    proxy_set_header Host $$host;
                    proxy_set_header X-Real-IP $$remote_addr;
                    proxy_set_header X-Forwarded-For $$proxy_add_x_forwarded_for;
                    proxy_set_header X-Forwarded-Proto $$scheme;
                  }

                   location /produtos/ {
                    proxy_pass http://backend_servers;
                    proxy_set_header Host $$host;
                    proxy_set_header X-Real-IP $$remote_addr;
                    proxy_set_header X-Forwarded-For $$proxy_add_x_forwarded_for;
                    proxy_set_header X-Forwarded-Proto $$scheme;
                  }

                    location /unidades/ {
                    proxy_pass http://backend_servers;
                    proxy_set_header Host $$host;
                    proxy_set_header X-Real-IP $$remote_addr;
                    proxy_set_header X-Forwarded-For $$proxy_add_x_forwarded_for;
                    proxy_set_header X-Forwarded-Proto $$scheme;
                  }

                    location /usuarios/ {
                    proxy_pass http://backend_servers;
                    proxy_set_header Host $$host;
                    proxy_set_header X-Real-IP $$remote_addr;
                    proxy_set_header X-Forwarded-For $$proxy_add_x_forwarded_for;
                    proxy_set_header X-Forwarded-Proto $$scheme;
                  }

                  location ~* /swagger-ui/ {
                      proxy_pass http://backend_servers;
                      proxy_set_header Host $$host;
                      proxy_set_header X-Real-IP $$remote_addr;
                      proxy_set_header X-Forwarded-For $$proxy_add_x_forwarded_for;
                      proxy_set_header X-Forwarded-Proto $$scheme;
                  }

                  location / {
                      proxy_pass http://localhost:3000;
                      proxy_http_version 1.1;
                      proxy_set_header Upgrade $$http_upgrade;
                      proxy_set_header Connection 'upgrade';
                      proxy_set_header Host $$host;
                      proxy_cache_bypass $$http_upgrade;
                  }
            }

            EOL

            sudo systemctl restart nginx

            sudo apt-get update -y
            sudo apt-get install ca-certificates curl

            sudo install -m 0755 -d /etc/apt/keyrings -y
            sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
            sudo chmod a+r /etc/apt/keyrings/docker.asc

            echo \
              "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
              $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
              sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

            sudo apt-get update -y
            sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

            sudo systemctl start docker
            sudo systemctl enable docker

            sudo groupadd docker
            sudo usermod -aG docker $USER
            newgrp docker

            BACKEND_IP = $(aws ec2 describe-instances --instance-ids "$${aws_instance.ec2_privada.id}" --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
            sudo docker run -d -p 80:80 -e REACT_APP_API_URL="http://$${BACKEND_IP}:8080" gabrielaseverino/codetech-front:v1

        EOF2

  tags = {
    Name = "codetech-publica"
  }
}

resource "aws_instance" "ec2_bd" {
  ami                         = "ami-0f9de6e2d2f067fca"
  instance_type               = "t2.micro"
  subnet_id                   = var.subnet_private_id
  key_name                    = aws_key_pair.codetech_key.key_name
  vpc_security_group_ids      = [var.security_private_id]
  associate_public_ip_address = false

  user_data = <<-EOF
    #!/bin/bash

    sudo apt-get update -y
    sudo apt-get install ca-certificates curl -y

    sudo install -m 0755 -d /etc/apt/keyrings -y
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update -y
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

    sudo systemctl start docker
    sudo systemctl enable docker

    sudo groupadd docker
    sudo usermod -aG docker $USER
    newgrp docker

    MYSQL_ROOT_PASSWORD="lombardi123"
    DATABASE_NAME="lombardi_db"
    MYSQL_USER="lombardi"
    MYSQL_PASSWORD="lombardi123"

   sudo docker run --name mysql-db -e MYSQL_ROOT_PASSWORD=$${MYSQL_ROOT_PASSWORD} -p 3306:3306 -d mysql:latest

    sleep 30

    sudo docker exec -i mysql-db mysql -u root -p"$${MYSQL_ROOT_PASSWORD}"

    <<EOF_SCRIPT
    CREATE DATABASE IF NOT EXISTS $${DATABASE_NAME};
    USE $${DATABASE_NAME};

    CREATE TABLE categoria (
      id INT PRIMARY KEY AUTO_INCREMENT,
      nome VARCHAR(40)
    );

    CREATE TABLE produto (
      id INT PRIMARY KEY AUTO_INCREMENT,
      nome VARCHAR(50),
      quantidade INT,
      descricao VARCHAR(50),
      unidade_medida VARCHAR(30),
      preco DOUBLE,
      categoria_id INT,
      FOREIGN KEY (categoria_id) REFERENCES categoria(id)
    );

    CREATE TABLE cliente (
      id INT PRIMARY KEY AUTO_INCREMENT,
      nome VARCHAR(75),
      telefone CHAR(11),
      cpf VARCHAR(14),
      data_nascimento DATE,
      email VARCHAR(75)
    );

    CREATE TABLE endereco (
      id INT PRIMARY KEY AUTO_INCREMENT,
      logradouro VARCHAR(45),
      cidade VARCHAR(45),
      estado VARCHAR(45),
      complemento VARCHAR(45),
      cep VARCHAR(45),
      num INT,
      bairro VARCHAR(45)
    );

    CREATE TABLE agendamento (
      id INT PRIMARY KEY AUTO_INCREMENT,
      cancelado TINYINT,
      dt DATE,
      horario TIME,
      cliente_id INT,
      FOREIGN KEY (cliente_id) REFERENCES cliente(id)
    );

    CREATE TABLE ordem_servico (
      id INT PRIMARY KEY AUTO_INCREMENT,
      valor_tatuagem DECIMAL(10, 2),
      agendamento_id INT,
      FOREIGN KEY (agendamento_id) REFERENCES agendamento(id)
    );

    CREATE TABLE faturamento (
      id INT PRIMARY KEY AUTO_INCREMENT,
      lucro DECIMAL(10, 2),
      ordem_servico_id INT,
      FOREIGN KEY (ordem_servico_id) REFERENCES ordem_servico(id)
    );

    CREATE TABLE usuario (
      id INT PRIMARY KEY AUTO_INCREMENT,
      email VARCHAR(75),
      senha VARCHAR(250),
      nome VARCHAR(75)
    );

    CREATE TABLE lista_produto (
      id INT PRIMARY KEY AUTO_INCREMENT,
      quantidade_produtos INT,
      produto_id INT,
      FOREIGN KEY (produto_id) REFERENCES produto(id),
      agendamento_id INT,
      FOREIGN KEY (agendamento_id) REFERENCES agendamento(id)
    );

    INSERT INTO usuario VALUES (null, 'lombardi@localhost', '$2b$12$3SzbTQaHdWnOlAnxw.7uyO24HWdq2bmmPAmtHcOl3tw5XXLhH5c1G', 'Letícia Lombardi');

    CREATE USER IF NOT EXISTS '$${MYSQL_USER}'@'%' IDENTIFIED BY '$${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON $${DATABASE_NAME}.* TO '$${MYSQL_USER}'@'%';
    FLUSH PRIVILEGES;

    INSERT INTO endereco (logradouro, cidade, estado, complemento, cep, num, bairro) VALUES
    ('Rua das Flores', 'São Paulo', 'SP', 'Apto 101', '01000-000', 123, 'Centro');
    
  EOF_SCRIPT
  EOF

  tags = {
    Name = "codetech-bd"
  }
}

output "private_instance_id_bd" {
  value       = aws_instance.ec2_bd.id
  description = "ID da EC2 bd mysql"
}

resource "aws_instance" "ec2_privada" {
  ami             = "ami-0f9de6e2d2f067fca"
  instance_type   = "t2.micro"
  subnet_id       = var.subnet_private_id
  key_name        = aws_key_pair.codetech_key.key_name
  security_groups = [var.security_private_id]

  user_data = <<-EOF
            #!/bin/bash
            
            sudo apt-get update -y
            sudo apt-get install ca-certificates curl

            sudo install -m 0755 -d /etc/apt/keyrings
            sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
            sudo chmod a+r /etc/apt/keyrings/docker.asc

            echo \
              "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
              $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
              sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

            sudo apt-get update -y
            sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

            sudo systemctl start docker
            sudo systemctl enable docker

            sudo groupadd docker
            sudo usermod -aG docker $USER
            newgrp docker

            DB_HOST=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4 -i) # Pega o próprio IP privado (não o do BD)

            sudo docker run -p 8080:8080 -d \
            -e SPRING_DATASOURCE_URL="jdbc:mysql://${aws_instance.ec2_bd.private_ip}:3306/lombardi_db" \
            -e SPRING_DATASOURCE_USERNAME="lombardi" \
            -e SPRING_DATASOURCE_PASSWORD="lombardi123" \
            gabrielaseverino/codetech.api:v1    

            #sudo docker run -p 8080:8080 -d gabrielaseverino/codetech.api:v1
        EOF

  tags = {
    Name = "codetech-be"
  }
}

resource "aws_instance" "ec2_privada_2" {
  ami             = "ami-0f9de6e2d2f067fca"
  instance_type   = "t2.micro"
  subnet_id       = var.subnet_private_id
  key_name        = aws_key_pair.codetech_key.key_name
  security_groups = [var.security_private_id]

  user_data = <<-EOF
            #!/bin/bash
            
            sudo apt-get update -y
            sudo apt-get install ca-certificates curl

            sudo install -m 0755 -d /etc/apt/keyrings
            sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
            sudo chmod a+r /etc/apt/keyrings/docker.asc

            echo \
              "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
              $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
              sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

            sudo apt-get update -y
            sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

            sudo systemctl start docker
            sudo systemctl enable docker

            sudo groupadd docker
            sudo usermod -aG docker $USER
            newgrp docker

            DB_HOST=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4 -i) # Pega o próprio IP privado (não o do BD)

            sudo docker run -p 8080:8080 -d \
            -e SPRING_DATASOURCE_URL="jdbc:mysql://${aws_instance.ec2_bd.private_ip}:3306/lombardi_db" \
            -e SPRING_DATASOURCE_USERNAME="lombardi" \
            -e SPRING_DATASOURCE_PASSWORD="lombardi123" \
            gabrielaseverino/codetech.api:v1

            # sudo docker run -p 8080:8080 -d gabrielaseverino/codetech.api:v1
        EOF

  tags = {
    Name = "codetech-be-2"
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
  filename        = "${path.module}/../keys/codetech_key.pem"
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

output "private_instance_id_2" {
  value       = aws_instance.ec2_privada_2.id
  description = "ID da EC2 be-2"
}