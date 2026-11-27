resource "aws_ecr_repository" "ecommerce_frontend" {
  name         = "ecommerce-frontend"
  force_delete = true

  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name = "ecommerce-frontend"
  }
}

resource "aws_ecr_repository" "ecommerce_backend" {
  name         = "ecommerce-backend"
  force_delete = true

  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name = "ecommerce-backend"
  }
}