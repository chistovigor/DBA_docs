DECLARE
  SQLText Varchar2(4000);
  DegreeValue Varchar2(64);
  EstimatePercentValue Varchar2(64);
  MethodOptValue Varchar2(64);
BEGIN
  DegreeValue := SYS.DBMS_STATS.GET_PREFS('DEGREE', 'FORTS', 'FUT_ARDEAL');
  EstimatePercentValue := SYS.DBMS_STATS.GET_PREFS('ESTIMATE_PERCENT', 'FORTS', 'FUT_ARDEAL');
  MethodOptValue := '''' || SYS.DBMS_STATS.GET_PREFS('METHOD_OPT', 'FORTS', 'FUT_ARDEAL') || '''';
  SQLText := 'BEGIN' || CHR(10) ||
             '  SYS.DBMS_STATS.GATHER_TABLE_STATS (' || CHR(10) ||
             '     OwnName           => ''FORTS''' || CHR(10) ||
             '    ,TabName           => ''FUT_ARDEAL''' || CHR(10) ||
             '    ,Estimate_Percent  => ' || EstimatePercentValue || CHR(10) ||
             '    ,Method_opt        => ' || MethodOptValue || CHR(10) ||
             '    ,Degree            => ' || DegreeValue || CHR(10) ||
             '    ,Cascade           => TRUE' || CHR(10) ||
             '    ,No_Invalidate  => FALSE);' || CHR(10) ||
             'END;';
  execute immediate(SQLText);
END;
/

