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

pause
:CONFIGURABLEVARS
REM if debug=1 debugging is enabled
REM if debug=0 debugging is off.
REM Default is usefull for auditiong and debugging purposes.
set debug=1
REM if execfilesbydate=1 it will run filebydate
REM if execfilesbydate=0 it will not run filesbydate
set execfilesbydate=0
REM if execsfc=1 it will run sfc
REM if execsfc=0 it will not run sfc
set execsfc=0
REM if execwinfw=1 it will grab windows firewall rules
REM if execwinfw=0 it will not gran windows firewall rules
set execwinfw=0


REM Mount a drive somewhere to copy reports to
:REPORTLOCATION
REM set /P reportbase=[Where would you like these reports sent?]
set reports=%USERPROFILE%\Desktop\sp\reports\live-capture\windows\%COMPUTERNAME%
if not exist "%reports%" mkdir "%reports%"

REM start time
for /f %%s in ('time /T') do SET stime=%%s
echo '#### starting time: %etime% ####' >> "%reports%\debug.txt"
echo '#### report location completed ####' >> "%reports%\debug.txt"
echo reports: %reports%	
if not exist %reports%\hostname.out del "%reports%\hostname.out"
echo %COMPUTERNAME% > "%reports%\hostname.out"
if %debug%==1 (
	echo '#### Debug Started ####' >> "%reports%\debug.txt"
	)
REM Get DATE
echo "Your Machine thinks it is: " %DATE% > "%reports%\date.out"
if %debug%==1 (
	echo '#### get date completed ####' >> "%reports%\debug.txt"
	)
REM Gets Logical and Physical Disks
:DRIVELAYOUT
wmic diskdrive list brief > "%reports%\physicaldisks.out"
if %debug%==1(echo '#### get physical disk completed ####' >> "%reports%\debug.txt")
wmic logicaldisk get caption,volumename > "%reports%\logicaldisks.out"
if %debug%==1 (
	echo '#### get logical disk completed ####' >> "%reports%\debug.txt"
	)

REM DUMP Physical Memory
:RAMDUMP
echo 'this can take a really long time'
choice.exe /C yn /M "Capture Ram: y/n. Timeout 10 seconds default No" /D n /T 10
if %debug%==1 (
	echo '#### RAM DUMP completed ####' >> "%reports%\debug.txt"
	if %errorlevel%==2 echo 'skipping RAM DUMP' >> "%reports%\debug.txt"
	)
if %errorlevel%==2 GOTO FILESBYDATE
if %errorlevel%==1 dd if=\\.\PhysicalMemory of="%reports%\memory.img" --progress
if %debug%==1 (
	echo '#### RAM DUMP completed ####' >> "%reports%\debug.txt"
	)
REM Get files and folders on system, sorted by date
:FILESBYDATE
if %execfilesbydate%==1 (
	echo 'this can take a REALLY LONG TIME, getting started'
	if exist "%reports%\files-by-date.out" del "%reports%\files-by-date.out"
	for /f %%f in ('wmic logicaldisk get caption') do for /f %%d in ('dir %%f') do dir /O-D /S %%f\ >> "%reports%\files-by-date.out"
	)
	if %debug%==1 (
		echo '#### getting files by date completed ####' >> "%reports%\debug.txt"
		)
	)
if execfilesbydate==0 (
	echo 'as per your configuration change it will not give you any files by date, this is not the default action' >> "%reports%\debug.txt"
	)


REM List Running Processes
:PROCESSES
tasklist.exe > "%reports%\processes.out"
if %debug%==1 (
	echo '#### getting processes completed ####' >> "%reports%\debug.txt"
	)

REM List all open ports
:OPENPORTS
netstat.exe -abo > "%reports%\ports.out"
if %debug%==1 (
	echo '#### getting ports completed ####' >> "%reports%\debug.txt"
	)

REM Check Windows Resources for integrity violations
:SFC
if %execsfc%==1 (
	sfc.exe /verifyonly > "%reports%\integrity.out"
	if %debug%==1 (
		echo '#### SFC completed ####' >> "%reports%\debug.txt"
		)
	)

REM List all network configurations
:NETCONFIG
ipconfig.exe /all > "%reports%\netconfig.out"
if %debug%==1 (
	echo '#### getting network config completed ####' >> "%reports%\debug.txt"
	)

REM List all Windows Firewall Rules
:WINFIREWALL
if %execwinfw%==1 (
	netsh advfirewall firewall show rule all > "%reports%\firewall.out"
	if %debug%==1 (
		echo '#### getting windows fireall rules completed ####' >> "%reports%\debug.txt"
		)
	)
REM Capture outgoing network traffic for 15 minutes
:NETCAPTURE

