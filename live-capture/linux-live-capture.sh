#!/bin/bash
set -e

#		Linux Live Capture: This software is inteded to be used
#	for a live capture on a compromised Debian Based Server, most
#	functionality will work on most distributions, some may
#	require packages installed. You may also have to find the equivalent
#	program for you Linux Distribution.
#
#     Copyright (C) <2012>  <Ben Abrams>
#
#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <http://www.gnu.org/licenses/gpl-3.0.html/>.




# CONFIG VARIABLES

# storage location for reports ( if value is ask it will prompt you for the location ) If you wish to preconfigure then simply put the path to the storage location and remove quotes
storage='/dev/sdg1'
reports='/media/sp'

# Whether you want  memdump (which mist be installed) valid options are true or false. default is false
mcap=false
# Whether you want to perform a packet capture valid oprions are true or false default is true
pcap=true
# length of desired packet capture this is in minutes
pcapLen=1
# Linux Distribution type: deb for any Debian based system epl for any YUM based system, gen for gentoo
distro='gen'
# Linux Tool verification methods options are: debsums (best debian results), rmp (best epl results), qcheck (best gentoo results) or md5 (fallback)
md5check='qcheck'

# It is recomended when doing a RAM dump to send the dump elsewhere as you will lose more information 
# by storing it locally this will be the IP or hostname of server where you have setup nc to listen on
# if ncServer is left 'none' than it will store it wherever the reports are being saved. This should only
# be performed on a LAN you can trust if you need SSL than please 
ncServer=false
# port that NC server is listening on
ncPort='none'
# netcat or openssl storage location modify path as desired
ncStorage=$reports/nc
mkdir -p $ncStorage

# to enable openssl please change 'false' to 'true' you must still configure ncServer,ncPort,ncStorage
opensslEnabled='false'



# Whoami
if [ "$(whoami)" != 'root' ]; then
		echo >&2 "no.  use something like: sudo -u root $0 $*"
		echo >&2 ' (in other words, run me as root)'
		exit 1
fi


# Copy Physical Memory; MUST HAVE memdump installed
# Check if RAM dump is requested
if [ $mcap==false ]; then
	echo 'just a reminder, you are not capturing a RAM dump,'
	echo 'if you want this stop and change the value of mcap to = true'
fi

# while [ $mcap==true ]
# do
# 	if [ -f /bin/memdump ] || [ -f /sbin/memdump ]; then
# # Checking to see if going to memdump local
# 		if [ $ncServer == 'false' ]; then
# # Using memdump locally
# 			sudo memdump > $reports/memdump.out
# 		fi
# # Checking if openssl is requested
# 		if [ $opensslEnabled == 'false' ]; then
# # Using nc to send memdump to specified nc server
# 			sudo memdump | nc $ncServer $ncPort < $ncStorage/memdump.out
# 		fi
# # Using openssl to send memdump to the specifed nc server
# 		if [ $opensslEnabled == 'false' ]; then
# #			sudo memdump | openssl s_client -connect $ncServer:$ncPort < $ncStorage/memdump.out
# 			echo "I would have done an memdump over ssl but its bork"
# 		fi
# 	$mcap=false
# 	else
# 		echo 'either disable RAM dump or memdump needs to be installed'
# 		if [ $distro == 'deb' ]; then
# 			echo 'try: sudo apt-get install memdump'
# 			exit
# 		fi

# 		if [ $distro == 'epl' ]; then
# 			echo 'either disable RAM dump or memdump needs to be installed'
# 			echo 'if rpmforge is not an enabled repo please add this repo'
# 			echo 'if you are insure how to do this please visit: http://www.centos.org/docs/5/html/yum/sn-using-repositories.html'
# 			echo 'once enabled try: sudo yum install memdump'
# 		fi

# 		if [ $distro == 'gen' ]; then
# 			echo 'either disable RAM dump or memdump needs to be installed'
# 			echo 'depending on needed USE flags try: emerge -av app-forensics/memdump'
# 		fi

# 		fi
# done


# Checking if memdump is installed
# Get hostname
hostname > $reports/hostname.out

# Get date
date > $reports/date.out

# List of running processes
ps aux > $reports/processes.out

# List of open ports
netstat -ae > $reports/ports.out

# firewall rules
sudo iptables -L -V -n > $reports/firewall.out

# Capture outgoing traffic for 5 minutes
if [ $pcap == true ]; then
	#checking to make sure you have tcpdump installed
	if [ -f /bin/tcpdump ] || [ -f /sbin/tcpdump ]; then
	echo 'performing packet capture on all interfaces for %pcapLen minutes'
	sudo tcpdump -G $pcapLen*60 -W 1 -w $reports/net-traffic.pcap
	fi
else
	echo 'tcpdump is not installed (at least in a standard location)'
	if [ $distro == 'deb' ]; then
		echo 'try sudo apt-get install tcpdump'
	elif [ $distro == 'epl' ]; then
		echo 'try yum installed tcpdump'
	elif [ $distro == 'gen' ]; then
		echo 'try emerge -av net-alayzer/tcpdump'
	else
		echo 'is your distro $(distro)?, if not set this correctly otherwise please submit a bug'
	fi
fi

# Verify Linux tools have not been tampered with
#debian based systems (for best results have debsums or rpm installed) otherwise more manual work is required
if [ $md5check == 'debsums' ]; then
	if [ -f /bin/debsums ] || [ -f /sbin/debsums ]; then
		sudo debsums -clsg > $reports/debsums.out &
	else
		echo 'you must install debsums or use an appropriate command'
		echo 'try sudo apt-get install debsums'
	fi
fi

if [ $md5check == 'rpm' ]; then
	if [ -f /bin/rpm ] || [ -f /sbin/rpm ]; then
	sudo rpm -Va > $reports/rpm-md5.out &
	else
		echo 'you must install rpm or use an appropriate command'
		echo 'try sudo yum install rpm'
	fi
fi


if [ $md5check == 'qcheck' ]; then
	if [ -f /usr/bin/qcheck ]; then
	sudo qcheck * > $reports/qcheck.out &
	else
		echo 'you must install qcheck or use an appropriate command'
		echo 'try sudo emerge portage-utils'
	fi
fi

if [ $md5check == 'md5' ]; then
	rm $reports/md5sums.out
	echo 'md5 values for /bin/' > $reports/md5sums.out
	sudo md5sum /bin/* >> $reports/md5sums.out
	echo 'md5 values for /sbin/' >> $reports/md5sums.out
	sudo md5sum /sbin/* >> $reports/md5sums.out
	echo 'for a quick breakdown of output meaning please read man/rpm-verify.html'
fi
# Grab version of kernel
uname -r > $reports/kern-version.out

# Grab kernel modules loaded
lsmod > $reports/kern-modules.out

#grabbing list of hardware and what kernel drivers handle
lspci -nqkvv > $reports/hardware-drivers.out

# Grab detailed information about kernel modules loaded
# for i in $(lsmod | awk '{print $1}');
# do
# 	modinfo $i >> $reports/drivers-loaded.out;
# done

# grab /etc/
rsync -arvP /etc $reports/etc
# grab /var/
rsync -arvP /var $reports/var

# get list of installed packages
if [ $distro == 'deb' ]; then
	dpkg --get seletions > $reports/deb-installed.out
elif [ $distro == 'epl'  ]; then
	yum list installed > $reports/yum-installed.out
elif [ $distr == 'gen' ]; then
	equery list "*"
else
	echo 'unknown distro cant get packages installed' >> $reports/debug.log
fi
