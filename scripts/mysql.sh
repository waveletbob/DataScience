yum安装方式
yum list installed | grep mysql

yum -y remove mysql-libs.x86_64

yum list | grep mysql 或 yum -y list mysql*

yum -y install mysql-server mysql mysql-devel 

rpm -qi mysql-server

mysqladmin -u root password "31.is.king"
GRANT ALL PRIVILEGES ON *.* TO root@'%' IDENTIFIED BY '31.is.king'
