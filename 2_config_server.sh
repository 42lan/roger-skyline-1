#!/bin/bash
# Configuration of server from non root user
PLAY_GAME="Please launch me again and play the game"
clear
echo "Hello. I am Jesy and I'll configurate your server in 5 secodns."
echo "I am not totaly automated (at least at the moment if my creator will not forget"
echo "to umake me more intellegent) I'll need your help."
echo "By the way, forgive my for my English, as my creator is not very good in English"
echo "I have heritated it from him"
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
	if ! [[ "$PORT" =~ ^[0-9]+$ ]]
	then
		echo "Sorry the port need to be and integer"
	else
		break
	fi
done
sudo sed -i "s/Port .*/Port ${PORT}/g" /etc/ssh/sshd_config
sudo sed -i "s/PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config
sudo service sshd restart
echo "Now you need to denerate an key on your Host machine and copy it as follow"
printf "\tssh-keygen\n"
printf "\tssh-copy-id $USER@$(hostname -I)-p $PORT\n"
read -p "Do you confirm that you have copied your public key (y/n) " -n 1
case $REPLY in
	[yY])
		sudo sed -i "s/PubkeyAuthentification .*/PubkeyAuthentification yes/g" /etc/ssh/sshd_config
		sudo sed -i "s/PasswordAuthentification .*/PasswordAuthentification no/g" /etc/ssh/sshd_config
		;;
	*)
		printf "\n$PLAY_GAME\n"
		exit
		;;
esac
echo
echo "Now you are able to work on thid server through SSH from your machine which is great"
sudo apt-get install iptables-persistent
sudo cp firewall /etc/init.d/
sudo sh /etc/init.d/firewall
sudo netfilter-persistent save
sudo apt-get install fail2ban
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo sed -i "s/action \= \%\(action\_\)s/action \= \%\(action_mwl\)s/g" /etc/fail2ban/jail.local
read -p "Please put enables = true, maxretry = 3, port = 2222 and logpath  = /var/log/auth.log"
vi /etc/fail2ban/jain.local
sudo apt-get install psad
sudo echo "$IPT -A INPUT -j LOG" >> /etc/init.d/firewall
sudo echo "$IPT -A FORWARD -j LOG" >> /etc/init.d/firewall
sudo echo "kern.info	|/var/lib/psad/psadfifo" > /etc/syslog.conf
sudo service syslog restart
sudo sed -i "s/HOSTNAME .*/HOSTNAME ${REPLY}/g" /etc/ssh/sshd_config
sudo sed -i "s/ENABLE_SYSLOG_FILE .*/ENABLE_SYSLOG_FILE Y;/g" /etc/ssh/sshd_config
sudo sed -i "s/IPT_WRITE_FWDATA .*/IPT_WRITE_FWDATA Y;/g" /etc/ssh/sshd_config
sudo sed -i "s/ENABLE_AUTO_IDS .*/ENABLE_AUTO_IDS Y;/g" /etc/ssh/sshd_config
sudo sed -i "s/AUTO_IDS_DANGER_LEVEL .*/AUTO_IDS_DANGER_LEVEL 1;/g" /etc/ssh/sshd_config
sudo psad --sig-update
sudo psad -R
sudo psad -S
sudo echo "apt-get update" > /etc/cron.d/update_packages
sudo echo "(date && apt-get -y upgrade | tail -1; echo) &>> /var/log/update_script.log" > /etc/cron.d/update_packages
sudo chmod +x /etc/cron.d/update_packages
sudo cp cron_integrity /etc/cron.d/cron_integrity
sudo chmod +x /etc/cron.d/cron_integrity
read -p "Copy and add follow lines to crontab please"
printf "0 4 * * 2\t/etc/cron.d/update_packages\n"
printf "@reboot\t/etc/cron.d/update_packages\n"
printf "0 0 * * *\t/etc/cron.d/cron_integrity\n"
