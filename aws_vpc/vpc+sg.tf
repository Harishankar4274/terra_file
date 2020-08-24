// creating VPC start
resource "aws_vpc" "custom_vpc"{
    cidr_block  =   "10.100.0.0/16"
    
    tags = {
        Name = "Custom_VPC"
    }
}
//creating VPC end

// Creating Public_Subnet start
resource "aws_subnet" "public_subnet" {
    depends_on = [aws_vpc.custom_vpc]

    vpc_id = aws_vpc.custom_vpc.id
    cidr_block = "10.100.1.0/24"
    availability_zone = "ap-south-1a"

    tags = {
        Name = "Public_Subnet"
    }
}
// Creating Public_Subnet end

// Creating Private_Subnet start
resource "aws_subnet" "private_subnet" {
    depends_on = [aws_vpc.custom_vpc]

    vpc_id = aws_vpc.custom_vpc.id
    cidr_block = "10.100.2.0/24"
    availability_zone = "ap-south-1a"

    tags = {
        Name = "Private_Subnet"
    }
}
// Creating Private_Subnet end

// Creating Internet_Gateway start
resource "aws_internet_gateway" "public_internet_gateway" {
	depends_on = [aws_vpc.custom_vpc]

  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Name = "public_internet_gateway"
  }
}
// Creating Internet_Gateway end

// Creating Route_Table start
resource "aws_route_table" "custom_route_table" {
    vpc_id = aws_vpc.custom_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.public_internet_gateway.id
    }
    tags = {
        Name = "custom_route_table"
    }
}
// Creating Route_Table end

// Associating custom_route_table start
resource "aws_route_table_association" "public_subnet_association" {
    depends_on = [aws_route_table.custom_route_table]
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.custom_route_table.id
}
// Associating custom_route_table end

// creating public_sg start
resource "aws_security_group" "public_sg" {
	depends_on = [aws_vpc.custom_vpc]

  name        = "public_sg"
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public_sg"
  }
}
// creating public_sg start

// creating private_sg start
resource "aws_security_group" "private_sg" {
	depends_on = [
    aws_vpc.custom_vpc
  ]
  name        = "private_sg"
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    description = "private_sg"
    security_groups = [aws_security_group.public_sg.id]
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private_sg"
  }
}
// creating private_sg start

// important data output start
output "vpc_id" {
    value = aws_vpc.custom_vpc.id
}

output "public_subnet_id" {
    value = aws_subnet.public_subnet.id
}

output "private_subnet_id" {
    value = aws_subnet.private_subnet.id
}

output "private_sg_id" {
    value = aws_security_group.private_sg.id
}

output "public_sg_id" {
    value = aws_security_group.public_sg.id
}
// important data output end