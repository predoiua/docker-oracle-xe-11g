#!/bin/bash

# Oracle 11g on CentOS 6.10

ASSET=/assets_11g
OR=/u01


create_user() {
    groupadd oinstall
    groupadd dba
    groupadd oracle
    useradd -g oinstall -G dba oracle
    echo "oracle" | passwd oracle --stdin
}

create_user

export ORACLE_HOME=${OR}/app/oracle/product/11.2.0/db_1

mkdir -p ${ORACLE_HOME}
chown -R oracle:oinstall ${OR}
chmod -R 775 ${OR}

export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=ORCL

echo "export ORACLE_HOME=${ORACLE_HOME}" >> /etc/bashrc
echo "export PATH=${ORACLE_HOME}/bin:\$PATH" >> /etc/bashrc
echo "export ORACLE_SID=${ORACLE_SID}" >> /etc/bashrc

create_env() {

yum update -y
yum install -y initscripts sudo # for service and sudo
yum install -y xorg-x11-server-Xorg xorg-x11-xauth xorg-x11-apps  # minimal X

# Oracle package
while read pack; do
    yum install -y ${pack}
done << FIN
    gcc
    glibc
    glibc-devel
    unixODBC-devel
    compat-libstdc++-33
    libaio-devel
    sysstat
    ksh
    binutils-2*x86_64*
    glibc-2*x86_64* nss-softokn-freebl-3*x86_64*
    glibc-2*i686* nss-softokn-freebl-3*i686*
    compat-libstdc++-33*x86_64*
    glibc-common-2*x86_64*
    glibc-devel-2*x86_64*
    glibc-devel-2*i686*
    glibc-headers-2*x86_64*
    elfutils-libelf-0*x86_64*
    elfutils-libelf-devel-0*x86_64*
    gcc-4*x86_64*
    gcc-c++-4*x86_64*
    ksh-*x86_64*
    libaio-0*x86_64*
    libaio-devel-0*x86_64*
    libaio-0*i686*
    libaio-devel-0*i686*
    libgcc-4*x86_64*
    libgcc-4*i686*
    libstdc++-4*x86_64*
    libstdc++-4*i686*
    libstdc++-devel-4*x86_64*
    make-3.81*x86_64*
    numactl-devel-2*x86_64*
    sysstat-9*x86_64*
    compat-libstdc++-33*i686*
    compat-libcap*
FIN



echo "
net.ipv4.ip_forward = 0
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
kernel.core_uses_pid = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.ip_local_port_range = 9000 65500
fs.file-max = 65536
kernel.shmall = 10523004
kernel.shmmax = 6465333657
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
net.core.rmem_default = 262144
net.core.wmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_max = 1048576
fs.aio-max-nr = 1048576
" >> /etc/sysctl.conf

sysctl -p /etc/sysctl.conf

echo "
oracle soft nproc 2047
oracle hard nproc 16384
oracle soft nofile 1024
oracle hard nofile 65536
" >> /etc/security/limits.conf

echo "
session required pam_limits.so
" >>/etc/pam.d/login

echo "
if [ \$USER = "oracle" ]; then
    ulimit -u 16384 -n 65536
fi
" >> /etc/profile

}

grant_user() {
    echo "oracle ALL=(ALL)        NOPASSWD: ALL" | EDITOR='tee -a' visudo
}

create_ssh() {
    yum install -y openssh-server sudo
    service sshd start
}


create_db_sw() {
    su - oracle -c "${ASSET}/database/runInstaller -silent -waitforcompletion -responseFile ${ASSET}/db_install.rsp -ignorePrereq -ignoreSysPrereqs"
    /u01/app/oraInventory/orainstRoot.sh
    ${ORACLE_HOME}/root.sh
    echo "Done install sw"
}

create_db() {
    su - oracle -c "dbca -silent -responseFile ${ASSET}/dbca.rsp"
    echo "ORCL:/u01/app/oracle/product/11.2.0/db_1:Y" >/etc/oratab
    echo "Done create DB"
}


create_listener() {
    cp ${ASSET}/listener.ora ${ORACLE_HOME}/network/admin/listener.ora.tmpl
    cp ${ASSET}/tnsnames.ora ${ORACLE_HOME}/network/admin/tnsnames.ora.tmpl
    su - oracle -c "netca /silent -responseFile ${ASSET}/netca.rsp"
    echo "Done listener"
}

create_service() {
    cp ${ASSET}/oracle /etc/rc.d/init.d/
    chmod 755 /etc/rc.d/init.d/oracle
    chkconfig --add oracle
    chkconfig oracle on
}


all() {
    create_env
    grant_user

    create_db_sw
    create_db
    create_listener
    create_service

    create_ssh
    echo "Done"
}

all