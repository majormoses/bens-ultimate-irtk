#!/bin/bash
bash -e

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

#config variables
# length of desired packet capture this is in minutes
pcapLen = 1
# Whether you want  memdump (which mist be installed) valid options are true or flase. default is false
mcap=false
# Linux Distribution type: deb for any Debian based system yum for any YUM based system
distro = 'deb'
# Linux Tool verification methods options are: debsums (best results), rmp (better results), or md5 (default)
md5check='md5'






# Mount some storage to save reports to

# Copy Physical Memory MUST HAVE memdump installed
if [ $mcap=false ]; then
	echo 'just a reminder, you are not capturing a RAM dump, if you want this stop and change the value of mcap to = true'
	if [ -f /bin/memdumo || /sbin/memdump ]; then
		sudo memdump > $reports/memdump.out
		else
			echo 'either disable RAM dump or memdump needs to be installed'
			if [ $distro == 'deb' ]; then
				echo 'try: sudo apt-get install memdump'
				exit
			else
				echo 'either disable RAM dump or memdump needs to be installed'
				echo 'if rpmforge is not an enabled repo please add this repo'
				echo 'if you are insure how to do this please visit: http://www.centos.org/docs/5/html/yum/sn-using-repositories.html'
				echo 'once enabled try: sudo yum install memdump'
				exit
	fi
fi
# Get hostname
hostname > $reports/hostname.out

# Get date
adte > $reports/date.out

# List of running processes
ps aux > $reports/processes.out

# List of open ports
netstat -ape > $reports/ports.out

# firewall rules
sudo iptables -L -V -n

# Capture outgoing traffic for 5 minutes
sudo tcpdump -G $pcapLen*60 -W 1 -w $reports/net-traffic.pcap

# Verify Linux tools have not been tampered with
#debian based systems (for best results have debsums or rpm installed) otherwise more manual work is required 
if [ $md5check == 'debsums' ]; then
	sudo debsums -clsg > $reports/debsums.out &
elif [$md5check == 'rpm' ]; then
	sudo rpm -Va > $reports/rpm-md5.out &
else
	rm $reports/md5sums.out
	echo 'md5 values for /bin/' > $reports/md5sums.out
	sudo md5sum /bin/* >> $reports/md5sums.out
	echo 'md5 calues for /sbin/' >> $reports/md5sums.out
	sudo md5sum /sbin/* >> $reports/md5sums.out
	echo 'for a quick breakdown of output meaning please read man/rpm-verify.html'
fi
# Grab version of kernel
uname -r > $reports/kern-version.out

# Grab kernel modules loaded
lsmod > $reports/kern-modules.out

# Grab detailed information about kernel modules loaded
for i in $(lsmod | awk '{print $1}');
do
	modinfo $i >> $reports/drivers-loaded.out;
done

# grab /etc/
rsync -arvP /etc $reports/etc
# grab /var/
rsync -arvP /var $reports/var

# get list of installed packages
dpk --get seletions > $reports/deb-installed.out
yum list installed > $reports/yum-installed.out
