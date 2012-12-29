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



# Mount some storage to save reports to

# Copy Physical Memory
sudo memdump > memdump.out
#sudo dd if=/dev/mem of=$remoteReports/ramdd.out

# Get hostname
hostname > $remoteReports/hostname.out

# Get date
adte > $remoteReports/date.out

# List of running processes
ps aux > $remoteReports/processes.out

# List of open ports
netstat -ape > $remoteReports/ports.out

# firewall rules
sudo iptables -L -V -n

# Capture outgoing traffic for 15 minutes
sudo tcpdump -G 300 -W 1 -w file.pcap

# Verify Linux tools have not been tampered with
#debian based systems
debsums -clsg > debsums.out &
# RHEL rpm systems
rpm -Va > rpm-md5.out &

# Grab version of kernel
uname -r > $remoteReports/kern-version.out

# Grab kernel modules loaded
lsmod > $remoteReports/kern-modules.out

# Grab detailed information about kernel modules loaded
for i in $(lsmod | awk '{print $1}');
do
	modinfo $i >> drivers-loaded.out;
done

# grab /etc/
rsync -arvP /etc remoteReports/etc
# grab /var/
rsync -arvP /var remoteReports/var
