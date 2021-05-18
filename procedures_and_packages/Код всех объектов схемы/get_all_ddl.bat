sqlplus vsmc3ds/vsmc3ds@ULTRA_PREVIEW @get_scheme_objects.sql vsmc3ds_preview
sqlplus vsmc3ds/vsmc3ds@ULTRADB_SERVICE @get_scheme_objects.sql vsmc3ds_prod
sqlplus aqjava/aqjava@ULTRA_PREVIEW @get_scheme_objects.sql aqjava_preview
sqlplus aqjava/aqjava@ULTRADB_SERVICE @get_scheme_objects.sql aqjava_prod
sqlplus rc_vsmc/rc_vsmc@ULTRA_PREVIEW @get_scheme_objects.sql rc_vsmc_preview
sqlplus rc_vsmc/rc_vsmc@ULTRADB_SERVICE @get_scheme_objects.sql rc_vsmc_prod

REM get date and time 
for /f "delims=" %%a in ('date/t') do @set mydate=%%a 
for /f "delims=" %%a in ('time/t') do @set mytime=%%a 
set fvar=%mydate%%mytime% 

echo  %fvar% > D:\Scripts\GetDBSources\log.txt 2>&1
echo. >> D:\Scripts\GetDBSources\log.txt 2>&1

call git status >> D:\Scripts\GetDBSources\log.txt 2>&1
echo. >> D:\Scripts\GetDBSources\log.txt 2>&1

call git add . >> D:\Scripts\GetDBSources\log.txt 2>&1

call git commit -a -m "Daily commit on %fvar%" >> D:\Scripts\GetDBSources\log.txt 2>&1
echo. >> D:\Scripts\GetDBSources\log.txt 2>&1

call git push origin master >> D:\Scripts\GetDBSources\log.txt 2>&1