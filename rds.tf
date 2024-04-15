### Creating Database Subnet Group
resource "aws_db_subnet_group" "rds_db_sub_grp" {
  name       = "rds_db_sub_grp"
  subnet_ids = aws_subnet.data_tier_subnet.*.id

  tags = {
    Name = "Data Tier DB Subnet Group"
  }
}

### Creating RDS MYSQL Database
resource "aws_db_instance" "data_tier_db" {
  identifier             = var.db_identifier
  allocated_storage      = var.db_storage
  db_name                = var.dbname
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  multi_az               = var.db_multi_az
  db_subnet_group_name   = aws_db_subnet_group.rds_db_sub_grp.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  username               = var.dbuser
  password               = var.dbpass
  parameter_group_name   = var.db_parameter_group_name
  skip_final_snapshot    = var.db_skip_snapshot

  tags = {
    Name = "Data Tier DB"
  }
}
