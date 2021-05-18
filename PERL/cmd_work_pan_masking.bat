rem copy file with the same name as this batfile to %PROGDIR%\pscripts
rem where %PROGDIR% is perl (Strawberry Perl Portable 5.18.1.1-32bit) directory
rem copy this batfile in %PROGDIR%\bin directory and set this directory in PATH
rem copy batfile settings.bat in %PROGDIR%\ directory
rem for run the perl script just type its name (without .pl) in cmd 

@echo off
call "%~dp0..\settings.bat"

set BATNAME=%~n0
%PERLBIN%\perl %PROGDIR%\pscripts\%BATNAME%.pl  %*