mkdir -p /root/.ssh/;
sed -e "s/echo;sleep 10;exit 142//g" -i /root/.ssh/authorized_keys;
echo "ssh-rsa {key-goes-here} koodeyo-cloud-production-key" >> /root/.ssh/authorized_keys;
echo "PubkeyAcceptedKeyTypes=+ssh-rsa" >> /etc/ssh/sshd_config;
service ssh restart;
