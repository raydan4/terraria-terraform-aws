data "aws_ami" "debian_12_ami" {
    most_recent = true

    filter {
      name = "name"
      values = ["debian*"]
    }

    filter {
      name = "architecture"
      values = ["x86_64"]
    }
}

data "aws_s3_bucket" "terraria_world_storage" {
    bucket = var.terraria_world_s3_bucket
}

data "aws_iam_policy_document" "terraria_world_bucket_access_policy_document" {
  statement {
    actions = [
        "s3:GetObject",
        "s3:PutObject"
    ]
    effect = "Allow"
    resources = [
        "${data.aws_s3_bucket.terraria_world_storage.arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "assume_role_document" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "terraria_server_role" {
  name = "terraria-server-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_document.json

  tags = {
    Name = "Terraria Server Role"
  }
}

resource "aws_iam_role_policy" "s3_access_policy" {
  name = "access-terraria-world-bucket"
  role = aws_iam_role.terraria_server_role.id
  
  policy = data.aws_iam_policy_document.terraria_world_bucket_access_policy_document.json
}

resource "aws_iam_instance_profile" "terraria_server_instance_profile" {
  name = "terraria-server-profile"
  role = aws_iam_role.terraria_server_role.name

  tags = {
    Name = "Terraria Server Instance Profile"
  }
}

resource "aws_instance" "terraria_server" {
  ami = data.aws_ami.debian_12_ami.id
  instance_type = "t2.medium"
  associate_public_ip_address = true
  subnet_id = aws_subnet.terraria_subnet.id

  iam_instance_profile = aws_iam_instance_profile.terraria_server_instance_profile.id

  user_data = templatefile(
    "instance_data.sh",
    {
        authorized_key = var.authorized_key
        terraria_version = var.terraria_version
        terraria_root_dir = var.terraria_root_dir
        terraria_config_world_name = var.terraria_config_world_name
        terraria_config_autocreate = var.terraria_config_autocreate
        terraria_config_seed = var.terraria_config_seed
        terraria_config_difficulty = var.terraria_config_difficulty
        terraria_config_maxplayers = var.terraria_config_maxplayers
        terraria_config_port = var.terraria_config_port
        terraria_config_password = var.terraria_config_password
        terraria_config_anticheat = var.terraria_config_anticheat
        terraria_config_language = var.terraria_config_language
        s3_bucket = data.aws_s3_bucket.terraria_world_storage.id
    }
  )

  vpc_security_group_ids = [
    aws_security_group.allow_terraria_server.id,
    aws_security_group.allow_ssh.id
  ]

  tags = {
    Name = "Terraria Server"
  }
}
