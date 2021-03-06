@ECHO OFF
TITLE Charon v0.6.5
COLOR 0c
::Created by the GCM team::
::Lane Garland (aka need2)::
::Samuel Brisby (aka spamuel42)::
::Tom B (aka r3l0ad)::
::Revision 0.6.5::

::Begin OS detection::
::Set default value. If OS is not found, then we don't support it!::
SET det_os=0

ver | findstr /i "5\.1\." > nul
IF %ERRORLEVEL% EQU 0 (
	SET det_os=5
	GOTO TOOLBOX
)

ver | findstr /i "6\.0\." > nul
IF %ERRORLEVEL% EQU 0 SET det_os=6

ver | findstr /i "6\.1\." > nul
IF %ERRORLEVEL% EQU 0 SET det_os=7

ver | findstr /i "6\.2\." > nul
IF %ERRORLEVEL% EQU 0 SET det_os=8

IF %det_os%==unsupp (
	GOTO UNSUPP
) ELSE (
	GOTO ELEVATE
)

:UNSUPP
::Report unsupported OS::
ECHO OS Unsupported. The tools will not run for your safety.
ECHO If you believe this is wrong, or know that these tools are
ECHO safe in your OS, please create an issue report at:
ECHO https://github.com/clique-mob/Project_Charon
PAUSE
GOTO :EOF

:ELEVATE
::Begin admin check::
>NUL 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

::If error flag is not zero, charon does not have admin rights::
IF %errorlevel% NEQ 0 (
    ECHO Requesting administrative privileges, please allow or this tool cannot run.
    GOTO UACPROMPT
) ELSE ( GOTO GOTADMIN )

:UACPROMPT
::Creates a temporary script to request administrative rights for a new instance of charon::
ECHO SET UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
ECHO UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"

"%temp%\getadmin.vbs"
EXIT /B

:GOTADMIN
::Cleanup after temporary script::
IF EXIST "%temp%\getadmin.vbs" DEL "%temp%\getadmin.vbs"
PUSHD "%CD%"
CD /D "%~dp0"

:TOOLBOX
::Toolbox main menu::
CLS
ECHO Welcome to the Charon Windows Multitool.
ECHO The following are tools for fixing various issues that can arise in Windows.
ECHO Please report issues to https://github.com/Clique-Mob/Project_Charon/issues
ECHO WARNING: I am not responsible for you breaking anything with this tool.
ECHO ----------------------------------------------------------------------------
ECHO.
ECHO.
ECHO 1. CD/DVD Drive registry fixer
ECHO 2. Reset HP Recovery Media creation software
ECHO 3. Start Windows Secure File Checker (SFC)
ECHO 4. Create the SFC log for Vista, 7, and 8
ECHO 5. Mass DLL register/unregister
ECHO 6. Unhide all User files
ECHO 7. Fix opening web page links in other programs (ie. Outlook)
::ECHO 8. Reset .DLL and/or .EXE handling
ECHO 8. Remove Internet Explorer Flash in Windows 8
ECHO 9. Prepare Windows for SATA mode switch.
ECHO 10. Quit
ECHO.
SET menu_option=""
SET /p menu_option= Please select an option: 
IF %menu_option%==1 GOTO CD_REG_FIX
IF %menu_option%==2 GOTO HP_MEDIA
IF %menu_option%==3 GOTO SFC
IF %menu_option%==4 GOTO SFC_LOG
IF %menu_option%==5 GOTO DLL
IF %menu_option%==6 GOTO UNHIDE
IF %menu_option%==7 GOTO WEBLNK
::IF %menu_option%==8 GOTO HANDLER
IF %menu_option%==8 GOTO IEFLASH
IF %menu_option%==9 GOTO SATA
IF %menu_option%==10 GOTO EOF
ECHO Not a valid option, please choose again.
GOTO TOOLBOX

:CD_REG_FIX
::cd/dvd reg fix tool::
CLS
ECHO This tool will remove the registry keys responsible for causing Windows
ECHO to fail to load the drivers for CD and DVD drives. No side effects known.
ECHO.
ECHO Do you want to run this tool?
ECHO 1. Yes
ECHO 2. No
ECHO.
SET menu_option=""
SET /p menu_option= Select an option: 
IF %menu_option%==1 ECHO Running...
IF %menu_option%==2 GOTO TOOLBOX
IF NOT %menu_option%==1 IF NOT %menu_option%==2 GOTO TOOLBOX

