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
fdisk -l
echo 'modify system partition layout before continuing'
echo 'root in dev/sdXY'
read deadCaptureRoot




chrootedSystem='/media/root'
reports=


#chroot
mkdir -p /media/root/
mount $deadCaptureRoot $chrootedSystem
mount --bind /dev $chrootedSystem/dev
mount --bind /proc $chrootedSystem/proc
chroot $chrootedSystem

# firewall rules
sudo iptables -L -V -n


# Verify Linux tools have not been tampered with
#debian
debsums -clsg > $reports/debsums.out &
# EPL rpm systems
rpm -Va > rpm-md5.out &

# Grab version of kernel
ls -l $chrootedSystem/boot/ | grep vmlinuz | awk '{print $8}' | tail -1 > $reports/kern-version.out

# Grab kernel modules loaded
lsmod > $reports/kern-modules-loaded.out

# Grab detailed information about kernel modules loaded
for i in $(lsmod | awk '{print $1}');
do
	modinfo $i >> $reports/drivers-loaded.out;
done

# grab /etc/
rsync -arvP $chrootedSystem/etc $reports/etc
# grab /var/
rsync -arvP $chrootedSystem/etc $reports/var
