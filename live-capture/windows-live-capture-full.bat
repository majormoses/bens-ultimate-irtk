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


REM Get computer name
echo %COMPUTERNAME%

REM Mount a drive somewhere to copy reports to
LABEL REPORTLOCATION
set liveCaptureLocation=D:\School\it\4600\live-capture\
REM set /P reports=[Where would you like these reports sent?]
set reports=D:\School\it\4600\reports\%COMPUTERNAME%
echo %COMPUTERNAME% > %reports%\computername.out

REM Get DATE
echo "Your Machine thinks it is: " %DATE% > %reports%\date.out

REM Gets Logical and Physical Disks
LABEL DRIVELAYOUT
wmic diskdrive list brief > %reports%\physicaldisks.out
wmic logicaldisk get caption,volumename > %reports%\logicaldisks.out


REM DUMP Physical Memory
LABEL RAMDUMP
choice.exe /C yn /M "Capture Ram: y/n. Timeout 10 seconds default No" /D n /T 10
if %errorlevel%==2 do GOTO SFC
if %errorlevel%==1 do dd if=\\.\PhysicalMemory of=%reports%\memory.img --progress

REM Get files and folders on system, sorted by date
LABEL FILESBYDATE
for /f %%f in ('wmic logicaldisk get caption') do for /f %%d in ('dir %%f') do dir /O-D /S %%f\ > %reports%\files-by-date.out

REM File/Folder tree
LABEL TREE
for /f %%f in ('wmic logicaldisk get caption') do tree.com /A %%f >> \Users\diablo\Desktop\sp\tree.out

REM List Running Processes and Process Tree
LABEL TASKSRUNNNING
tasklist.exe > %reports%\reports\processes.out
%liveCaptureLocation%\SysinternalsSuite\pslist.exe -t > %reports%\ptree.out

REM List all open ports
LABEL OPENPORTS
netstat.exe -abo > %reports%\ports.out

REM Check Windows Resources for integrity violations
LABEL SFC
sfc.exe /verifyonly > %reports%\integrity.out

REM List all network configurations
LABEL NETCONFIG
ipconfig.exe /all > %reports%\netconfig.out

REM List all Windows Firewall Rules
LABEL WINFIREWALL
netsh advfirewall firewall show rule all > %reports%\firewall.out

REM Capture outgoing network traffic for 15 minutes
LABEL NETCAPTURE

REM Capture list of Scheduled Tasks
LABEL SCHEDULEDTASKS
schtasks.exe /query /fo LIST  > %reports%\tasks.out

REM List of Users
LABEL LISTUSERS
IF EXSIST %HOMEDRIVE%\Users (
	SET profileBase=%HOMEDRIVE%\Users)
REM MUST BE XP/Server 2003
ELSE (
	SET profileBase="%HOMEDRIVE%\Documents and Settings")

dir /B %profileBase%\* > users.out

REM Capture all PATH variables
LABEL PATHVARIABLES
PATH > %reports%\path.out

REM List Startup Applications
wmic startup get caption,name,location > %reports%\startup.out


REM Capture several Windows Logs {Security, System, Application}
LABEL WINLOGS
wevtutil.exe epl Security %reports%\security.evt
wevtutil.exe epl System %reports%\system.evt
wevtutil.exe epl Application %reports%\application.evt

REM Export Registery
LABEL EXPORTREG
regedit /e %reports%\registery.reg

REM Tries to get a list of instaled software
LABEL INSTALLEDPROGRAMS
If Exist %reports%\installed-export.out Del %reports%\installed-export.out
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
LABEL ASKROAMINGPROFILES
choice.exe /C ynb /M "Roaming Profiles: y/n or b to break. Timeout 30 seconds, default is No" /D n /T 30
if %errorlevel%==3 do GOTO END
if %errorlevel%==2 do GOTO GRAB DOWNLOADS
if %errorlevel%==1 do GOTO ROAMINGDOWNLOADS

REM Grab list of files in Downloads Folder
LABEL GRABDOWNLOADS
for /f %%f in ('dir /b %profileBase%\') do for /f %%d in ('dir /b %profileBase%\%%f\Downloads') do dir /S %profileBase%\%%f\Downloads > %reports%\downloads.out

REM Get Roaming Profiles
LABEL GETROAMINGPROFILELOCATION

echo "the account you are running this as must have"
echo "permission to access the roaming profiles, likley"
echo "needs to be run as domain admin, or sudoer"

SET /P roamingProfileBase=[Where are your roaming profiles exsist?]
if exsist %roamingProfileBase% (
	for /f %%f in ('dir /b %roamingProfileBase%\') ^
	 do for /f %%d in ('dir /b %roamingProfileBase%\%%f\Downloads') ^
	 do dir /S %roamingProfileBase%\%%f\Downloads > %reports%\roaming-downloads.out)
else(
	echo "you must have typed wrong, or don't have permission"
	GOTO ASKROAMINGPROFILES)

REM GPOINFO
LABEL GPOINFO

gpresult.exe /Z > %reports%\gpo-info.out

REM AUTORUNSETC
LABEL AUTORUNSETC
embeded\SysinternalSuite\autoruns.exe -ev %reports%\autoruns.arn

REM AD Info
LABEL ADINFO


	
pause
LABEL END