REG DELETE HKLM\SYSTEM\CurrentControlSet\Control\Class\{4D36E965-E325-11CE-BFC1-08002BE10318} /v UpperFilters /f
REG DELETE HKLM\SYSTEM\CurrentControlSet\Control\Class\{4D36E965-E325-11CE-BFC1-08002BE10318} /v LowerFilters /f

ECHO Complete. Please restart the computer or Disable/Enable the drive in Device
ECHO Manager to finish the fix.
PAUSE
GOTO TOOLBOX

:HP_MEDIA
::HP recovery media creation reset tool::
CLS
ECHO This tool will reset the HP Recovery Media Creator program to its
ECHO default state, allowing you to make additional sets of recovery
ECHO discs.
ECHO.
ECHO Do you want to run this tool?
ECHO 1. Yes
ECHO 2. No
ECHO.
SET menu_option=""
SET /p menu_option= Select an option: 
IF %menu_option%==1 ECHO Running...
IF %menu_option%==2 GOTO TOOLBOX
IF NOT %menu_option%==1 IF NOT %menu_option%==2 GOTO TOOLBOX

MKDIR C:\recovery_temp
IF EXIST D:\hp\CDCreatorLog MOVE D:\hp\CDCreatorLog\*.* C:\recovery_temp
IF EXIST D:\RMCStatus.bin MOVE D:\RMCStatus.bin C:\recovery_temp
IF EXIST C:\Windows\System32\Rebecca.dat MOVE C:\Windows\System32\Rebecca.dat C:\recovery_temp
IF EXIST "C:\Program Files (x86)\Hewlett-Packard\HP Recovery Manager\RMCStatus.bin" MOVE "C:\Program Files (x86)\Hewlett-Packard\HP Recovery Manager\RMCStatus.bin" C:\recovery_temp
IF EXIST D:\HPCD.SYS MOVE D:\HPCD.SYS C:\recovery_temp
IF EXIST C:\Windows\SMINST\HPCD.SYS MOVE C:\Windows\SMINST\HPCD.SYS C:\recovery_temp
IF EXIST C:\ProgramData\Hewlett-Packard\Recovery\hpdrcu.prc MOVE C:\ProgramData\Hewlett-Packard\Recovery\hpdrcu.prc C:\recovery_temp
IF EXIST D:\hpdrcu.prc MOVE D:\hpdrcu.prc C:\recovery_temp

ECHO Files moved... you can delete C:\recovery_temp if you don't want
ECHO backups of removed files.
PAUSE
GOTO TOOLBOX

:SFC
::Windows Secure File Checker helper tool::
CLS
ECHO This tool will start the Windows Secure File Checker for your OS.
ECHO This will verify that various critical Windows files are in their
ECHO original state, unmodified and unmoved. If they are changed it will
ECHO try to replace the damaged file with a clean copy. XP may prompt for
ECHO your install disc. This can also undo some changes made by third
ECHO party OS mods.
ECHO.
ECHO Do you want to run this tool?
ECHO 1. Yes
ECHO 2. No
ECHO.
SET menu_option=""
SET /p menu_option= Select an option: 
IF %menu_option%==1 ECHO Running...
IF %menu_option%==2 GOTO TOOLBOX
IF NOT %menu_option%==1 IF NOT %menu_option%==2 GOTO TOOLBOX

IF %det_os%==5 START sfc.exe /scannow
IF NOT %det_os%==5 START sfc /scannow
GOTO TOOLBOX

