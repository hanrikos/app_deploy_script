#!/bin/bash
#title           :createenvironment-elk.sh
#description     :shell script to create environments (elasticsearch,logstash and kibana)
#date            :2018-04-19
#usage           :sudo ./elk.sh
#used version    :6.2.4
#tested-version  :1.2.0
#tested-distros  :CentOS 7.4

#become sudo
echo $pass | sudo -S ls /root

# Checking whether user has enough permission to run this script
sudo -n true
if [ $? -ne 0 ]
    then
        echo "This script requires user to have passwordless sudo access"
        exit
fi

# insert/update hosts entry
# option 2
# sed -i "/localhost4/ s/.*/0.0.0.0\tlocalhost localhost.localdomain localhost4 localhost4.localdomain4/g" /etc/hosts
sudo sed -i "/localhost4/ s/.*/0.0.0.0\tlocalhost/g" /etc/hosts

dependency_check_deb() {
java -version
if [ $? -ne 0 ]
    then
        # Installing Java 8 if it's not installed
        sudo wget --directory-prefix=/opt/ -nv --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u161-b12/2f38c3b165be4555a1fa6e98c45e0808/jdk-8u161-linux-x64.tar.gz
        sudo tar xzf /opt/jdk-8u161-linux-x64.tar.gz -C /opt/
        sudo update-alternatives --install /usr/bin/java java /opt/jdk1.8.0_161/bin/java 1
        sudo update-alternatives --config java <<< '1' 
        sudo -E echo -n -e '
        JAVA_HOME="/usr/java/jdk1.8.0_161/bin/java"
        JRE_HOME="/usr/java/jdk1.8.0_161/jre/bin/java"
        PATH=$PATH:$HOME/bin:JAVA_HOME:JRE_HOME' >> /etc/environment
        sudo -E source /etc/environment

fi
}

dependency_check_rpm() {
    java -version
    if [ $? -ne 0 ]
        then
            #Installing Java 8 if it's not installed
            sudo wget --directory-prefix=/opt/ -nv --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u161-b12/2f38c3b165be4555a1fa6e98c45e0808/jdk-8u161-linux-x64.tar.gz
            sudo tar xzf /opt/jdk-8u161-linux-x64.tar.gz -C /opt/
            sudo alternatives --install /usr/bin/java java /opt/jdk1.8.0_161/bin/java 1
            sudo alternatives --config java <<< '1'
            sudo -E echo -n -e '
            JAVA_HOME="/usr/java/jdk1.8.0_161/bin/java"
            JRE_HOME="/usr/java/jdk1.8.0_161/jre/bin/java"
            PATH=$PATH:$HOME/bin:JAVA_HOME:JRE_HOME' >> /etc/bashrc
    fi
}

debian_elk() {
    # resynchronize the package index files from their sources.
    #sudo apt-get update
    # Downloading debian package of elasticsearch
    sudo wget --directory-prefix=/tmp/ https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.2.4.deb
    # Install debian package of elasticsearch
    sudo dpkg -i /tmp/elasticsearch-6.2.4.deb
    # Downloading debian package of logstash
    sudo wget --directory-prefix=/tmp/ https://artifacts.elastic.co/downloads/logstash/logstash-6.2.4.deb
    # Install logstash debian package
    sudo dpkg -i /tmp/logstash-6.2.4.deb
    # install kibana
    #sudo apt-get install apt-transport-https
    sudo wget --directory-prefix=/tmp/ https://artifacts.elastic.co/downloads/kibana/kibana-6.2.4-amd64.deb
    sudo dpkg -i /tmp/kibana-6.2.4-amd64.deb
    # Starting The Services
    sudo systemctl restart elasticsearch
    sudo systemctl enable elasticsearch
    sudo systemctl restart logstash
    sudo systemctl enable logstash
    sudo systemctl restart kibana
    sudo systemctl enable kibana
}

rpm_elk() {
    #Installing wget.
    #sudo yum install wget -y
    # Downloading rpm package of elasticsearch
    sudo wget --directory-prefix=/tmp/ https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.2.4.rpm
    # Install rpm package of elasticsearch
    sudo rpm -ivh /tmp/elasticsearch-6.2.4.rpm
    # Downloading rpm package of logstash
    sudo wget --directory-prefix=/tmp/ https://artifacts.elastic.co/downloads/logstash/logstash-6.2.4.rpm
    # Install logstash rpm package
    sudo rpm -ivh /tmp/logstash-6.2.4.rpm
    # Download kibana tarball in /tmp
    sudo wget --directory-prefix=/tmp/ https://artifacts.elastic.co/downloads/kibana/kibana-6.2.4-x86_64.rpm
    # Install rpm package of kibana
    sudo rpm -ivh /tmp/kibana-6.2.4-x86_64.rpm
    # Starting The Services
    sudo systemctl daemon-reload
    sudo systemctl enable elasticsearch.service
    sudo systemctl enable logstash.service
    sudo systemctl enable kibana.service
    sudo systemctl restart elasticsearch.service
    sudo systemctl restart logstash.service
    sudo systemctl restart kibana.service
}

firewall_elk_rpm() {
    #Setup firewall rules
    sudo firewall-cmd --permanent --zone=public --add-port=5601/tcp 
    sudo firewall-cmd --permanent --zone=public --add-port=9200/tcp 
    sudo firewall-cmd --permanent --zone=public --add-port=9300/tcp
    sudo firewall-cmd --permanent --zone=public --add-port=5044/tcp
    sudo firewall-cmd --reload
    #Test APP
    curl -X GET http://localhost:9200
    curl -X GET http://localhost:5601
}

firewall_elk_deb() {
    #Setup firewall rules
    sudo iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 5601 -j ACCEPT 
    sudo iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 9200 -j ACCEPT
    sudo iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 9300 -j ACCEPT 
    sudo iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 5044 -j ACCEPT
    sudo service iptables save
    sudo service iptables restart
}

# Installing ELK Stack
if [ "$(grep -Ei 'debian|buntu|mint' /etc/*release)" ]
    then
        echo " It's a Debian based system"
        dependency_check_deb
        debian_elk
        firewall_elk_deb
        
elif [ "$(grep -Ei 'fedora|redhat|centos' /etc/*release)" ]
    then
        echo "It's a RedHat based system."
        dependency_check_rpm
        rpm_elk
        firewall_elk_rpm
else
    echo "This script doesn't support ELK installation on this OS."
fi
