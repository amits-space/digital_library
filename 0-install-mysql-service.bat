@echo off
:: ============================================================
::  0-install-mysql-service.bat
::
::  Run this ONCE as Administrator to register MySQL as a
::  Windows Service. After this, MySQL will:
::    - Start automatically with Windows
::    - Always be available for Tomcat / your project
::
::  HOW TO RUN AS ADMIN:
::    Right-click this file → "Run as administrator"
:: ============================================================

echo.
echo  ================================================
echo   Installing MySQL as a Windows Service
echo   (This requires Administrator rights)
echo  ================================================
echo.

:: Stop any running mysqld first
taskkill /F /IM mysqld.exe 2>nul
ping -n 3 127.0.0.1 >nul

:: Register the service
echo [1/3] Registering MySQL80 service...
C:\mysql\bin\mysqld.exe --install MySQL80 --datadir="C:\mysql\data"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo  ERROR: Could not install service.
    echo  Make sure you right-clicked and chose "Run as administrator"!
    pause
    exit /b 1
)

:: Start the service
echo [2/3] Starting MySQL80 service...
net start MySQL80

if %ERRORLEVEL% NEQ 0 (
    echo  ERROR: Could not start MySQL80 service.
    pause
    exit /b 1
)

:: Load the schema
echo [3/3] Loading the digital_library schema...
ping -n 4 127.0.0.1 >nul
C:\mysql\bin\mysql.exe -u root --connect-timeout=10 -e "source C:/Users/amitr/OneDrive/Desktop/Other Projects/digital_library/DigitalLibrary/database/schema.sql"

echo.
echo  ================================================
echo   SUCCESS! MySQL is installed as a service.
echo.
echo   MySQL will now start automatically with Windows.
echo   You no longer need to run 1-start-mysql.bat.
echo   Just run 2-start-tomcat.bat directly!
echo  ================================================
echo.
pause
