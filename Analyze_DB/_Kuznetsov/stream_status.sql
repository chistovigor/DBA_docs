col name format a15
col PROCESS_NAME format a20
col QUEUE_OWNER format a15
col STATE format a25
col ERRMSG format a20



Select
  Name,PROCESS_NAME, QUEUE_OWNER, status, STATE, ERRMSG
From(
    Select 
          'APPLY' As Name, 
            APPLY_NAME As PROCESS_NAME, 
            queue_owner As QUEUE_OWNER,
            STATUS, 
            'N/A' As STATE,
            Case When ERROR_message Is Null Then 'No ERROR' When ERROR_message = '' Then 'No ERROR' Else ERROR_message End As ERRMSG 
        From 
          DBA_APPLY
  Union
      Select 
          'CAPTURE' As Name, 
          dc.CAPTURE_NAME As PROCESS_NAME, 
          queue_owner As QUEUE_OWNER,
          dc.STATUS, 
          gsc.STATE As STATE,
          Case When dc.ERROR_message Is Null Then 'No ERROR' When dc.ERROR_message = '' Then 'No ERROR' Else dc.ERROR_message End As ERRMSG 
        From 
          DBA_CAPTURE dc
          Inner Join gv$streams_capture gsc On gsc.CAPTURE_NAME = dc.capture_name
  Union
    SELECT 
          'PROPAGATION' As Name, 
            PROPAGATION_NAME As PROCESS_NAME, 
            source_queue_owner As QUEUE_OWNER,
            STATUS, 
            'N/A' As STATE,
            Case When ERROR_message Is Null Then 'No ERROR' When ERROR_message = '' Then 'No ERROR' Else ERROR_message End As ERRMSG 
        From 
          DBA_PROPAGATION
  )
Order By name,process_name;