:SFC_LOG
::Retrieve the SFC log in Vista and 7::
CLS
ECHO This will retrieve the SFC log for Windows Vista, 7, and 8 then
ECHO place it in a text file on the current user's desktop. This log is
ECHO useful for reviewing files that were repaired or not repairable.
ECHO NOTE: XP stores it's SFC log in the Event Viewer in the System Events.
ECHO For XP, this tool will launch the Event Viewer.
ECHO.
ECHO Do you want to run this tool?
ECHO 1. Yes
ECHO 2. No
ECHO.
SET menu_option=""
SET /p menu_option= Select an option: 
IF %menu_option%==1 ECHO Running...
IF %menu_option%==2 GOTO TOOLBOX
IF NOT %menu_option%==1 IF NOT %menu_option%==2 GOTO TOOLBOX

IF %det_os%==5 (
	START eventvwr.exe
	GOTO TOOLBOX
) ELSE ( FINDSTR /c:"[SR]" %windir%\Logs\CBS\CBS.log >%userprofile%\Desktop\sfcdetails.txt)
GOTO TOOLBOX

:DLL
::DLL mass register / unregister::
CLS
ECHO This will register or unregister EVERY .dll in the folder you select.
ECHO This is useful for manually removing or repairing programs. Do NOT
ECHO use this unless you know what you are doing! You can break your OS.
ECHO.
ECHO Do you want to run this tool?
ECHO 1. Yes
ECHO 2. No
ECHO.
SET menu_option=""
SET /p menu_option= Select an option: 
IF %menu_option%==1 ECHO Running...
IF %menu_option%==2 GOTO TOOLBOX
IF NOT %menu_option%==1 IF NOT %menu_option%==2 GOTO TOOLBOX

:DLL_MENU_A
SET /p target= Please enter the full path to the folder containing the .DLL files: 
SET modtarget="%target%"
IF NOT EXIST %modtarget% ECHO Location does not exist! Try again.
IF NOT EXIST %modtarget% GOTO DLL_MENU_A
:DLL_MENU_B
SET /p state= Please either select (u)nregister or (r)egister: 
IF NOT %state%==u (
	IF NOT %state%==r (
		ECHO Not an available option (%state%). Please select 'u' or 'r'.
	)
) ELSE ( GOTO DLL_MENU_B )

IF %state%==r FOR %%i in (%modtarget%\*.dll) do regsvr32 "%%i"
IF %state%==u FOR %%i in (%modtarget%\*.dll) do regsvr32 /u "%%i"
PAUSE
GOTO TOOLBOX

:UNHIDE
::Mass Unhider for User files::
CLS
ECHO This tool will unhide all files in typical User folders. Useful in
ECHO cleaning up after some viruses that hide your files.
ECHO.
ECHO Do you want to run this tool?
ECHO 1. Yes
ECHO 2. No
ECHO.
SET menu_option=""
SET /p menu_option= Select an option: 
IF %menu_option%==1 ECHO Running...
IF %menu_option%==2 GOTO TOOLBOX
IF NOT %menu_option%==1 IF NOT %menu_option%==2 GOTO TOOLBOX

CLS
ECHO Please wait. This may take some time.
ATTRIB %UserProfile%\Desktop\* /d /s -h -s
ATTRIB %UserProfile%\Desktop\desktop.ini /d /s +h +s +a
ATTRIB %UserProfile%\My Documents\* /d /s -h -s
ATTRIB %UserProfile%\My Documents\desktop.ini /d /s +h +s +a
ATTRIB %UserProfile%\Favorites\* /d /s -h -s
ATTRIB %UserProfile%\Favorites\desktop.ini /d /s +h +s +a
IF NOT %det_os%==5 (
	ATTRIB %UserProfile%\My Music\* /d /s -h -s
	ATTRIB %UserProfile%\My Music\desktop.ini /d /s +h +s +a
	ATTRIB %UserProfile%\My Pictures\* /d /s -h -s
	ATTRIB %UserProfile%\My Pictures\desktop.ini /d /s +h +s +a
	ATTRIB %UserProfile%\My Videos\* /d /s -h -s
	ATTRIB %UserProfile%\My Videos\desktop.ini /d /s +h +s +a
	ATTRIB %UserProfile%\Contacts\* /d /s -h -s
	ATTRIB %UserProfile%\Contacts\desktop.ini /d /s +h +s +a
)
ECHO Complete.
PAUSE
GOTO TOOLBOX

