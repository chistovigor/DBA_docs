rem Set PROGDIR to this script's directory
set PROGDIR=%~dp0

rem Remove trailing slash from PROGDIR if any
if '%PROGDIR:~-1%'=='\' set PROGDIR=%PROGDIR:~0,-1%

set PROGDIR_NQ=%PROGDIR%
set PROGDIR="%PROGDIR%"

set TERM=dumb
set PERLBIN=%PROGDIR%\perl\perl\bin

set JAVA_HOME=%PROGDIR_NQ%\java7
set GROOVY_HOME=%PROGDIR_NQ%\groovy-2.1.6
set GNUWIN32_HOME=%PROGDIR_NQ%\gnuwin32
set CLASSPATH=%PROGDIR_NQ%\gscripts;%PROGDIR_NQ%\jars\joda-time-2.3.jar