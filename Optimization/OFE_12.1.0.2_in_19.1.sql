SPO OFE_12.1.0.2_in_19.1.0.log;

REM AUTHOR
REM   balavignesh.arumugam@oracle.com
REM
REM SCRIPT
REM   OFE_12.1.0.2_in_19.1.0.sql

REM DESCRIPTION
REM   This script is used to set the CBO parameters and fix control
REM   settings to downgrade the optimizer features to 12.1.0.2
REM   in an 19.1.0 Database environment with default optimizer features set.
REM   These are the parameters and fix controls that are linked to OFE and
REM   change its values upon OFE change. However, there are some parameters and
REM   fix controls that are not linked to OFE and hence such parameters/fix controls
REM   would remain unchanged upon OFE change.

REM   Starting 12.1.0.2.170418 DBBP, Optimizer fixes are included as part of bundle patches 
REM   with the fix controls disabled by default for those fixes. Hence there are chances for
REM   difference in the fix control settings given in the script with the customer environment 
REM	  when the customer environment is 12.1.0.2.170418 DBBP or above.

REM NOTES
REM   1. For errors see OFE_12.1.0.2_in_19.1.0.log
REM   2. This can be used in ADG (read-only standby database) environment also.

REM CBO Hidden Parameters To be set in 19.1.0 Optimizer Env to come to 12.1.0.2 OFE level

alter session set "_sqlexec_hash_based_distagg_ssf_enabled"=FALSE;
alter session set "_optimizer_use_xt_rowid"=FALSE;
alter session set "_key_vector_double_enabled"=FALSE;
alter session set "_hcs_enable_pred_push"=FALSE;
alter session set "_optimizer_union_all_gsets"=FALSE;
alter session set "_ds_xt_split_count"=0;
alter session set "_optimizer_use_table_scanrate"=OFF;
alter session set "_bloom_filter_ratio"=30;
alter session set "_px_partition_skew_threshold"=0;
alter session set "_sqlexec_pwiseops_with_binds_enabled"=FALSE;
alter session set "_px_hybrid_partition_skew_threshold"=255;
alter session set "_optimizer_use_auto_indexes"=OFF;
alter session set "_vector_encoding_mode"=OFF;
alter session set "_px_pwise_wif_enabled"=FALSE;
alter session set "_px_join_skew_sampling_time_limit"=0;
alter session set "_px_dynamic_granules"=FALSE;
alter session set "_optimizer_quarantine_sql"=FALSE;
alter session set "_optimizer_undo_cost_change"="12.1.0.2";
alter session set "_optimizer_cbqt_or_expansion"=OFF;
alter session set "_optimizer_ads_use_spd_cache"=FALSE;
alter session set "_optimizer_vector_base_dim_fact_factor"=0;
alter session set "_px_scalable_gby_invdist"=FALSE;
alter session set "_optimizer_use_stats_on_conventional_config"=65535;
alter session set "_optimizer_ads_use_partial_results"=FALSE;
alter session set "_optimizer_key_vector_pruning_enabled"=FALSE;
alter session set "_pwise_distinct_enabled"=FALSE;
alter session set "_optimizer_band_join_aware"=FALSE;
alter session set "_optimizer_inmemory_use_stored_stats"=NEVER;
alter session set "_key_vector_timestamp_enabled"=FALSE;
alter session set "_sqlexec_pwiseops_with_sqlfuncs_enabled"=FALSE;
alter session set "_optimizer_gather_stats_on_load_index"=FALSE;
alter session set "_px_dynamic_granules_adjust"=0;
alter session set "_optimizer_gather_stats_on_conventional_config"=65535;
alter session set "_px_scalable_invdist_mcol"=FALSE;
alter session set "_optimizer_eliminate_subquery"=FALSE;
alter session set "_key_vector_create_pushdown_threshold"=0;
alter session set "_recursive_with_parallel"=FALSE;
alter session set "_recursive_with_branch_iterations"=1;
alter session set "_optimizer_key_vector_payload"=FALSE;
alter session set "_px_join_skew_use_histogram"=FALSE;
alter session set "_optimizer_use_stats_on_conventional_dml"=FALSE;
alter session set "_query_rewrite_use_on_query_computation"=FALSE;
alter session set "_optimizer_enhanced_join_elimination"=FALSE;
alter session set "_optimizer_multicol_join_elimination"=FALSE;
alter session set "_ds_sampling_method"=NO_QUALITY_METRIC;
alter session set "_ds_enable_view_sampling"=FALSE;
alter session set "_mv_access_compute_fresh_data"=OFF;
alter session set "_sqlexec_reorder_wif_enabled"=FALSE;
alter session set "_px_join_skew_null_handling"=FALSE;
alter session set "_cell_offload_vector_groupby_withnojoin"=FALSE;
alter session set "_optimizer_enable_plsql_stats"=FALSE;
alter session set "_px_dist_agg_partial_rollup_pushdown"=OFF;
alter session set "_xt_sampling_scan_granules"=OFF;
alter session set "_optimizer_control_shard_qry_processing"=65529;
alter session set "_optimizer_interleave_or_expansion"=FALSE;
alter session set "_px_nlj_bcast_rr_threshold"=65535;
alter session set "_bloom_pruning_setops_enabled"=FALSE;
alter session set "_bloom_filter_setops_enabled"=FALSE;
alter session set "_cell_offload_vector_groupby_fact_key"=FALSE;
alter session set "_px_hybrid_partition_execution_enabled"=FALSE;
alter session set "_key_vector_join_pushdown_enabled"=FALSE;
alter session set "_cell_offload_grand_total"=FALSE;
alter session set "_optimizer_gather_stats_on_conventional_dml"=FALSE;
/

