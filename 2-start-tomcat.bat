@echo off
:: ============================================================
::  2-start-tomcat.bat  —  FIXED VERSION
::
::  Compiles servlets, deploys to Tomcat, and starts Tomcat.
::  Tomcat opens in its own console window — keep it open.
::
::  RUN THIS AFTER 1-start-mysql.bat
:: ============================================================

set TOMCAT_HOME=C:\tomcat\apache-tomcat-11.0.22
set PROJECT=C:\Users\amitr\OneDrive\Desktop\Other Projects\digital_library\DigitalLibrary
set SERVLET_API=%TOMCAT_HOME%\lib\servlet-api.jar
set MYSQL_JAR=%PROJECT%\WEB-INF\lib\mysql-connector-j-8.3.0.jar
set SRC=%PROJECT%\src
set OUT=%PROJECT%\WEB-INF\classes
set DEPLOY=%TOMCAT_HOME%\webapps\DigitalLibrary

echo.
echo  ================================================
echo   Digital Library — Step 2: Build and Start
echo  ================================================
echo.

:: ── 1. Kill any running Tomcat ─────────────────────────────
echo [1/5] Stopping any running Tomcat...
taskkill /F /IM java.exe /FI "WINDOWTITLE eq Tomcat*" >nul 2>&1
call "%TOMCAT_HOME%\bin\shutdown.bat" >nul 2>&1
timeout /t 3 /nobreak >nul

:: ── 2. Compile servlets ────────────────────────────────────
echo [2/5] Compiling servlets...
javac -cp "%SERVLET_API%;%MYSQL_JAR%" ^
      -d "%OUT%" ^
      -sourcepath "%SRC%" ^
      "%SRC%\servlets\SearchServlet.java" ^
      "%SRC%\servlets\IssueBookServlet.java" ^
      "%SRC%\servlets\ReturnBookServlet.java"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo  ERROR: Compilation failed!
    echo  Make sure 'javac' is on your PATH.
    echo  Add C:\Program Files\Java\jdk-25\bin to PATH.
    echo.
    pause
    exit /b 1
)
echo        Compiled OK.

:: ── 3. Deploy files to Tomcat webapps ──────────────────────
echo [3/5] Deploying to Tomcat webapps...
if not exist "%DEPLOY%" mkdir "%DEPLOY%"
xcopy /E /Y /Q "%PROJECT%\WebContent\*" "%DEPLOY%\" >nul
xcopy /E /Y /Q "%PROJECT%\WEB-INF" "%DEPLOY%\WEB-INF\" >nul
echo        Deployed OK.

:: ── 4. Verify MySQL is running ─────────────────────────────
echo [4/5] Checking MySQL connection...
"%MYSQL_JAR%" >nul 2>&1
"C:\mysql\bin\mysql.exe" -u root --connect-timeout=5 -e "SELECT 1;" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo  WARNING: MySQL is NOT running!
    echo  Please run 1-start-mysql.bat first, then try again.
    echo.
    pause
    exit /b 1
)
echo        MySQL is running. Good.

:: ── 5. Start Tomcat in a new window ────────────────────────
echo [5/5] Starting Tomcat 11...
set JAVA_HOME=C:\Program Files\Java\jdk-25
set CATALINA_HOME=%TOMCAT_HOME%
start "Tomcat 11 - Digital Library" /MIN "%TOMCAT_HOME%\bin\startup.bat"

:: Wait for Tomcat to initialize
echo      Waiting 8 seconds for Tomcat to be ready...
timeout /t 8 /nobreak >nul

:: Open the browser automatically
echo      Opening browser...
start "" "http://localhost:8080/DigitalLibrary/"

echo.
echo  ================================================
echo   SUCCESS! App is running.
echo   URL: http://localhost:8080/DigitalLibrary/
echo.
echo   Keep both windows open:
echo     - "MySQL Server"  (minimized in taskbar)
echo     - "Tomcat 11..."  (minimized in taskbar)
echo  ================================================
echo.
pause
