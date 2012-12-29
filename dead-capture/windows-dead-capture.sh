#!/bin/bash

#	Windows Dead Capture: This software is inteded to be used
#	for a dead capture on a compromised Windows Server 2003-2008,
#	and Windows 7 Pro and some functionality may work in Windows XP.
#	Unfortunately quite a bit may not work on "Home or Basic" versions
#	of Windows. You have been Warned.
#
#	Copyright (C) <2012>  <Ben Abrams>
#
#	This program is free software: you can redistribute it and/or
#	modify it under the terms of the GNU General Public License as
#	published by the Free Software Foundation, either version 3 of
#	the License, or (at your option) any later version.
#
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
#	You should have received a copy of the GNU General Public License
#	along with this program.  If not, see <http://www.gnu.org/licenses/gpl-3.0.html/>.



# Get computer name
# Reg value in HKLM\SYSTEM\ControlSet001\Control\ComputerName\ActiveComputerName\ComputerName


# Mount a drive somewhere to copy reports to

# Get Local Time and Date

# Get Time from pool.ntp.org

# Gets Logical and Physical Disks

# Get files and folders on system, sorted by date
ls -lRa $mountedSystem/ > $reports/files-sorted.out

# Check Windows Resources for integrity violations

# List all network configurations
# export HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\services\Tcpip\Parameters\Interfaces
# export HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\services\Tcpip6\Parameters\Interfaces
# List all Windows Firewall Rules

# Capture list of Scheduled Tasks

# List of Users


# Capture all PATH variables

# List Startup Applications

# Capture several Windows Logs {Security, System, Application}

# Export Registery

# Tries to get a list of instaled software

# Grab list of downloads

echo "I will attempt to grab file and folder"
echo "names users downloads stored on system"
echo "chances are if you Roaming Profiles"
echo "you will be asked where they are"
echo "if you don't care about them answer"
echo "the same as if you didnt have any."

# Asks if using Roaming Profiles

# Grab list of files in Downloads Folder

# Get Roaming Profiles

echo "the account you are running this as must have"
echo "permission to access the roaming profiles, likley"
echo "needs to be run as domain admin, or sudoer"

# grab ip configs in reg Computer\HKEY_LOCAL_MACHINE\SYSTEM\COntrolSet001\Tcpip\Parameters\Interfaces as well as Computer\HKEY_LOCAL_MACHINE\SYSTEM\COntrolSet001\TCPIP6\Parameters\Interfaces

# windows fw exceptions in reg Computer\HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\services\SharedAccess\Parameters\FirewallPolicy\FirewallRules

# Get list of scheduled tasks these are located in C:\Windows\System32\Tasks

# cp the actual scheduled tasks these are located in C:\Windows\System32\Tasks

# list users

# enviornmental variables for user located in Computer\HKEY_CURRENT_USER\Environment

# enviornmental variables for system located in Computer\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SessionManager\Environment

# list downloads

