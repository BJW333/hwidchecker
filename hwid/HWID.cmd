@shift /0
@echo off 
title HWID^>
color 0A
REM mode con COLS=80 LINES=26
Rd "%WinDir%\system32\test_permissions" >NUL 2>NUL
Md "%WinDir%\System32\test_permissions" 2>NUL||(echo.&Echo.____Please run with admin! &&Pause>nul&&Exit)
Rd "%WinDir%\System32\test_permissions" 2>NUL
setlocal EnableExtensions
setlocal EnableDelayedExpansion
set "Back=Please press any key to go back...&&pause>nul"
set "Back1=Please press any key to go back and re-enter...&&pause>nul"
set "Website=^|________________________ HWID ________________________^|"
reg add "HKCU\Software\Microsoft\InputMethod\Settings\CHS" /v "Default Mode" /t REG_DWORD /d 1 /f
if /i %PROCESSOR_ARCHITECTURE% equ AMD64 ( set "Bit=64" ) else ( set "Bit=86" )
for /f "tokens=4 delims= " %%i in ('reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v "ProductName"') do (set "Version=%%i")
ver|findstr "版本" >nul&&set "HostLanguage=zh-CN"||set "HostLanguage=en-US"
:Begin
title HWID
mode con COLS=104 LINES=55

cls
echo.
echo.      __________________________________ HWID _________________________________
echo.
echo.      BaseBoard:
echo. 
for /f "tokens=* delims=" %%a in ('reg query "HKLM\HARDWARE\DESCRIPTION\System\BIOS" /v "SystemManufacturer"') do (set "Brand=%%a")
echo.            Brand:%Brand:~36%
for /f "tokens=* delims=" %%a in ('reg query "HKLM\HARDWARE\DESCRIPTION\System\BIOS" /v "BaseBoardProduct"') do (set "model=%%a")
echo.            Model:%model:~34%
set tee=0
for /f "skip=1 tokens=*" %%a in ('wmic bios get serialnumber') do (
	set /a tee+=1
	if "!tee!" == "1" echo.            SN:%%a
)
echo. 
wmic csproduct get Name /value
 echo.      Bios:
echo. 
for /f "tokens=3 delims= " %%a in ('reg query "HKLM\HARDWARE\DESCRIPTION\System\BIOS" /v "BIOSReleaseDate"') do (
	for /f "tokens=1-3 delims=/" %%b in ("%%a") do (echo.            BIOSReleaseDate:%%d %%b %%c)
)
echo.      CPU:
set tee=0
for /f "skip=1 tokens=*" %%a in ('wmic cpu get name') do (
	set /a tee+=1
	if "!tee!" == "1" echo.            CPU Model:%%a
)
echo. 
echo.      mEMORY:
set tee=0
for /f "skip=1 tokens=*" %%a in ('wmic os get TotalVisibleMemorySize')  do (
	set /a tee+=1
	if "!tee!" == "1" set /a res = %%a/1000/1024
)
echo.            MemorySize:%res%G
echo. 
echo       Boot:
bcdedit|findstr /i "winload.efi">nul 2>nul && set "BootType=UEFI" || set "BootType=传统"
echo. 
echo.            BootType:%BootType%
echo. 
echo.      Disk:
if /i %BootType% == Uefi (
	echo.            BootType:GPT
) else (
	echo.            BootType:MBR
)
for /f "tokens=* delims=" %%a in ('wmic diskdrive get Caption^,InterfaceType^,Size^,Status^,Index^') do (echo.            %%a)

echo. CPU SN
wmic cpu get serialnumber
echo. DiskDrive SN
wmic diskdrive get serialnumber
echo. BaseBoard SN
wmic baseboard get serialnumber
echo. BIOS SN
wmic bios get SerialNumber
echo. Motherboard ID
wmic path Win32_ComputerSystemProduct get IdentifyingNumber
echo. Motherboard UUID
wmic path Win32_ComputerSystemProduct get UUID

echo. Adapter
@echo off&color 0A&&setlocal EnableDelayedExpansion
for /f "tokens=*" %%i in ('ipconfig /all^|findstr /i "描述 物理地址"') do set "qq=%%i"&&set "qq=!qq:. =!"&&echo.!qq!
for /f "tokens=*" %%i in ('ipconfig /all^|findstr /ic:"Description" /ic:"Physical Address"') do set "qq=%%i"&&set "qq=!qq:. =!"&&echo.!qq!
echo.
echo.
echo._________________________________HWID_________________________________  
pause>nul
goto exit