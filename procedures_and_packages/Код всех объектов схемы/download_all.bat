for /f "delims=" %%a in ('date/t') do @set mydate=%%a 
for /f "delims=" %%a in ('time/t') do @set mytime=%%a 
set fvar=%mydate%%mytime% 

echo  %fvar% > D:\Scripts\GetDBSources\log.txt 2>&1
echo. >> D:\Scripts\GetDBSources\log.txt 2>&1

call git status >> D:\Scripts\GetDBSources\log.txt 2>&1
echo. >> D:\Scripts\GetDBSources\log.txt 2>&1

call git pull origin master >> D:\Scripts\GetDBSources\log.txt 2>&1