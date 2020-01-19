


cp ./assets_11g/database/response/db_install.rsp ./assets_11g/


https://stackoverflow.com/questions/24288616/permission-denied-on-accessing-host-directory-in-docker
http://www.projectatomic.io/blog/2015/06/using-volumes-with-docker-can-cause-problems-with-selinux/


docker run -it --rm -v /home/predoiua/git/git_predoiua/docker-oracle-xe-11g/assets_11g:/assets_11g:Z ubuntu:18.04 bash


docker run -it --rm -v /home/predoiua/git/git_predoiua/docker-oracle-xe-11g/assets_11g:/assets_11g:Z -p 2222:22 ubuntu:18.04 bash



docker run -it --rm ubuntu:18.04 bash



# Prepare to install Oracle
apt-get update &&
apt-get install -y libaio1 net-tools bc &&
ln -s /usr/bin/awk /bin/awk &&
mkdir /var/lock/subsys 
&&
mv /assets/chkconfig /sbin/chkconfig &&
chmod 755 /sbin/chkconfig &&



/assets_11g/database/runInstaller -silent -noconfig -responseFile /assets_11g/db_install.rsp 



http://meandmyubuntulinux.blogspot.com/2012/05/installing-oracle-11g-r2-express.html


## Ubuntu 18.4

docker run -it --rm -v /home/predoiua/git/git_predoiua/docker-oracle-xe-11g/assets_11g:/assets_11g:Z -p 2222:22 ubuntu:18.04 bash

apt update
apt install openssh-server
service ssh start

groupadd oinstall
groupadd dba
groupadd oracle
useradd -g oinstall -G dba oracle
passwd oracle


apt install vim sudo
usermod -aG sudo oracle


## CentOS 6

docker run -it --rm -v /home/predoiua/git/git_predoiua/docker-oracle-xe-11g/assets_11g:/assets_11g:Z -p 2225:22  centos:6 bash

yum update -y
yum install -y initscripts
yum install -y xorg-x11-server-Xorg xorg-x11-xauth xorg-x11-apps

yum install -y openssh-server sudo
service sshd start


groupadd oinstall
groupadd dba
groupadd oracle
useradd -g oinstall -G dba oracle

echo "oracle" | passwd oracle --stdin
echo "oracle ALL=(ALL)        NOPASSWD: ALL" | sudo EDITOR='tee -a' visudo





