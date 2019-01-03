#!/bin/bash
# Lauch from root
echo "Auto-configuration of the Debian OS"
read -p "Please enter username that you want create: " username
echo -ne "Confirm that you want configurate OS for \033[31m$username\033[0m (y/n) "
read -n 1 confirm
echo
case $confirm in
	[yY])
		apt-get update 
		apt-get -y upgrade | tail -1; echo
		apt-get install sudo git
		adduser $username
		adduser $username sudo
esac
