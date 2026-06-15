@echo off
:: ============================================================
::  1-start-mysql.bat
::
::  Starts MySQL as a PERSISTENT background process.
::  Run this as Administrator for best results.
::
::  IMPORTANT: The minimized "MySQLSrv" window that appears
::  in your taskbar MUST stay open while you use the app.
:: ============================================================

echo.
echo  ================================================
echo   Digital Library  ^|  Step 1: Start MySQL
echo  ================================================
echo.

:: Step 1: Kill any stale mysqld processes
echo [1/3] Stopping any existing MySQL processes...
taskkill /F /IM mysqld.exe 2>nul
ping -n 3 127.0.0.1 >nul

:: Step 2: Start mysqld in its own independent window
::   "start" without /B opens a completely separate process
::   that STAYS ALIVE after this .bat window closes.
echo [2/3] Starting MySQL server (a small window will open minimized)...
start "MySQLSrv" /MIN C:\mysql\bin\mysqld.exe --datadir=C:\mysql\data --port=3306

:: Wait for MySQL to fully initialize
echo      Waiting 8 seconds for MySQL to be ready...
ping -n 9 127.0.0.1 >nul

:: Step 3: Load the schema while mysqld is still up in this CMD session
echo [3/3] Loading the digital_library schema...
C:\mysql\bin\mysql.exe -u root --connect-timeout=10 -e "source C:/Users/amitr/OneDrive/Desktop/Other Projects/digital_library/DigitalLibrary/database/schema.sql"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo  ================================================
    echo   SUCCESS!
    echo   MySQL is running on port 3306.
    echo   digital_library database and tables are ready.
    echo.
    echo   IMPORTANT: Keep the "MySQLSrv" window in your
    echo   taskbar open while using the app!
    echo  ================================================
) else (
    echo.
    echo  ERROR: Could not connect to MySQL!
    echo  Try right-clicking this file and choosing
    echo  "Run as administrator", then try again.
)

echo.
pause
