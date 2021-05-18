REM sqlplus vsmc3ds/vsmc3ds@ULTRA_PREVIEW @get_scheme_objects.sql vsmc3ds_preview
REM sqlplus vsmc3ds/vsmc3ds@ULTRA_SERVICE @get_scheme_objects.sql vsmc3ds_prod
REM sqlplus aqjava/aqjava@ULTRA_PREVIEW @get_scheme_objects.sql aqjava_preview
REM sqlplus aqjava/aqjava@ULTRA_SERVICE @get_scheme_objects.sql aqjava_prod
sqlplus rc_vsmc/rc_vsmc@ULTRA_PREVIEW @get_scheme_objects.sql rc_vsmc_preview

REM get date and time 
for /f "delims=" %%a in ('date/t') do @set mydate=%%a 
for /f "delims=" %%a in ('time/t') do @set mytime=%%a 
set fvar=%mydate%%mytime% 

echo  %fvar% > D:\Scripts\GetDBSources\log.txt 2>&1
echo. >> D:\Scripts\GetDBSources\log.txt 2>&1

call git status >> D:\Scripts\GetDBSources\log.txt 2>&1
echo. >> D:\Scripts\GetDBSources\log.txt 2>&1

call git add . >> D:\Scripts\GetDBSources\log.txt 2>&1

call git commit -a -m "Test RC_VSMC COMMIT" >> D:\Scripts\GetDBSources\log.txt 2>&1
echo. >> D:\Scripts\GetDBSources\log.txt 2>&1

call git push origin master >> D:\Scripts\GetDBSources\log.txt 2>&1