REM Capture list of Scheduled Tasks
:SCHEDULEDTASKS
schtasks.exe /query /fo LIST  > "%reports%\tasks.out"
if %debug%==1 (
	echo '#### GPO INFO completed ####' >> "%reports%\debug.txt"
	)

REM List of Users
:LISTUSERS
set profileBase=%HOMEPATH%\..\

dir /B %profileBase% > "%reports%\users.out"
if %debug%==1 (
	echo '#### LIST USERS completed ####' >> "%reports%\debug.txt"
	)

REM Capture all PATH variables
:PATHVARIABLES
PATH > "%reports%\pathvar.out"
if %debug%==1 (
	echo '#### GET PATHVARIABLES completed ####' >> "%reports%\debug.txt"
	)

REM List Startup Applications
:STARTUPAPPLICATIONS
wmic startup get caption,name,location > "%reports%\startup.out"
if %debug%==1 (
	
	echo '#### GET STARTUP APPLICATIONS completed ####' >> "%reports%\debug.txt"
	)


REM Capture several Windows Logs {Security, System, Application}
:WINLOGS
if exist "%reports%\security.evt" del "%reports%\security.evt"
wevtutil.exe epl Security "%reports%\security.evt"
if exist %reports%\system.evt del "%reports%\system.evt"
wevtutil.exe epl System "%reports%\system.evt"
if exist "%reports%\application.evt" del "%reports%\application.evt"
wevtutil.exe epl Application "%reports%\application.evt"
if %debug%==1 (
	echo '#### GET WINLOGS completed ####' >> "%reports%\debug.txt"
	)

REM Export Registery
:EXPORTREG
regedit /e "%reports%\registery.reg"
if %debug%==1 (
	echo '#### REGISTRY EXPORT completed ####' >> "%reports%\debug.txt"
	)

REM Tries to get a list of instaled software
:INSTALLEDPROGRAMS
if exist "%reports%\installed-export.out" del "%reports%\installed-export.out"
regedit /e "%reports%\installed-export.out" "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall"
find "DisplayName" "%reports%\installed-export.out" > "%reports%\installed.out"

if %debug%==1 (
	echo '#### INSTALLED PROGRAMS completed ####' >> "%reports%\debug.txt"
	)


REM Grab list of downloads

echo "I will attempt to grab file and folder"
echo "names users downloads stored on system"
echo "chances are if you Roaming Profiles"
echo "you will be asked where they are"
echo "if you don't care about them answer"
echo "the same as if you didnt have any."

REM Asks if using Roaming Profiles
:ASKROAMINGPROFILES
choice.exe /C yn /M "Roaming Profiles: y/n Timeout 30 seconds, default is No" /D n /T 30
if %errorlevel%==2 GOTO GRABDOWNLOADS
if %errorlevel%==1 GOTO GETROAMINGPROFILELOCATION


REM Get Roaming Profiles
:GETROAMINGPROFILELOCATION

echo "the account you are running this as must have"
echo "permission to access the roaming profiles. Likley"
echo "needs to be run as: (domain) admin or equivalent"

set /P roamingProfileBase=['Where are your network profiles?']
if exist "%roamingProfileBase%" (
	for /f %%f in ('dir /b %roamingProfileBase%') do for /f %%d in ('dir /b %roamingProfileBase%\%%f\Downloads') do dir /S "%roamingProfileBase%\%%f\Downloads" > "%reports%\roaming-downloads.out"
	)
else (
	echo "you must have typed wrong, or don't have permission"
	GOTO ASKROAMINGPROFILES)

if %debug%==1 (
	echo '#### GOT ROAMING PROFILES LOCATION completed ####' >> "%reports%\debug.txt"
	)

REM Grab list of files in Downloads Folder
:GRABDOWNLOADS
echo %profilebase%
dir %profilebase%
for /f %%f in ('dir /b %profileBase%') do for /f %%d in ('dir /b %profileBase%\%%f\Downloads') do dir /S %profileBase%\%%f\Downloads > "%reports%\downloads.out"
if %debug%==1 (
	echo '#### GET DOWNLOADS completed ####' >> "%reports%\debug.txt"
	)
	
REM GPOINFO
:GPOINFO

gpresult.exe /Z > "%reports%\gpo-info.out"
if %debug%==1 (
	echo '#### GPO INFO completed ####' >> "%reports%\debug.txt"
	)
	
REM AUTORUNSETC
:AUTORUNSETC


REM AD Info
:ADINFO


REM Getting finished time
:ETIME
for /f %%e in ('time /T') do SET etime=%%e
echo '#### completion time: %etime% ####' >> "%reports%\debug.txt"
set /a %ttime%=%etime%-%stime%
echo %ttime% >> "%reports%\debug.txt"
 
pause
:END
