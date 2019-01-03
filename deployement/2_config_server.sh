#!/bin/bash
# Configuration of server from non root user
PLAY_GAME="Please launch me again and play the game"
clear
echo "+-----------------------------------------------------------------------+"
echo "| Hello!                                                                |"
echo "| I am Jessy and I'll configurate your server in 5 secodns. I am        |"
echo "| not totaly automated (at least at the moment if my creator will not   |"
echo "| forget to to umake me more intellegent). I'll need your help.         |"
echo "| By the way, forgive my English, as my creator is not very good in     |"
echo "| English. So I have heritatedit from him.                              |"
echo "+-----------------------------------------------------------------------+"
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
sudo locale-gen en_US.UTF-8
sudo apt-get -yqq install git iptables-persistent fail2ban psad
sudo git clone https://github.com/4slan/roger-skyline-1.git rs1
read -p "Could you please configurate your interface as static (y/n) " -n 1
case $REPLY in
	[yY])
		sudo vi /etc/network/interfaces
		;;
	*)
		printf "\n$PLAY_GAME"
		echo
		exit 1
		;;
esac
echo
while read -p "Chose SSH port between 1000 and 65535 : " PORT;
do
	if ! [[ ( "$PORT" =~ ^[0-9]+$ ) ]]
	then
		echo "Sorry the port need to be and integer"
	else
		break
	fi
done
sudo sed -i "s/Port .*/Port ${PORT}/g" /etc/ssh/sshd_config
sudo sed -i "s/PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config
sudo service sshd restart
echo "You need to generate an key on your Host machine and copy it as follow"
printf "\tssh-keygen\n"
printf "\tssh-copy-id $USER@$(hostname -I)-p $PORT\n"
read -p "Do you confirm that you have copied your public key (y/n) " -n 1
case $REPLY in
	[yY])
		sudo sed -i "s/PubkeyAuthentication .*/PubkeyAuthentication yes/g" /etc/ssh/sshd_config
		sudo sed -i "s/PasswordAuthentication .*/PasswordAuthentication no/g" /etc/ssh/sshd_config
		;;
	*)
		printf "\n$PLAY_GAME\n"
		exit
		;;
esac
echo
echo "Now you are able to work through SSH from your machine which is great"
sudo cp ~/rs1/deployement/firewall /etc/init.d/
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo sed -i "s/action \= \%\(action\_\)s/action \= \%\(action_mwl\)s/g" /etc/fail2ban/jail.local
read -p "Please put enables = true, maxretry = 3, port = 2222 and logpath =/var/log/auth.log"
sudo vi /etc/fail2ban/jail.local
echo "Copy the following line in file that open when you press [enter]"
printf "kern.info\t|/var/lib/psad/psadfifo\n"
read
sudo vi /etc/syslog.conf
sudo service syslog restart
sudo sed -i "s/EMAIL_ADDRESSES .*/EMAIL_ADDRESSES\t\troot\@localhost\,amalsago\@student\.42\.fr;/g" /etc/psad/psad.conf
sudo sed -i "s/HOSTNAME .*/HOSTNAME\t\t$(hostname)/g" /etc/psad/psad.conf
sudo sed -i "s/ENABLE_SYSLOG_FILE .*/ENABLE_SYSLOG_FILE Y;/g" /etc/psad/psad.conf
sudo sed -i "s/IPT_WRITE_FWDATA .*/IPT_WRITE_FWDATA\tY;/g" /etc/psad/psad.conf
sudo sed -i "s/ENABLE_AUTO_IDS .*/ENABLE_AUTO_IDS\t\tY;/g" /etc/psad/psad.conf
sudo sed -i "s/AUTO_IDS_DANGER_LEVEL .*/AUTO_IDS_DANGER_LEVEL\t1;/g" /etc/psad/psad.conf
sudo psad --sig-update
sudo psad -R
sudo psad -S
sudo cp ~/rs1/deployement/update_packages /etc/cron.d/
sudo chmod +x /etc/cron.d/update_packages
sudo cp ~/rs1/deployement/cron_integrity /etc/cron.d/cron_integrity
sudo chmod +x /etc/cron.d/cron_integrity
echo "Write following line in crontab"
echo "0 4 * * 2       /etc/cron.d/update_packages"
echo "@reboot         /etc/cron.d/update_packages"
read -p "0 0 * * *       /etc/cron.d/cron_integrity"
sudo crontab -e
sudo rm -rf ~/rs1
sudo sh /etc/init.d/firewall
sudo netfilter-persistent save
