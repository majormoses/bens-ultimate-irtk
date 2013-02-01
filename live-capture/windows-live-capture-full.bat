cls
REM	Windows Live Capture: This software is inteded to be used
REM	for a live capture on a compromised Windows Server 2003-2008,
REM	and Windows 7 Pro and some functionality may work in Windows XP.
REM	Unfortunately quite a bit may not work on "Home or Basic" versions
REM	of Windows. You have been Warned.
REM
REM	Copyright (C) <2012>  <Ben Abrams>
REM
REM	This program is free software: you can redistribute it and/or
REM	modify it under the terms of the GNU General Public License as
REM	published by the Free Software Foundation, either version 3 of
REM	the License, or (at your option) any later version.
REM
REM	This program is distributed in the hope that it will be useful,
REM	but WITHOUT ANY WARRANTY; without even the implied warranty of
REM	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
REM	GNU General Public License for more details.
REM
REM	You should have received a copy of the GNU General Public License
REM	along with this program.  If not, see <http://www.gnu.org/licenses/gpl-3.0.html/>.

REM DEBUG MODE IF debug=1 debugging is enabled IF debug=0 debugging is off
:DEBUGMODE
set debug=1


REM Mount a drive somewhere to copy reports to
:REPORTLOCATION
REM set /P reports=[Where would you like these reports sent?]
set reports=C:\Users\%USERNAME%\Desktop\sp\reports\live-capture\windows\%COMPUTERNAME%
mkdir %reports%
if %debug%==1 (
	echo '#### report location completed ####' >> %reports%\debug.txt)
	
echo %COMPUTERNAME% > %reports%\computername.out
if %debug%==1 (
	echo '#### computer name completed ####' >> %reports%\debug.txt)
REM Get DATE
echo "Your Machine thinks it is: " %DATE% > %reports%\date.out
if %debug%==1 (
	echo '#### get date completed ####' >> %reports%\debug.txt)
REM Gets Logical and Physical Disks
:DRIVELAYOUT
wmic diskdrive list brief > %reports%\physicaldisks.out
if %debug%==1 (
	echo '#### get physical disk completed ####' >> %reports%\debug.txt)
wmic logicaldisk get caption,volumename > %reports%\logicaldisks.out
if %debug%==1 (
	echo '#### get logical disk completed ####' >> %reports%\debug.txt)

REM DUMP Physical Memory
:RAMDUMP
echo 'this can take a really long time'
choice.exe /C yn /M "Capture Ram: y/n. Timeout 10 seconds default No" /D n /T 10
if %debug%==1 (
	echo '#### RAM DUMP completed ####' >> %reports%\debug.txt
	if %errorlevel%==2 echo 'skipping RAM DUMP' >> %reports\debug.txt)
if %errorlevel%==2 do GOTO FILESBYDATE
if %errorlevel%==1 do dd if=\\.\PhysicalMemory of=%reports%\memory.img --progress
if %debug%==1 (
	echo '#### RAM DUMP completed ####' >> %reports%\debug.txt)
REM Get files and folders on system, sorted by date
:FILESBYDATE
echo 'this can take a really long time, getting started'
if exist %reports%\files-by-date.out del %reports%\files-by-date.out
for /f %%f in ('wmic logicaldisk get caption') do for /f %%d in ('dir %%f') do dir /O-D /S %%f\ >> %reports%\files-by-date.out
if %debug%==1 (
	echo '#### getting files by date completed ####' >> %reports%\debug.txt)
REM File/Folder tree
:TREE
for /f %%f in ('wmic logicaldisk get caption') do tree.com /A %%f >> %reports%\tree.out

REM List Running Processes
:PROCESSES
tasklist.exe > %reports%\processes.out


REM List all open ports
:OPENPORTS
netstat.exe -abo > %reports%\ports.out

REM Check Windows Resources for integrity violations
:SFC
sfc.exe /verifyonly > %reports%\integrity.out

REM List all network configurations
:NETCONFIG
ipconfig.exe /all > %reports%\netconfig.out

REM List all Windows Firewall Rules
:WINFIREWALL
netsh advfirewall firewall show rule all > %reports%\firewall.out

REM Capture outgoing network traffic for 15 minutes
:NETCAPTURE

REM Capture list of Scheduled Tasks
:SCHEDULEDTASKS
schtasks.exe /query /fo LIST  > %reports%\tasks.out

REM List of Users
:LISTUSERS
if exist %HOMEDRIVE%\Users (
	SET profileBase=%HOMEDRIVE%\Users)
REM MUST BE XP/Server 2003
else (
	SET profileBase="%HOMEDRIVE%\Documents and Settings")

dir /B %profileBase%\* > users.out

REM Capture all PATH variables
:PATHVARIABLES
PATH > %reports%\path.out

REM List Startup Applications
:STARTUPAPPLICATIONS
wmic startup get caption,name,location > %reports%\startup.out


REM Capture several Windows Logs {Security, System, Application}
:WINLOGS
wevtutil.exe epl Security %reports%\security.evt
wevtutil.exe epl System %reports%\system.evt
wevtutil.exe epl Application %reports%\application.evt

REM Export Registery
:EXPORTREG
regedit /e %reports%\registery.reg

REM Tries to get a list of instaled software
:INSTALLEDPROGRAMS
if exist %reports%\installed-export.out del %reports%\installed-export.out
regedit /e %reports%\installed-export.out "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall"
find "DisplayName" %reports%\installed-export.out > %reports%\installed.out


REM Grab list of downloads

echo "I will attempt to grab file and folder"
echo "names users downloads stored on system"
echo "chances are if you Roaming Profiles"
echo "you will be asked where they are"
echo "if you don't care about them answer"
echo "the same as if you didnt have any."

REM Asks if using Roaming Profiles
:ASKROAMINGPROFILES
choice.exe /C ynb /M "Roaming Profiles: y/n or b to break. Timeout 30 seconds, default is No" /D n /T 30
if %errorlevel%==3 do GOTO END
if %errorlevel%==2 do GOTO GRAB DOWNLOADS
if %errorlevel%==1 do GOTO ROAMINGDOWNLOADS

REM Grab list of files in Downloads Folder
:GRABDOWNLOADS
for /f %%f in ('dir /b %profileBase%\') do for /f %%d in ('dir /b %profileBase%\%%f\Downloads') do dir /S %profileBase%\%%f\Downloads > %reports%\downloads.out

REM Get Roaming Profiles
:GETROAMINGPROFILELOCATION

echo "the account you are running this as must have"
echo "permission to access the roaming profiles, likley"
echo "needs to be run as domain admin, or sudoer"

SET /P roamingProfileBase=[Where are your roaming profiles exsist?]
if exist %roamingProfileBase% (
	for /f %%f in ('dir /b %roamingProfileBase%\') ^
	 do for /f %%d in ('dir /b %roamingProfileBase%\%%f\Downloads') ^
	 do dir /S %roamingProfileBase%\%%f\Downloads > %reports%\roaming-downloads.out)
else(
	echo "you must have typed wrong, or don't have permission"
	GOTO ASKROAMINGPROFILES)

REM GPOINFO
:GPOINFO

gpresult.exe /Z > %reports%\gpo-info.out

REM AUTORUNSETC
:AUTORUNSETC


REM AD Info
:ADINFO


	
pause
:END