:HANDLER
::Tool for resetting DLL and/or EXE handling::
CLS
ECHO IN DEVELOPMENT DO NOT USE
ECHO This tool will reset the way that Windows handles .DLL and/or
ECHO .EXE files, resolving issues where you get errors trying to
ECHO launch programs or services.
ECHO Not tested.
ECHO.
ECHO Do you want to run this tool?
ECHO 1. Yes
ECHO 2. No
ECHO.
SET menu_option=""
SET /p menu_option= Select an option: 
IF %menu_option%==1 ECHO Running...
IF %menu_option%==2 GOTO TOOLBOX
IF NOT %menu_option%==1 IF NOT %menu_option%==2 GOTO TOOLBOX

:HANDA
SET menu_option=""
ECHO Reset .DLL handling(d), .EXE handling(e), or both(b)?
ECHO /p menu_option= Please select (d, e, or b):
IF NOT %menu_option%==d IF NOT %menu_option%==e IF NOT %menu_option%==b GOTO HANDA

IF NOT %menu_option%==e (
	REG DELETE HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.dll\UserChoice
) ELSE (
	REG DELETE HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.exe
	REG ADD HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.exe
	REG ADD HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.exe\OpenWithList
	REG ADD HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.exe\OpenWithProgids
)

:HANDB
ECHO Complete.
PAUSE
GOTO TOOLBOX

:WEBLNK
::Tool for resetting web page link handling. For issues with opening links from other programs::
::such as Outlook.::
CLS
ECHO This tool will fix the way Windows handles wep page links
ECHO in non-broswer programs, fixing errors when clicking web
ECHO links. This issue seems to start most commonly from removing
ECHO Google Chrome, but could occur after removing any browser.
ECHO Example: Will fix errors when clicking a web link in Outlook.
ECHO Not tested.
ECHO.
ECHO Do you want to run this tool?
ECHO 1. Yes
ECHO 2. No
ECHO.
SET menu_option=""
SET /p menu_option= Select an option: 
IF %menu_option%==1 ECHO Running...
IF %menu_option%==2 GOTO TOOLBOX
IF NOT %menu_option%==1 IF NOT %menu_option%==2 GOTO TOOLBOX

REG ADD HKCU\Software\Classes\.htm /ve /d htmlfile /f 
REG ADD HKCU\Software\Classes\.html /ve /d htmlfile /f 
REG ADD HKCU\Software\Classes\.shtml /ve /d htmlfile /f 
REG ADD HKCU\Software\Classes\.xht /ve /d htmlfile /f 
REG ADD HKCU\Software\Classes\.xhtml /ve /d htmlfile /f

ECHO Complete. Please restart the computer to finish the fix.
PAUSE
GOTO TOOLBOX

:IEFLASH
::Tool for removing Internet Explorer Flash in Windows 8.::
CLS
ECHO This tool removes Flash for Internet Explorer in Windows 8.
ECHO There is no normal uninstall method for IE Flash otherwise.
ECHO This tool should NOT damage Flash for other browsers (ie. Firefox,
ECHO Chrome, Opera). Future Windows Updates may re-add IE Flash, so
ECHO you may have to rerun this after those updates if you want
ECHO to keep IE Flash off of your machine.
ECHO Not tested.
ECHO.
ECHO Do you want to run this tool?
ECHO 1. Yes
ECHO 2. No
ECHO.
SET menu_option=""
SET /p menu_option= Select an option: 
IF %menu_option%==1 ECHO Running...
IF %menu_option%==2 GOTO TOOLBOX
IF NOT %menu_option%==1 IF NOT %menu_option%==2 GOTO TOOLBOX

::Detect Windows 8. If not 8, do not run!::
IF NOT %det_os%==8 ECHO WARNING: NOT Windows 8. Tool will not run.
IF NOT %det_os%==8 PAUSE
IF NOT %det_os%==8 GOTO TOOLBOX

