@ECHO OFF
TITLE Charon v0.5.7
COLOR 0c
::Created by the GCM team::
::Lane Garland (aka need2)::
::Tom B (aka r3l0ad)::
::Revision 0.5.7::

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
::ECHO 7. Reset .DLL and/or .EXE handling
ECHO 7. Quit
ECHO.
SET menu_option=""
SET /p menu_option= Please select an option: 
IF %menu_option%==1 GOTO CD_REG_FIX
IF %menu_option%==2 GOTO HP_MEDIA
IF %menu_option%==3 GOTO SFC
IF %menu_option%==4 GOTO SFC_LOG
IF %menu_option%==5 GOTO DLL
IF %menu_option%==6 GOTO UNHIDE
::IF %menu_option%==7 GOTO HANDLER
IF %menu_option%==7 GOTO EOF
ECHO Not a valid option, please choose again.
GOTO TOOLBOX

:CD_REG_FIX
::cd/dvd reg fix tool::
CLS
ECHO This tool will remove the registry keys responsible for causing Windows
ECHO to fail to load the drivers for CD and DVD drives. No side effects known.
ECHO Restart or disable then enable the drive to see the results.
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
IF EXIST C:\Program Files (x86)\Hewlett-Packard\HP Recovery Manager\RMCStatus.bin MOVE C:\Program Files (x86)\Hewlett-Packard\HP Recovery Manager\RMCStatus.bin C:\recovery_temp
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
ECHO NOTE: Does not work in XP. Your SFC log is in your Event Viewer.
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

IF %det_os%==5 GOTO TOOLBOX
FINDSTR /c:"[SR]" %windir%\Logs\CBS\CBS.log >%userprofile%\Desktop\sfcdetails.txt
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
IF NOT EXIST %target% ECHO Location does not exist! Try again.
IF NOT EXIST %target% GOTO DLL_MENU_A
:DLL_MENU_B
SET /p state= Please either select (u)nregister or (r)egister: 
IF NOT %state%==u IF NOT %state%==r ECHO Not an available option (%state%). Please select 'u' or 'r'.
IF NOT %state%==u IF NOT %state%==r GOTO DLL_MENU_B

IF %state%==r FOR %%i in (%target%\*.dll) do regsvr32 %%i
IF %state%==u FOR %%i in (%target%\*.dll) do regsvr32 /u %%i
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
IF NOT %det_os%==5 ATTRIB %UserProfile%\My Music\* /d /s -h -s
IF NOT %det_os%==5 ATTRIB %UserProfile%\My Music\desktop.ini /d /s +h +s +a
IF NOT %det_os%==5 ATTRIB %UserProfile%\My Pictures\* /d /s -h -s
IF NOT %det_os%==5 ATTRIB %UserProfile%\My Pictures\desktop.ini /d /s +h +s +a
IF NOT %det_os%==5 ATTRIB %UserProfile%\My Videos\* /d /s -h -s
IF NOT %det_os%==5 ATTRIB %UserProfile%\My Videos\desktop.ini /d /s +h +s +a
IF NOT %det_os%==5 ATTRIB %UserProfile%\Contacts\* /d /s -h -s
IF NOT %det_os%==5 ATTRIB %UserProfile%\Contacts\desktop.ini /d /s +h +s +a
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

IF NOT %menu_option%==e REG DELETE HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.dll\UserChoice
IF NOT %menu_option%==e GOTO HANDB
REG DELETE HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.exe
REG ADD HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.exe
REG ADD HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.exe\OpenWithList
REG ADD HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.exe\OpenWithProgids

:HANDB
ECHO Complete.
PAUSE
GOTO TOOLBOX

:EOF
EXIT