PRO CBO Parameters settings completed.

PAUSE Press Enter to continue.

REM CBO Fix Control Settings in 19.1.0 Optimizer Env to come to 12.1.0.2 OFE level

alter session set "_fix_control"="16515789:0";
alter session set "_fix_control"="17491018:0";
alter session set "_fix_control"="17986549:0";
alter session set "_fix_control"="18115594:0";
alter session set "_fix_control"="18182018:0";
alter session set "_fix_control"="18302923:0";
alter session set "_fix_control"="18377553:0";
alter session set "_fix_control"="5677419:0";
alter session set "_fix_control"="18134680:0";
alter session set "_fix_control"="18636079:0";
alter session set "_fix_control"="18415557:0";
alter session set "_fix_control"="18385778:0";
alter session set "_fix_control"="18308329:0";
alter session set "_fix_control"="17973658:0";
alter session set "_fix_control"="18558952:0";
alter session set "_fix_control"="18874242:0";
alter session set "_fix_control"="18765574:0";
alter session set "_fix_control"="18952882:0";
alter session set "_fix_control"="18924221:0";
alter session set "_fix_control"="18422714:0";
alter session set "_fix_control"="18798414:0";
alter session set "_fix_control"="18969167:0";
alter session set "_fix_control"="19055664:0";
alter session set "_fix_control"="18898582:0";
alter session set "_fix_control"="18960760:0";
alter session set "_fix_control"="19070454:0";
alter session set "_fix_control"="19230097:0";
alter session set "_fix_control"="19063497:0";
alter session set "_fix_control"="19046459:0";
alter session set "_fix_control"="19269482:0";
alter session set "_fix_control"="18876528:0";
alter session set "_fix_control"="19227996:0";
alter session set "_fix_control"="18864613:0";
alter session set "_fix_control"="19239478:0";
alter session set "_fix_control"="19451895:0";
alter session set "_fix_control"="18907390:0";
alter session set "_fix_control"="19025959:0";
alter session set "_fix_control"="16774698:0";
alter session set "_fix_control"="19475484:0";
alter session set "_fix_control"="19287919:0";
alter session set "_fix_control"="19386746:0";
alter session set "_fix_control"="19774486:0";
alter session set "_fix_control"="18671960:0";
alter session set "_fix_control"="19484911:0";
alter session set "_fix_control"="19731940:0";
alter session set "_fix_control"="19604408:0";
alter session set "_fix_control"="14402409:0";
alter session set "_fix_control"="16486095:0";
alter session set "_fix_control"="19563657:0";
alter session set "_fix_control"="19632232:0";
alter session set "_fix_control"="19889960:0";
alter session set "_fix_control"="17208933:0";
alter session set "_fix_control"="19710102:0";
alter session set "_fix_control"="18697515:0";
alter session set "_fix_control"="18318631:0";
alter session set "_fix_control"="20078639:0";
alter session set "_fix_control"="19503668:0";
alter session set "_fix_control"="20124288:0";
alter session set "_fix_control"="19847091:0";
alter session set "_fix_control"="12618642:0";
alter session set "_fix_control"="19779920:0";
alter session set "_fix_control"="20186282:0";
alter session set "_fix_control"="20186295:0";
alter session set "_fix_control"="20265690:0";
alter session set "_fix_control"="16047938:0";
alter session set "_fix_control"="19507904:0";
alter session set "_fix_control"="18915345:0";
alter session set "_fix_control"="20329321:0";
alter session set "_fix_control"="20225191:0";
alter session set "_fix_control"="18776755:0";
alter session set "_fix_control"="19882842:0";
alter session set "_fix_control"="20010996:0";
alter session set "_fix_control"="20379571:0";
alter session set "_fix_control"="20129763:0";
alter session set "_fix_control"="19899588:0";
alter session set "_fix_control"="10098852:0";
alter session set "_fix_control"="20465582:0";
alter session set "_fix_control"="16732417:0";
alter session set "_fix_control"="20732410:0";
alter session set "_fix_control"="20289688:0";
alter session set "_fix_control"="20543684:0";
alter session set "_fix_control"="20506136:0";
alter session set "_fix_control"="20830312:0";
alter session set "_fix_control"="19768896:0";
alter session set "_fix_control"="19814541:0";
alter session set "_fix_control"="17443547:0";
alter session set "_fix_control"="19123152:0";
alter session set "_fix_control"="19899833:0";
alter session set "_fix_control"="20754928:0";
alter session set "_fix_control"="20808265:0";
alter session set "_fix_control"="20808192:0";
alter session set "_fix_control"="20340595:0";
alter session set "_fix_control"="18949550:0";
alter session set "_fix_control"="14775297:0";
alter session set "_fix_control"="17497847:0";
alter session set "_fix_control"="20232513:0";
alter session set "_fix_control"="20587527:0";
alter session set "_fix_control"="19186783:0";
alter session set "_fix_control"="19653920:0";
alter session set "_fix_control"="21211786:0";
alter session set "_fix_control"="21057343:0";
alter session set "_fix_control"="21503478:0";
alter session set "_fix_control"="21476032:0";
alter session set "_fix_control"="20859246:0";
alter session set "_fix_control"="21639419:0";
alter session set "_fix_control"="21683982:0";
alter session set "_fix_control"="20216500:0";
alter session set "_fix_control"="20906162:0";
alter session set "_fix_control"="20854798:0";
alter session set "_fix_control"="21509656:0";
alter session set "_fix_control"="21833220:0";
alter session set "_fix_control"="21802552:0";
alter session set "_fix_control"="21452843:0";
alter session set "_fix_control"="21800590:0";
alter session set "_fix_control"="21273039:0";
alter session set "_fix_control"="16750133:0";
alter session set "_fix_control"="22013607:0";
alter session set "_fix_control"="22152372:0";
alter session set "_fix_control"="22077191:0";
alter session set "_fix_control"="22123025:0";
alter session set "_fix_control"="16913734:0";
alter session set "_fix_control"="8357294:0";
alter session set "_fix_control"="21979983:0";
alter session set "_fix_control"="22158526:0";
alter session set "_fix_control"="21971099:0";
alter session set "_fix_control"="22090662:0";
alter session set "_fix_control"="21300129:0";
alter session set "_fix_control"="21339278:0";
alter session set "_fix_control"="20270511:0";
alter session set "_fix_control"="21424812:0";
alter session set "_fix_control"="22114090:0";
alter session set "_fix_control"="22159570:0";
alter session set "_fix_control"="22272439:0";
alter session set "_fix_control"="22372694:0";
alter session set "_fix_control"="22514195:0";
alter session set "_fix_control"="22520315:0";
alter session set "_fix_control"="22649054:0";
alter session set "_fix_control"="8617254:0";
alter session set "_fix_control"="22020067:0";
alter session set "_fix_control"="22864730:0";
alter session set "_fix_control"="21099502:0";
alter session set "_fix_control"="22904304:0";
alter session set "_fix_control"="22967807:0";
alter session set "_fix_control"="22879002:0";
alter session set "_fix_control"="23019286:0";
alter session set "_fix_control"="22760704:0";
alter session set "_fix_control"="20853506:0";
alter session set "_fix_control"="22513493:0";
alter session set "_fix_control"="22518491:0";
alter session set "_fix_control"="23103096:0";
alter session set "_fix_control"="22143411:0";
alter session set "_fix_control"="23180670:0";
alter session set "_fix_control"="23002609:0";
alter session set "_fix_control"="23210039:0";
alter session set "_fix_control"="23102649:0";
alter session set "_fix_control"="23071621:0";
alter session set "_fix_control"="23136865:0";
alter session set "_fix_control"="23176721:0";
alter session set "_fix_control"="23223113:0";
alter session set "_fix_control"="22258300:0";
alter session set "_fix_control"="22205301:0";
alter session set "_fix_control"="23556483:0";
alter session set "_fix_control"="21305617:0";
alter session set "_fix_control"="22533539:0";
alter session set "_fix_control"="23596611:0";
alter session set "_fix_control"="22937293:0";
alter session set "_fix_control"="20107874:0";
alter session set "_fix_control"="19582337:0";
alter session set "_fix_control"="22746853:0";
alter session set "_fix_control"="23537232:0";
alter session set "_fix_control"="23565188:0";
alter session set "_fix_control"="24690046:0";
alter session set "_fix_control"="23732552:0";
alter session set "_fix_control"="20648883:0";
alter session set "_fix_control"="24654471:0";
alter session set "_fix_control"="23738304:0";
alter session set "_fix_control"="22766607:0";
alter session set "_fix_control"="24845754:0";
alter session set "_fix_control"="22128803:0";
alter session set "_fix_control"="24926999:0";
alter session set "_fix_control"="24434608:0";
alter session set "_fix_control"="25094218:0";
alter session set "_fix_control"="24819957:0";
alter session set "_fix_control"="23478835:0";
alter session set "_fix_control"="24745366:0";
alter session set "_fix_control"="24570810:0";
alter session set "_fix_control"="24518392:0";
alter session set "_fix_control"="25234139:0";
alter session set "_fix_control"="25108065:0";
alter session set "_fix_control"="22212124:0";
alter session set "_fix_control"="25123105:0";
alter session set "_fix_control"="25078728:0";
alter session set "_fix_control"="25090203:0";
alter session set "_fix_control"="23738553:0";
alter session set "_fix_control"="22070473:0";
alter session set "_fix_control"="19956351:0";
alter session set "_fix_control"="25393617:0";
alter session set "_fix_control"="25342352:0";
alter session set "_fix_control"="23473108:0";
alter session set "_fix_control"="25501716:0";
alter session set "_fix_control"="22973474:0";
alter session set "_fix_control"="22153026:0";
alter session set "_fix_control"="25367727:0";
alter session set "_fix_control"="25477783:0";
alter session set "_fix_control"="25493582:0";
alter session set "_fix_control"="22205362:0";
alter session set "_fix_control"="23249829:0";
alter session set "_fix_control"="25796244:0";
alter session set "_fix_control"="25575369:0";
alter session set "_fix_control"="25478095:0";
alter session set "_fix_control"="25405100:0";
alter session set "_fix_control"="24952618:0";
alter session set "_fix_control"="25809211:0";
alter session set "_fix_control"="21183079:0";
alter session set "_fix_control"="25948370:0";
alter session set "_fix_control"="25926263:0";
alter session set "_fix_control"="26019148:0";
alter session set "_fix_control"="25995431:0";
alter session set "_fix_control"="21870589:0";
alter session set "_fix_control"="24584046:0";
alter session set "_fix_control"="26374214:0";
alter session set "_fix_control"="25345279:0";
alter session set "_fix_control"="24478915:0";
alter session set "_fix_control"="26541991:0";
alter session set "_fix_control"="26338880:0";
alter session set "_fix_control"="26671842:0";
alter session set "_fix_control"="26712343:0";
alter session set "_fix_control"="26585420:0";
alter session set "_fix_control"="26677151:0";
alter session set "_fix_control"="26367868:0";
alter session set "_fix_control"="26177646:0";
alter session set "_fix_control"="23643560:0";
alter session set "_fix_control"="25792706:0";
alter session set "_fix_control"="26986173:0";
alter session set "_fix_control"="26423085:0";
alter session set "_fix_control"="27077069:0";
alter session set "_fix_control"="26536320:0";
alter session set "_fix_control"="25138211:0";
alter session set "_fix_control"="27321179:0";
alter session set "_fix_control"="27343844:0";
alter session set "_fix_control"="27282295:0";
alter session set "_fix_control"="27432718:0";
alter session set "_fix_control"="24841671:0";
alter session set "_fix_control"="26842212:0";
alter session set "_fix_control"="27436816:0";
alter session set "_fix_control"="23098284:0";
alter session set "_fix_control"="26660568:0";
alter session set "_fix_control"="27693205:0";
alter session set "_fix_control"="27174324:0";
alter session set "_fix_control"="27000158:0";
alter session set "_fix_control"="27745220:0";
alter session set "_fix_control"="26566785:0";
alter session set "_fix_control"="18816560:0";
alter session set "_fix_control"="27466597:0";
alter session set "_fix_control"="27643128:0";
alter session set "_fix_control"="24761824:0";
alter session set "_fix_control"="27634227:0";
alter session set "_fix_control"="26733841:0";
alter session set "_fix_control"="22174392:0";
alter session set "_fix_control"="27730925:0";
alter session set "_fix_control"="22559379:0";
alter session set "_fix_control"="27622097:0";
alter session set "_fix_control"="22582700:0";
alter session set "_fix_control"="28201419:0";
alter session set "_fix_control"="27991474:0";
alter session set "_fix_control"="28210382:0";
alter session set "_fix_control"="27500916:0";
alter session set "_fix_control"="28012754:0";
alter session set "_fix_control"="28071742:0";
alter session set "_fix_control"="28242450:0";
alter session set "_fix_control"="28660798:0";
alter session set "_fix_control"="27541468:0";
alter session set "_fix_control"="28725660:0";
alter session set "_fix_control"="28072567:0";
alter session set "_fix_control"="28835937:0";
/
SPO OFF;

PRO Fix control settings completed.
