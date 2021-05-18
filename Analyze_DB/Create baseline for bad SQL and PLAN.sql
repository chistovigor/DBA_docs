–2) Create baseline for bad SQL and PLAN
declare
nRet pls_integer;
begin
nRet := DBMS_SPM.LOAD_PLANS_FROM_CURSOR_CACHE (sql_id=>'981t428aj1ah6',plan_hash_value=>'579167269',fixed=>'YES',enabled=>'YES');
end;
/
SELECT * FROM dba_sql_plan_baselines;

–3) Now generate new plan using hints /*+ ORDERED */ could be starting point. You just need to get it to execute in reasonable time.
— Run hinted SQL through SQL Tuning Advisor in EM and accept SQL profile
SELECT * FROM dba_sql_profiles;

–4) Loaded hinted SQL plan, after tuning and accepting profile, into bad SQL baseline (identified by sql_handle)
declare
nRet pls_integer;
begin
nRet := DBMS_SPM.LOAD_PLANS_FROM_CURSOR_CACHE (sql_id=>'9rmm9ycmkrqkb',plan_hash_value=>'2233217598',sql_handle=>'SQL_aa6e0ff42af35d08',fixed=>'YES',enabled=>'YES');
end;
/
SELECT * FROM dba_sql_plan_baselines;

–5) Drop original BAD baseline through EM

–6) Validate by running SQL to see performance improvement
— Check v$sql should have entry connected to SQL PROFILE plan for both BAD and hinted SQL
SELECT * from v$sql where plan_hash_value='2233217598';