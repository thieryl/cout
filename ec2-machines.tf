resource "aws_instance" "phpapp" {
  ami                         = "${lookup(var.AmiLinux, var.region)}"
  instance_type               = "t2.micro"
  associate_public_ip_address = "true"
  subnet_id                   = "${aws_subnet.PublicAZA.id}"
  vpc_security_group_ids      = ["${aws_security_group.FrontEnd.id}"]
  key_name                    = "${var.key_name}"
  tags {
    Name = "phpapp"
  }
  user_data = <<HEREDOC
  #!/bin/bash
  yum update -y
  yum install -y httpd24 php56 php56-mysqlnd monit
  service httpd start
  chkconfig httpd on
  touch /var/www/html/index.html
  echo "<h1><center>" >> /var/www/html/calldb.php
  echo "<?php" >> /var/www/html/calldb.php
  echo "\$conn = new mysqli('${aws_instance.database.private_ip}', 'root', 'secret', 'test');" >> /var/www/html/calldb.php
  echo "\$sql = 'SELECT * FROM mytable'; " >> /var/www/html/calldb.php
  echo "\$result = \$conn->query(\$sql); " >>  /var/www/html/calldb.php
  echo "while(\$row = \$result->fetch_assoc()) { echo 'the value is: ' . \$row['mycol'];} " >> /var/www/html/calldb.php
  echo "\$conn->close(); " >> /var/www/html/calldb.php
  echo "?>" >> /var/www/html/calldb.php
  echo "</center></h1>" >> /var/www/html/calldb.php

  # set up monit
  echo "set httpd port 2812 and " >> /etc/monit.conf
  echo "allow 0.0.0.0/0 " >> /etc/monit.conf
  echo "allow admin:monit      # require user 'admin' with password 'monit' " >> /etc/monit.conf
  echo "allow @monit           # allow users of group 'monit' to connect (rw) " >> /etc/monit.conf
  echo "allow @users readonly  # allow users of group 'users' to connect readonly " >> /etc/monit.conf

  echo "check process httpd with pidfile /var/run/httpd/httpd.pid " >> /etc/monit.conf
  echo "group apache " >> /etc/monit.conf
  echo "start program = \"/etc/init.d/httpd start\" " >> /etc/monit.conf
  echo "stop program = \"/etc/init.d/httpd stop\" " >> /etc/monit.conf
  echo "if failed host 127.0.0.1 port 80 " >> /etc/monit.conf
  echo "protocol http then restart " >> /etc/monit.conf
  echo "if 5 restarts within 5 cycles then timeout " >> /etc/monit.conf

  echo "check process sshd with pidfile /var/run/sshd.pid" >> /etc/monit.conf
  echo "start program \"/etc/init.d/sshd start\" " >> /etc/monit.conf
  echo "stop program \"/etc/init.d/sshd stop\" " >> /etc/monit.conf
  echo "if failed host 127.0.0.1 port 22 protocol ssh then restart" >> /etc/monit.conf
  echo "if 5 restarts within 5 cycles then timeout" >> /etc/monit.conf

  echo "check host mydatabase.tricky-bit.internal with address ${aws_instance.database.private_ip} " >> /etc/monit.conf
  echo "start program = \"/usr/bin/ssh user@ipaddress /etc/init.d/sshd start\" " >> /etc/monit.conf
  echo "stop program = \"/usr/bin/ssh user@ipaddress /etc/init.d/sshd stop\" " >> /etc/monit.conf
  echo "if failed port 22 protocol ssh " >> /etc/monit.conf
  echo "then alert " >> /etc/monit.conf

  sleep 5
  service monit on
  service monit start
HEREDOC

}

resource "aws_instance" "database" {
  ami                         = "${lookup(var.AmiLinux, var.region)}"
  instance_type               = "t2.micro"
  associate_public_ip_address = "false"
  subnet_id                   = "${aws_subnet.PrivateAZA.id}"
  vpc_security_group_ids      = ["${aws_security_group.Database.id}"]
  key_name                    = "${var.key_name}"
  tags {
    Name = "database"
  }
  user_data = <<HEREDOC
  #!/bin/bash
  sleep 180
  yum update -y
  yum install -y mysql-server mysql-client
  service mysqld start
  /usr/bin/mysqladmin -u root password 'secret'
  mysql -u root -psecret -e "create user 'root'@'%' identified by 'secret';" mysql
  mysql -u root -psecret -e 'CREATE TABLE mytable (mycol varchar(255));' test
  mysql -u root -psecret -e "INSERT INTO mytable (mycol) values ('tricky-beast') ;" test
HEREDOC
}

output "webapp_ip_public_address" {
  value = "${aws_instance.phpapp.*.public_ip}"
}

output "webapp_ip_private_address" {
  value = "${aws_instance.phpapp.*.private_ip}"
}
output "database_ip_private_address" {
  value = "${aws_instance.database.*.private_ip}"
}
