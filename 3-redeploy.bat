@echo off
:: ============================================================
::  3-redeploy.bat  —  FIXED VERSION
::  Use after editing any Java servlet file.
::  Stops Tomcat, recompiles, redeploys, restarts.
:: ============================================================

set TOMCAT_HOME=C:\tomcat\apache-tomcat-11.0.22
set PROJECT=C:\Users\amitr\OneDrive\Desktop\Other Projects\digital_library\DigitalLibrary
set SERVLET_API=%TOMCAT_HOME%\lib\servlet-api.jar
set MYSQL_JAR=%PROJECT%\WEB-INF\lib\mysql-connector-j-8.3.0.jar
set SRC=%PROJECT%\src
set OUT=%PROJECT%\WEB-INF\classes
set DEPLOY=%TOMCAT_HOME%\webapps\DigitalLibrary

echo [1/4] Stopping Tomcat...
call "%TOMCAT_HOME%\bin\shutdown.bat" >nul 2>&1
timeout /t 4 /nobreak >nul

echo [2/4] Recompiling servlets...
javac -cp "%SERVLET_API%;%MYSQL_JAR%" -d "%OUT%" -sourcepath "%SRC%" ^
    "%SRC%\servlets\SearchServlet.java" ^
    "%SRC%\servlets\IssueBookServlet.java" ^
    "%SRC%\servlets\ReturnBookServlet.java"

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Compilation failed!
    pause
    exit /b 1
)

echo [3/4] Redeploying files...
xcopy /E /Y /Q "%PROJECT%\WebContent\*" "%DEPLOY%\" >nul
xcopy /E /Y /Q "%PROJECT%\WEB-INF" "%DEPLOY%\WEB-INF\" >nul

echo [4/4] Restarting Tomcat...
set JAVA_HOME=C:\Program Files\Java\jdk-25
set CATALINA_HOME=%TOMCAT_HOME%
start "Tomcat 11 - Digital Library" /MIN "%TOMCAT_HOME%\bin\startup.bat"
timeout /t 8 /nobreak >nul
start "" "http://localhost:8080/DigitalLibrary/"
echo Done! http://localhost:8080/DigitalLibrary/
pause