FOR %%i in (%WINDIR%\System32\Macromed\Flash\*.OCX) do regsvr32 /u "%%i"
FOR %%i in (%WINDIR%\System32\Macromed\Flash\*.OCX) do DEL /f "%%i"
IF EXIST %WINDIR%\System32\Macromed\Flash\*_ActiveX.dll (
	regsvr32 /u %WINDIR%\System32\Macromed\Flash\*_ActiveX.dll
	DEL /f %WINDIR%\System32\Macromed\Flash\*_ActiveX.dll
)
IF EXIST %WINDIR%\System32\Macromed\Flash\*_ActiveX.exe DEL /f %WINDIR%\System32\Macromed\Flash\*_ActiveX.exe
IF NOT EXIST %WINDIR%\SysWow64 GOTO ENDFLASH
FOR %%i in (%WINDIR%\SysWow64\Macromed\Flash\*.OCX) do regsvr32 /u "%%i"
FOR %%i in (%WINDIR%\SysWow64\Macromed\Flash\*.OCX) do DEL /f "%%i"
IF EXIST %WINDIR%\SysWow64\Macromed\Flash\*_ActiveX.dll (
	regsvr32 /u %WINDIR%\SysWow64\Macromed\Flash\*_ActiveX.dll
	DEL /f %WINDIR%\SysWow64\Macromed\Flash\*_ActiveX.dll
)
IF EXIST %WINDIR%\SysWow64\Macromed\FLash\*_ActiveX.exe DEL /f %WINDIR%\SysWow64\Macromed\Flash\*_ActiveX.exe

:ENDFLASH
ECHO Complete. Please restart the computer to complete removal.
PAUSE
GOTO TOOLBOX

:SATA
::Tool to reset what driver Windows loads for a SATA type drive. Forces Windows::
::to redetect best driver on reboot.::
CLS
ECHO This tool is for allowing you to change what mode your SATA
ECHO controller is in. For example, your system is running SATA in
ECHO IDE mode (slow), and you want AHCI (fast) or RAID. Running this
ECHO before restarting and changing the BIOS setting will prevent
ECHO Windows from crashing by telling Windows to redetect what type
ECHO of drive the OS is running on. Please make sure you have the
ECHO drivers for the new mode installed. First restart will be somewhat
ECHO slow, and one more restart will be required after successful
ECHO booting in the new SATA mode. This must be run EVERY time you
ECHO want to change SATA modes in the BIOS. Known to work in Vista
ECHO 7, and 8.
ECHO WARNING: MODIFICATIONS NOT TESTED IN XP.
ECHO Tool not tested.
ECHO.
ECHO Do you want to run this tool?
ECHO 1. Yes
ECHO 2. No
ECHO.
SET menu_option=""
SET /p menu_option= Select an option: 
IF %menu_option%==1 ECHO Running...
IF %menu_option%==2 GOTO TOOLBOX
IF NOT %menu_option%==1 IF NOT %menu_option%==2 GOTO TOOLBOX

set reg_det=0
REG QUERY HKLM\SYSTEM\CurrentControlSet\services\msahci /v Start || SET reg_det=1
IF %reg_det%==0 REG ADD "HKLM\SYSTEM\CurrentControlSet\services\msahci" /v Start /t reg_dword /d 0 /f

set reg_det=0
REG QUERY HKLM\SYSTEM\CurrentControlSet\services\pciide /v Start || SET reg_det=1
IF %reg_det%==0 REG ADD "HKLM\SYSTEM\CurrentControlSet\services\pciide" /v Start /t reg_dword /d 0 /f

set reg_det=0
REG QUERY HKLM\SYSTEM\CurrentControlSet\services\iaStorV /v Start || SET reg_det=1
IF %reg_det%==0 REG ADD "HKLM\SYSTEM\CurrentControlSet\services\iaStorV" /v Start /t reg_dword /d 0 /f

set reg_det=0
REG QUERY HKLM\SYSTEM\CurrentControlSet\services\Storahci /v Start || SET reg_det=1
IF %reg_det%==0 REG ADD "HKLM\SYSTEM\CurrentControlSet\services\Storahci" /v Start /t reg_dword /d 0 /f

ECHO.
ECHO Complete. It is now safe to reboot into the BIOS and
ECHO change your SATA controller's mode. Any "ERROR"s displayed
ECHO above are ok so long as at least two above operations completed.
PAUSE
GOTO TOOLBOX

:EOF
EXIT