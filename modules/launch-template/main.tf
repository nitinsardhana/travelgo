resource "aws_launch_template" "web" {

  name_prefix = "${var.environment}-lt-"

  image_id      = var.ami_id
  instance_type = var.instance_type

  key_name = var.key_name

  vpc_security_group_ids = [
    var.security_group_id
  ]

  user_data = base64encode(<<-EOF
#!/bin/bash

dnf install nginx -y

systemctl enable nginx

systemctl start nginx

cat > /usr/share/nginx/html/index.html <<HTML
<h1>TravelTGo Devops Project</h1>
<h2>Deployed Using Launch Template</h2>
HTML

EOF
  )

  tags = {
    Name = "${var.environment}-launch-template"

  }
}

