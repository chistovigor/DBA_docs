#!/bin/sh


# Copyright (c) 1999, 2013, Oracle and/or its affiliates. All rights reserved.
#
# Disclaimer:
#
# EXCEPT WHERE EXPRESSLY PROVIDED OTHERWISE, THE INFORMATION, SOFTWARE,
# PROVIDED ON AN \"AS IS\" AND \"AS AVAILABLE\" BASIS. ORACLE EXPRESSLY DISCLAIMS
# ALL WARRANTIES OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
# PURPOSE AND NON-INFRINGEMENT. ORACLE MAKES NO WARRANTY THAT: (A) THE RESULTS
# THAT MAY BE OBTAINED FROM THE USE OF THE SOFTWARE WILL BE ACCURATE OR
# RELIABLE; OR (B) THE INFORMATION, OR OTHER MATERIAL OBTAINED WILL MEET YOUR
# EXPECTATIONS. ANY CONTENT, MATERIALS, INFORMATION OR SOFTWARE DOWNLOADED OR
# OTHERWISE OBTAINED IS DONE AT YOUR OWN DISCRETION AND RISK. ORACLE SHALL HAVE
# NO RESPONSIBILITY FOR ANY DAMAGE TO YOUR COMPUTER SYSTEM OR LOSS OF DATA THAT
# RESULTS FROM THE DOWNLOAD OF ANY CONTENT, MATERIALS, INFORMATION OR SOFTWARE.
#
# ORACLE RESERVES THE RIGHT TO MAKE CHANGES OR UPDATES TO THE SOFTWARE AT ANY
# TIME WITHOUT NOTICE.
#
# Limitation of Liability:
#
# IN NO EVENT SHALL ORACLE BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL OR CONSEQUENTIAL DAMAGES, OR DAMAGES FOR LOSS OF PROFITS, REVENUE,
# DATA OR USE, INCURRED BY YOU OR ANY THIRD PARTY, WHETHER IN AN ACTION IN
# CONTRACT OR TORT, ARISING FROM YOUR ACCESS TO, OR USE OF, THE SOFTWARE.


###############################################################################
############    SCRIPT VARIABLES HERE   #######################################
###############################################################################
VERSION=0001                              # script version
MAX_RPCOUNT=2000                          # max permitted restore point entries
PHYSRU_DEBUG=0                            # set to 1 for additional tracing

# Customizable settings (proceed with caution)
LOC_BACKUP_FILES="$ORACLE_HOME/dbs/"      # location of backup files

LOG_PHYSRU_ENABLED=1                      # output to logfile enabled
LOG_PHYSRU_FILE="physru.log"              # filename of script output log
LOG_SQL_ERRORS=1                          # 1 to display sql error context
LOG_SQL_EXETMP="physru_sql.tmp"           # temp file for executing sql
LOG_UNSUPP_FILE="physru_unsupported.log"  # filename of unsupported types log

LSP_APPLY_LAG=30                          # apply lag target (sec) for lsp
LSP_APPLY_LAG_TIMEOUT=30                  # timeout (min) for mrp to sync
LSP_DICT_LOAD_INTERVAL=10                 # time (sec) in b/w dict load checks
LSP_DICT_LOAD_TIMEOUT=30                  # timeout (min) for dict load
LSP_START_TIMEOUT=10                      # timeout (min) for lsp to start
LSP_START_INTERVAL=5                      # time (sec) in b/w lsp start checks

MRP_APPLY_LAG=30                          # apply lag limit (sec) for mrp
MRP_APPLY_LAG_TIMEOUT=30                  # timeout (min) for mrp to sync
MRP_REDO_PROG_INTERVAL=15                 # time (sec) between progress checks
MRP_START_INTERVAL=5                      # time (sec) in b/w mrp start checks
MRP_START_TIMEOUT=10                      # timeout (min) for mrp to start
MRP_UPGRADE_TIMEOUT=15                    # timeout (min) mrp scn is stagnant
                                          #   during recovery of upgrade redo 
RPFX=PRU                                  # prefix for restore point names

STB_APPLY_LAG_INTERVAL=30                 # time (sec) in b/w apply lag checks
STB_EOR_INTERVAL=10                       # time (sec) in b/w eor done checks
STB_EOR_TIMEOUT=15                        # timeout (min) for eor to complete
STB_EOR_RESTART_AFTER=5                   # timeout (min) to restart lsp/mrp
STB_VIEW_INIT_INTERVAL=3                  # time (sec) in b/w view init checks



###############################################################################
# NAME:        autopru
#
# DESCRIPTION: 
#   This is the main entry point of the script.
#
# INPUT(S):
#   Arguments: 
#     $1: database user
#     $2: tns service name to primary
#     $3: tns service name to physical standby
#     $4: db_unique_name of primary (or any identifying string)
#     $5: db_unique_name of standby (or any identifying string)
#     $6: target rdbms version
#
#   Globals: 
#     $user $db1tns $db2tns $db1name $db2name $stage $task
#
# RETURN:
#   0: Success 1: Error
#
###############################################################################
autopru()
{

# Save tty settings
origstty=`stty -g`

# Declare signal handler
trap 'inthandler' 2

# We need all 6 parameters
if [ "$#" -ne "6" ]; then
  display_usage
  echo -e "\nERROR: $# of the 6 required parameters have been specified\n"
  exit 1
fi

# Display Oracle banner
# display_banner

# Prompt for password
stty -echo
echo "Please enter the sysdba password: "
read passwd
stty $origstty

# Global variables
user=$1                                 # username (assumes same on pri/stb)
db1tns=$2                               # db1 (orig pri) tns connect string
db2tns=$3                               # db2 (orig stb) tns connect string
db1name=$4                              # db1 db_unique_name (set in S1)
db2name=$5                              # db2 db_unique_name (set in S1)
upgver=$6                               # upgraded version number
stage=0                                 # current stage in the script
task=1                                  # current task within a stage 
suppress=0                              # suppress all output
suppresst=0                             # suppress terminal output
suppressl=0                             # supporess logfile output
db1iname=""                             # db1 instance name (assoc w/db1tns)
db2iname=""                             # db2 instance name (assoc w/db2tns)
db1iid=0                                # db1 instance id (assoc w/db1tns)
db2iid=0                                # db2 instance id (assoc w/db2tns)
db1version="0.0.0.0"                    # db1 complete rdbms version
db2version="0.0.0.0"                    # db2 complete rdbms version
db1ver="0.0"                            # db1 short rdbms version
db2ver="0.0"                            # db2 short rdbms version
sql_out=""                              # output from last sql_exec call

S0_initialization                       # set stage, task vars to start/resume
while [ "$stage" ]
do
  case "$stage" in
     1) S1_backup;;                     # enable full rollback on script abort
     2) S2_physical_to_logical;;        # convert physical to transient logical

     #  ... user upgrades db2 ...

     3) S3_post_upgrade_validation;;    # validate upgraded environment
     4) S4_switchover;;                 # make db2 the new primary
     5) S5_primary_to_physical;;        # convert old primary to physical

     #  ... user starts db1 on new binary ...

     6) S6_recover_through_upgrade;;    # run media recovery through upgrade
     7) S7_switchback;;                 # make db1 the new primary
     8) S8_statistics;;                 # report statistics
     *) break;;
  esac

  # Proceed to the next stage
  stage=`expr $stage + 1`
  task=1

done
S9_cleanup                              # cleanup after script

display_raw "\nSUCCESS: The physical rolling upgrade is complete\n"
}


###############################################################################
############   STAGE DEFINITIONS    ##+########################################
###############################################################################


###############################################################################
# NAME:        S0_initialization
#
# DESCRIPTION: 
#   In this stage we decide if we should start the rolling upgrade from scratch
#   or resume where the last invocation was interrupted.  If we start from 
#   scratch, an initial flashback restore point is created and the current 
#   control file is backed up.  We do this to give the user the option to 
#   cleanly recover from the actions taken by this script.  If we resume from a
#   prior invocation, this routine will set the stage and task global variables
#   so that control is transfered to the appropriate point of execution.
#   
#   A word about resuming... we achieve this by using guaranteed flashback 
#   restore points to track this script's progress.  Each restore point name
#   is encoded with a stage id and a task id which identifies a block of code
#   in this script.  When this script starts, it uses the stage and task from
#   the most recent restore point to initialize its execution.  To protect 
#   ourselves from doing harm, the very first restore point name is encoded
#   with the version number of the authoring script.  We only permit resuming
#   if an executing script has a matching version number.
#
#   N.B.: It might seem overkill to bother with version, but I can easily
#   imagine a scenario where a user runs into an error and decides to track 
#   down a more recent release of the script.  If a user was to then run the 
#   script atop the broken configuration, we could potentially do harm.
#
# INPUT(S):
#   Arguments:
#     None
#
#   Globals:
#     $user $passwd $db1tns $db2tns $db1name $db2name $stage $task $VERSION
#
# RETURN:
#   stage: the # of the initial stage or resume stage
#   task:  the # of the initial task or resume task
#
###############################################################################
S0_initialization()
{
display_raw "\n### Initialize script to either start over or resume execution"
isready=1
runningon=0

#
# Fetch primary and standby rdbms version 
#
display "Identifying rdbms software version"

get_rdbms_version $user $passwd $db1tns $db1name
db1version=$l_grv_val
display "database $db1name is at version $db1version"

get_rdbms_version $user $passwd $db2tns $db2name
db2version=$l_grv_val
display "database $db2name is at version $db2version"

# Save short form of database version (assume 2-digit major 1-digit minor)
db1ver=`echo $db1version | cut -d '.' -f 1-2`
db2ver=`echo $db2version | cut -d '.' -f 1-2`

#
# Fetch primary and standby db unique names
#
get_db_unique_name $user $passwd $db1tns $db1name
if [ "$?" -eq "0" ]; then
  db1name=$l_dun_val
fi
get_db_unique_name $user $passwd $db2tns $db2name
if [ "$?" -eq "0" ]; then
  db2name=$l_dun_val
fi

#
# Fetch primary and standby instance names
#
get_instance_name $user $passwd $db1tns $db1name
db1iname=$l_gin_val

get_instance_name $user $passwd $db2tns $db2name
db2iname=$l_gin_val

# 
# Flashback database must be enabled at both db1 and db2
#
display "verifying flashback database is enabled at $db1name and $db2name"
is_flashback_enabled $user $passwd $db1tns $db1name
if [ "$?" -eq "0" ]; then
  display "ERROR: flashback database disabled at $db1name"
  isready=0
fi
is_flashback_enabled $user $passwd $db2tns $db2name
if [ "$?" -eq "0" ]; then
  display "ERROR: flashback database disabled at $db2name"
  isready=0
fi

# Flashback retention is of sufficient size (is this predictable???)
      
# 
# Enough free restore point entries available to accommodate our use of them
#
display "verifying available flashback restore points"
get_flashback_restore_count $user $passwd $db1tns $db1name
if [ "$l_gfr_val" -gt "$MAX_RPCOUNT" ]; then
  display "ERROR: $l_gfr_val restore points at $db1name exceeds maximum of $MAX_RPCOUNT"
  isready=0
fi

get_flashback_restore_count $user $passwd $db2tns $db2name
if [ "$l_gfr_val" -gt "$MAX_RPCOUNT" ]; then
  display "ERROR: $l_gfr_val restore points at $db2name exceeds maximum of $MAX_RPCOUNT"
  isready=0
fi

#
# The Data Guard Broker must be disabled
#
display "verifying DG Broker is disabled"
is_dg_enabled $user $passwd $db1tns $db1name
if [ "$?" -eq "1" ]; then
  display "ERROR: parameter DG_BROKER_START on $db1name must be set to FALSE"
  isready=0
fi
is_dg_enabled $user $passwd $db2tns $db2name
if [ "$?" -eq "1" ]; then
  display "ERROR: parameter DG_BROKER_START on $db2name must be set to FALSE"
  isready=0
fi

#
# Exit now if one or more warnings have been found
#
if [ "$isready" -eq "0" ]; then
  display "exiting: errors must be addressed in order to proceed"
  exit 1
fi

#
# Check if we are to resume the rolling upgrade from the last invocation.  If 
# any resume state exists, an initial restore point will exist with the script
# version embedded in the name.
#
resuming=1
display "looking up prior execution history"
get_resume_version $user $passwd $db2tns $db2name
resumever=`echo $l_grv_val | awk '{print int(\$0)}'`
scriptver=`echo $VERSION | awk '{print int(\$0)}'`
if [ "$resumever" -ne "0" ]; then
  if [ "$resumever" -ne "$scriptver" ]; then
    #
    # The script versions do not match.  It's most likely that a prior rolling 
    # upgrade attempt has failed, and the user is now re-attempting the rolling
    # upgrade with a new version of this script.  This should be rare, and the 
    # user must revalidate their setup, and start from scratch.
    #
    display_raw "\nNOTE: A different version of this script has failed in the past leaving"
    display_raw "      progress-related state that may not correspond with this version of the "
    display_raw "      script.  This script will purge all state left by the older script, and "
    display_raw "      start the physical rolling upgrade from scratch."
    display_raw "\n      If you need to revisit your configuration to ensure it meets the "
    display_raw "      prerequisites for physical rolling upgrade or simply don't want to "
    display_raw "      continue, you should answer 'n' to the following question:\n"

    prompt "      Are you ready to start this script from scratch?" "y/n"
    if [ "$l_p_val" = "y" ]; then
      display "continuing"
      # Set flag to indicate start from scratch
      resuming=0
    else
      display "exiting"
      exit
    fi

  else
    # Fetch the stage and task that was last completed
    get_resume_state $user $passwd $db2tns $db2name
    resume_stage=`echo $l_grs2_stage | awk '{print int(\$0)}'`
    resume_task=`echo $l_grs2_task | awk '{print int(\$0)}'`

    # If found, the next task is where we want to start
    if [ "$resume_stage" -gt "0" ]; then
      display "last completed stage [${resume_stage}-${resume_task}] using script version $l_grv_val"
      
      # Resuming from other than these two states implies an error had occurred
      prompt_user=1
      if [ "$resume_stage" -eq "2" ] && [ "$resume_task" -eq "4" ]; then
        prompt_user=0
       fi
      if [ "$resume_stage" -eq "5" ] && [ "$resume_task" -eq "4" ]; then
        prompt_user=0
      fi

      # Prompt user
      if [ "$prompt_user" -eq "1" ]; then
        display_raw "\nWARN: The last execution of this script either exited in error or at the "
        display_raw "      user's request.  At this point, there are three available options:\n"
        display_raw "        1) resume the rolling upgrade where the last execution left off"
        display_raw "        2) restart the script from scratch"
        display_raw "        3) exit the script"
        display_raw "\n      Option (2) assumes the user has restored the primary and physical "
        display_raw "      standby back to the original configuration as required by this script.\n"
        prompt "Enter your selection" "1/2/3"
        if [ "$l_p_val" = "1" ]; then
          resuming=1
        else
          if [ "$l_p_val" = "2" ]; then
            resuming=0
            break
          else
            if [ "$l_p_val" = "3" ]; then
              exit
            fi
          fi
        fi
      fi
    else
      # A stage of 0 is possible if the script's version restore point is the only entry
      resuming=0
    fi
  fi
else
  resuming=0
fi

# Script will resume at the next task
if [ "$resuming" -eq "1" ]; then
  display "resuming execution of script"
  stage=$resume_stage
  task=$resume_task
  task=`expr $task + 1`
else
  # Script will start from scratch
  purge_resume_state $user $passwd $db1tns $db1name
  purge_resume_state $user $passwd $db2tns $db2name
  display "starting new execution of script"
  stage=1
  task=1
fi
}


###############################################################################
# NAME:        S1_backup
#
# DESCRIPTION: 
#   In this stage, we ensure that the user will be able to cleanly recover if 
#   they wish to abandon the rolling upgrade.  This involves creating initial 
#   flashback restore points, and backing up the control files on the primary 
#   and standby databases.  
#
# INPUT(S):
#   Arguments: 
#     None
# 
#   Globals:
#     $user $passwd $db1tns $db2tns $db1name $db2name $task $VERSION
#
# RETURN:
#   None
#
###############################################################################
S1_backup()
{
display_stage "Backup user environment in case rolling upgrade is aborted"

# 
# Step through each task
#
while [ "$task" ]
do 
  case "$task" in
      
  1)  # Create initial restore point and backup control files

      # Stop media recovery since we're about to create a restore point 
      stop_media_recovery $user $passwd $db2tns $db2name
   
      # Create initial restore point on standby
      create_restore_point $user $passwd $db2tns $db2name ${RPFX}_0000_${VERSION}
      
      # Create a backup control file on standby
      create_backup_ctlfile $user $passwd $db2tns $db2name ${RPFX}_${VERSION}_${db2name}_f.f
      
      # Create initial restore point on primary
      create_restore_point $user $passwd $db1tns $db1name ${RPFX}_0000_${VERSION}
      
      # Create a backup control file on primary
      create_backup_ctlfile $user $passwd $db1tns $db1name ${RPFX}_${VERSION}_${db1name}_f.f

      # Remind user of these safepoints
      display_raw "\nNOTE: Restore point ${RPFX}_0000_0001 and backup control file ${RPFX}_${VERSION}_${db2name}_f.f "
      display_raw "      can be used to restore ${db2name} back to its original state as a "
      display_raw "      physical standby, in case the rolling upgrade operation needs to be aborted "
      display_raw "      prior to the first switchover done in Stage 4."
      ;;

  *) break;;
  esac

  # Checkpoint our completion of the current task
  checkpoint

  # Proceed to next task
  task=`expr $task + 1`
done
}

###############################################################################
# NAME:        S2_physical_to_logical
#
# DESCRIPTION:
#   In this stage the physical standby is converted into a transient logical
#   standby database.  Before the conversion, the primary is checked for 
#   datatypes which may be problematic for the transient logical standby.
#   If found, these datatypes are written to an output log, so the user can
#   review them.
#
#   The actual conversion into a transient logical is achieved via the 
#   recover to logical standby database ddl.  This ddl runs media recovery
#   in a special mode responsible which looks specifically for the dictionary.
#   The section in the script below which performs this may perform multiple
#   builds in the event this script is interrupted.  This is necessary to avoid
#   the possibility that recovery was run by the user beyond the dictionary,
#   making instantiation not possible without a subsequent dictionary build.
#
# INPUT(S):
#   Arguments: 
#     None
# 
#   Globals:
#     $user $passwd $db1tns $db2tns $db1name $db2name $task
#     $LSP_APPLY_LAG $LSP_APPLY_LAG_TIMEOUT $MRP_APPLY_LAG 
#     $MRP_APPLY_LAG_TIMEOUT
#
# RETURN:
#   None
#
###############################################################################
S2_physical_to_logical()
{
display_stage "Create transient logical standby from existing physical standby"

# 
# RAC standbys must be reduced to a single instance for the duration of the
# instantiation.
#
l_s2_hint="unknown"
if [ "$task" -ge "1" ] && [ "$task" -le "4" ]; then
  while [ "1" ]
  do
    display "verifying RAC is disabled at $db2name"
    is_rac_database $user $passwd $db2tns $db2name
    if [ "$?" -eq "0" ]; then
      break
    fi

    l_s2_hint="rac"
    display_rac_demote $user $passwd $db2tns $db2name $db2iname "instantiation"
    display_raw "      Once these steps have been performed, enter 'y' to continue the script."
    display_raw "      If desired, you may enter 'n' to exit the script to perform the required"
    display_raw "      steps, and recall the script to resume from this point.\n"
    prompt "Are you ready to continue?" "y/n"
    if [ "$l_p_val" = "y" ]; then
      display "continuing"
    else
      display "exiting"
      exit
    fi
  done
fi

# 
# Step through each task
#
while [ "$task" ] 
do 
  case "$task" in

  1)  # Prerequisites
      isready=1

      # db1 should be the primary and db2 should be a physical standby
      display "verifying database roles"
      is_database_role $user $passwd $db1tns $db1name "PRIMARY"
      if [ "$?" -eq "0" ]; then
        fail "$db1name is not a primary database"
      fi
      is_database_role $user $passwd $db2tns $db2name "PHYSICAL STANDBY"
      if [ "$?" -eq "0" ]; then
        fail "$db2name is not a physical standby database"
      fi

      # Physical standby must be mounted
      display "verifying physical standby is mounted"
      is_open_mode $user $passwd $db2tns $db2name "MOUNTED"
      if [ "$?" -eq "0" ]; then
        display "ERROR: $db2name must be in MOUNTED mode"
        isready=0;
      fi

      # We do not allow maximum protection mode
      display "verifying database protection mode"
      get_protection_mode $user $passwd $db1tns $db1name
      if [ "$l_gpm_val" = "MAXIMUM PROTECTION" ]; then
        display "ERROR: maximum protection mode not permitted"
        isready=0
      fi
      
      # Exit if any requirements not met
      if [ "$isready" -ne "1" ]; then
        display "exiting: errors must be addressed in order to proceed"
        exit 1
      fi

      # Check for unsupported datatypes
      display "verifying transient logical standby datatype support"
      l_ptl1_sql="set pagesize 0 feedback off verify off heading off echo off tab off 
      whenever sqlerror exit sql.sqlcode 
      select count(*) from dba_logstdby_unsupported; 
      exit;"
      sql_exec $user $passwd $db1tns "$l_ptl1_sql"
      chkerr $? "failed to lookup unsupported datatypes on $db1name"

      # Write out unsupported datatypes 
      l_ptl1=`echo $sql_out`
      if [ "$l_ptl1" -gt "0" ]; then
        l_ptl2_sql="spool $LOG_UNSUPP_FILE 
        set pagesize 50000 linesize 165 feedback off verify off heading on echo off tab off 
        whenever sqlerror exit sql.sqlcode 
        set heading on 
        select * from dba_logstdby_unsupported; 
        spool off; 
        exit;" 
        sql_exec $user $passwd $db1tns "$l_ptl2_sql"
        chkerr $? "failed to query unsupported datatypes"

        # Ask permission to continue
        display_raw "\nWARN: Objects have been identified on the primary database which will not be"
        display_raw "      replicated on the transient logical standby.  The complete list of "
        display_raw "      objects and their associated unsupported datatypes can be found in the"
        display_raw "      dba_logstdby_unsupported view.  For convenience, this script has written"
        display_raw "      the contents of this view to a file - $LOG_UNSUPP_FILE."
        display_raw "\n      Various options exist to deal with these objects such as: "
        display_raw "        - disabling applications that modify these objects"
        display_raw "        - manually resolving these objects after the upgrade"
        display_raw "        - extending support to these objects (see metalink note: 559353.1)"
        display_raw "\n      If you need time to review these options, you should enter 'n' to exit"
        display_raw "      the script.  Otherwise, you should enter 'y' to continue with the "
        display_raw "      rolling upgrade.\n"
        prompt "Are you ready to proceed with the rolling upgrade?" "y/n"
        if [ "$l_p_val" = "y" ]; then
          display "continuing"
        else
          display "exiting"
          exit
        fi
      fi
      ;;

  2)  # Logical build and recover to logical standby

      # N.B.: We bundle the build and recover together since it's possible a 
      #       failure could occur before the recover to logical reaches the 
      #       build marker.  Any manual startup of the MRP could result in 
      #       recovering beyond the build marker making instantiation 
      #       impossible without another build.

      is_database_role $user $passwd $db2tns $db2name "PHYSICAL STANDBY"
      if [ "$?" -eq "1" ]; then

        # Stop media recovery in case it was left running
        stop_media_recovery $user $passwd $db2tns $db2name

        # Start media recovery
        start_media_recovery $user $passwd $db2tns $db2name

        # Switch logs on the primary
        switch_logs $user $passwd $db1tns $db1name

        # Wait for media recovery to catch up to a recent scn
        minimize_apply_lag $user $passwd $db1tns $db1name $db2tns $db2name $db2ver $MRP_APPLY_LAG $MRP_APPLY_LAG_TIMEOUT

        # Stop media recovery
        stop_media_recovery $user $passwd $db2tns $db2name 
     
        # Dump the logminer dictionary
        start_logical_build $user $passwd $db1tns $db1name

        # Recover to logical standby
        recover_to_logical $user $passwd $db2tns $db2name
      fi
      ;;

  3)  # Open transient logical standby database
     
      # N.B.: A bug in v$dataguard_stats apply lag prevents direct open
      if [ "$db2ver" = "11.1" ]; then
        shutdown_database $user $passwd $db2tns $db2name
        mount_database $user $passwd $db2tns $db2name
      fi

      # Instance must be in mounted mode
      is_open_mode $user $passwd $db2tns $db2name "MOUNTED"
      if [ "$?" -eq "0" ]; then
        fail "$db2name must be in MOUNTED mode"
      fi

      # Open the transient logical database
      open_database $user $passwd $db2tns $db2name
      ;;

  4)  # Configure and startup logical standby
       
      # NOTE: If <task> is assigned a new number from 4, the code in 
      #       S6_recovery_through_upgrade (task == 2) which
      #       calculates media recovery's completion of the upgrade
      #       redo, must be modified to consider the new resulting 
      #       restore point.

      # Instance must be open read write
      is_open_mode $user $passwd $db2tns $db2name "READ WRITE"
      if [ "$?" -eq "0" ]; then
        fail "$db2name must be in READ WRITE mode"
      fi

      # Stop logical standby (in case an error left it running)
      stop_logical_apply $user $passwd $db2tns $db2name

      # Set rolling upgrade parameters
      set_rolling_upgrade_params $user $passwd $db2tns $db2name

      # Start logical standby
      start_logical_apply $user $passwd $db2tns $db2name

      # Wait until dictionary load has finished
      wait_logical_dictload $user $passwd $db2tns $db2name

      # Switch logs on the primary
      switch_logs $user $passwd $db1tns $db1name

      # Wait until apply lag is within 5 minutes
      minimize_apply_lag $user $passwd $db1tns $db1name $db2tns $db2name $db2ver $LSP_APPLY_LAG $LSP_APPLY_LAG_TIMEOUT

      # Force a checkpoint since we're about to exit
      checkpoint

      # Display message that we're ready for them to ugprade.
      display_raw "\nNOTE: Database $db2name is now ready to be upgraded.  This script has left the"
      display_raw "      database open in case you want to perform any further tasks before "
      display_raw "      upgrading the database.  Once the upgrade is complete, the database must"
      display_raw "      opened in READ WRITE mode before this script can be called to resume the "
      display_raw "      rolling upgrade."

      # Display instructions on how to re-enable RAC
      display_rac_promote $user $passwd $db2tns $db2name $db2iname "db2upgrade" "$l_s2_hint"

      exit
      ;;

  *)  break;;
  esac

  # Checkpoint our completion of the current task
  checkpoint

  # Proceed to next task
  task=`expr $task + 1`

done
} # S2_physical_to_logical()

###############################################################################
# NAME:        S3_post_upgrade_validation
#
# DESCRIPTION: 
#   When this stage is entered, the user has already completed the manual 
#   upgrade, and has re-called this script to resume the rolling upgrade.  In 
#   this stage, the upgraded physical standby is validated to be on the 
#   newer binary, and no longer upgrading.
#
# INPUT(S):
#   Arguments: 
#     None
#
#   Globals:   $user $passwd $db2tns $db2name $task
#
# RETURN:
#   None
#
###############################################################################
S3_post_upgrade_validation()
{
display_stage "Validate upgraded transient logical standby"

# 
# Step through each task
#
while [ "$task" ] 
do 
  case "$task" in
  1)  # Validation

      # Database is no longer in open migrate mode
      is_open_mode $user $passwd $db2tns $db2name "OPEN MIGRATE"
      if [ "$?" -eq "1" ]; then
        fail "$4 must not be in OPEN MIGRATE mode"
      fi
      display "database $db2name is no longer in OPEN MIGRATE mode"

      # Database is on correct target version
      if [ "$db2version" != "$upgver" ]; then
        fail "$db2name is not at version $upgver"
      fi
      display "database $db2name is at version $upgver"

      # Future: EDS trigger deletion
      ;;

  *)  break;;
  esac 

  # Checkpoint our completion of the current task
  checkpoint

  # Proceed to next task
  task=`expr $task + 1`
done
} # S3_post_upgrade_validation

###############################################################################
# NAME:        S4_switchover
#
# DESCRIPTION: 
#   In this stage, the primary and upgraded, transient logical standby switch
#   roles.  This step is necessary since the former primary will be flashed 
#   back and converted into a physical standby which will then recover the 
#   upgrade redo.
#
# INPUT(S):
#   Arguments: 
#     None
#
#   Globals:   $user $passwd $db1tns $db2tns $db1name $db2name $task
#
# RETURN:
#   None
#
###############################################################################
S4_switchover()
{
display_stage "Switch the transient logical standby to be the new primary"

# 
# Step through each task
#
while [ "$task" ]
do 
  case "$task" in
  1)  # Preparing logical standby for switchover

      is_database_role $user $passwd $db1tns $db1name "PRIMARY"
      if [ "$?" -eq "0" ]; then
        fail "$db1name is not a primary database"
      fi
      is_database_role $user $passwd $db2tns $db2name "LOGICAL STANDBY"
      if [ "$?" -eq "0" ]; then
        fail "$db2name is not a logical standby database"
      fi

      is_open_mode $user $passwd $db1tns $db1name "READ WRITE"
      if [ "$?" -eq "0" ]; then
        fail "$db1name must be in READ WRITE mode"
      fi

      is_open_mode $user $passwd $db2tns $db2name "READ WRITE"
      if [ "$?" -eq "0" ]; then
        fail "$db2name must be in READ WRITE mode"
      fi

      display "waiting for $db2name to catch up (this could take a while)"
      switch_logs $user $passwd $db1tns $db1name
      start_logical_apply $user $passwd $db2tns $db2name
      minimize_apply_lag $user $passwd $db1tns $db1name $db2tns $db2name $db2ver $LSP_APPLY_LAG $LSP_APPLY_LAG_TIMEOUT
      ;;

  2)  # Switch $db1name to the logical standby role
      switch_primary_to_logical $user $passwd $db1tns $db1name
      ;;

  3)  # Confirm $db2name has witnessed the role change
      wait_standby_eor $user $passwd $db2tns $db2name $db2ver
      ;;

  4)  # Switch $db2name to the primary role
      switch_logical_to_primary $user $passwd $db2tns $db2name
      ;;

  *)  break;;
  esac  

  # Checkpoint our completion of the current task
  checkpoint

  # Proceed to next task
  task=`expr $task + 1`
done

} # S4_switchover

###############################################################################
# NAME:        S5_primary_to_physical
#
# DESCRIPTION: 
#   In this stage, the former primary (now a logical standby as the result of a
#   switchover) is flashed back and converted into a physical standby.  The 
#   script exits after the flashback since the user is responsible for starting
#   up the physical standby using the newer binary.
#
# INPUT(S):
#   Arguments: 
#     None
#
#   Globals:   $user $passwd $db1tns $db1name $task
#
# RETURN:
#   None
#
###############################################################################
S5_primary_to_physical()
{
display_stage "Flashback former primary to pre-upgrade restore point and convert to physical"

# 
# db1 must be reduced to a single instance for the conversion to a physical 
#
if [ "$task" -ge "1" ] && [ "$task" -le "4" ]; then
  is_rac_database $user $passwd $db1tns $db1name
  if [ "$?" -eq "1" ]; then
    while [ "1" ]
    do
      display "verifying instance $db1iname is the only active instance"
      display_rac_demote $user $passwd $db1tns $db1name $db1iname "convert"
      if [ "$?" -eq "0" ]; then
        break
      else
        display_raw "      Once these steps have been performed, enter 'y' to continue the script."
        display_raw "      If desired, you may enter 'n' to exit the script to perform the required"
        display_raw "      steps, and recall the script to resume from this point.\n"
        prompt "Are you ready to continue?" "y/n"
        if [ "$l_p_val" = "y" ]; then
          display "continuing"
        else
          display "exiting"
          exit
        fi
      fi
    done
  fi
fi

# 
# Step through each task
#
l_s5_db1israc=0
while [ "$task" ] 
do 
  case "$task" in
  1)  # After the last switchover, db1 should be a logical standby
      is_database_role $user $passwd $db1tns $db1name "LOGICAL STANDBY"
      if [ "$?" -eq "0" ]; then
        fail "$db1name is not a logical standby database"
      fi

      # After the last switchover, db2 should be the new primary
      is_database_role $user $passwd $db2tns $db2name "PRIMARY"
      if [ "$?" -eq "0" ]; then
        fail "$db2name is not a primary database"
      fi

      # Restart database in mounted mode
      shutdown_database $user $passwd $db1tns $db1name
      mount_database $user $passwd $db1tns $db1name
      ;;

  2)  # Flashing back former primary to pre-upgrade restore point
      is_open_mode $user $passwd $db1tns $db1name "MOUNTED"
      if [ "$?" -eq "0" ]; then
        fail "$db1name must be in MOUNTED mode"
      fi
      flashback_database $user $passwd $db1tns $db1name ${RPFX}_0000_${VERSION}
      ;;

  3)  # Converting primary to physical standby database
      convert_to_physical $user $passwd $db1tns $db1name
      ;;

  4)  # Save RAC status prior to shutting down the database
      is_rac_database $user $passwd $db1tns $db1name
      l_s5_db1israc=$?
      
      # Shutting down database $db1name
      shutdown_database $user $passwd $db1tns $db1name

      # Force a checkpoint since we're about to exit
      checkpoint

      # User must restart db1 with the new oracle binary
      display_raw "\nNOTE: Database $db1name has been shutdown, and is now ready to be started "
      display_raw "      using the newer version Oracle binary.  This script requires the "
      display_raw "      database to be mounted (on all active instances, if RAC) before calling "
      display_raw "      this script to resume the rolling upgrade."

      if [ "$l_s5_db1israc" -eq "1" ]; then
        display_rac_promote $user $passwd $db1tns $db1name $db1iname "db1upgrade"
      else
        display_raw " "
      fi
      exit
      ;;

  *)  break;;
  esac
  
  # Checkpoint our completion of the current task
  checkpoint

  # Proceed to next task
  task=`expr $task + 1`
done

} # S5_primary_to_physical

###############################################################################
# NAME:        S6_recover_through_upgrade
#
# DESCRIPTION: 
#   In this stage, the former primary (now a physical standby on a newer binary)
#   is monitored as it recovers up to and through the upgrade redo.  During 
#   this stage, media recovery's progress is frequently output along with
#   estimated completion times.
#
# INPUT(S):
#   Arguments: 
#     None
#
#   Globals:   $user $passwd $db1tns $db2tns $db1name $db2name $task
#
# RETURN:
#   None
#
###############################################################################
S6_recover_through_upgrade()
{
display_stage "Run media recovery through upgrade redo"

# Nothing to do if task 3 was the last completed task
if [ "$task" -gt "3" ]; then
  return;
fi

# Defer exiting so the user gets as much repair context as possible up front
l_rtu_ready=1

# db1 must be physical standby, mounted, and on the upgrade version
is_database_role $user $passwd $db1tns $db1name "PHYSICAL STANDBY"
if [ "$?" -eq "0" ]; then
  display "ERROR: $db1name is not a physical standby database"
  l_rtu_ready=0
fi
is_open_mode $user $passwd $db1tns $db1name "MOUNTED"
if [ "$?" -eq "0" ]; then
  display "ERROR: $db1name must be in MOUNTED mode"
  l_rtu_ready=0
fi
if [ "$db1version" != "$upgver" ]; then
  display "ERROR: $db1name is not at version $upgver"
  l_rtu_ready=0
fi

# db2 must be a primary, open read write, and on the upgrade version
is_database_role $user $passwd $db2tns $db2name "PRIMARY"
if [ "$?" -eq "0" ]; then
  display "ERROR: $db2name is not a primary database"
  l_rtu_ready=0
fi
is_open_mode $user $passwd $db2tns $db2name "READ WRITE"
if [ "$?" -eq "0" ]; then
  display "ERROR: $db2name must be in READ WRITE mode"
  l_rtu_ready=0
fi
if [ "$db2version" != "$upgver" ]; then
  display "ERROR: $db2name is not at version $upgver"
  l_rtu_ready=0
fi

# Exit if any unsatisfied requirements
if [ "$l_rtu_ready" -eq "0" ]; then
  display "exiting: errors must be addressed in order to proceed"
  exit 1;
fi

# Wait for media recovery to recover through upgrade
# Obtain the scn boundaries which define the upgrade region.  We make 
# use of the scns associated with the restore points created at 
# stage 2, task 4 and stage 3, task 1 to define the upgrade region.  

# Get scn where upgrade starts
get_flashback_scn $user $passwd $db2tns $db2name "${RPFX}_0204"
l_rtu_begscn=$l_gfs_val

# Get scn where upgrade ends
get_flashback_scn $user $passwd $db2tns $db2name "${RPFX}_0301"
l_rtu_endscn=$l_gfs_val

# Use the start/end range as the scale for media recovery's progress
sql_eval $user $passwd $db2tns $db2name "( ${l_rtu_endscn} - ${l_rtu_begscn} )"
l_rtu_range=$l_se_val
display "upgrade redo region identified as scn range [${l_rtu_begscn}, ${l_rtu_endscn}]"

# Switch logs on the primary
switch_logs $user $passwd $db2tns $db2name

# Start media recovery 
start_media_recovery $user $passwd $db1tns $db1name

# Wait until v$recovery_progress has been initialized
display "waiting for media recovery to initialize v\$recovery_progress"
l_rtu_status=1
l_rtu_curtime=`perl -e 'print int(time)'`
l_rtu_exptime=`expr $MRP_START_TIMEOUT "*" 60`
l_rtu_maxtime=`expr $l_rtu_curtime + $l_rtu_exptime`
while [ "$l_rtu_curtime" -lt "$l_rtu_maxtime" ]
do
  get_recovery_scn $user $passwd $db1tns $db1name $db1ver
  l_rtu_curscn=$l_grs_val
  if [ "$l_rtu_curscn" != "0" ]; then
    l_rtu_status=0
    break
  fi
  sleep $STB_VIEW_INIT_INTERVAL
  l_rtu_curtime=`perl -e 'print int(time)'`
done
chkerr $l_rtu_status "timed out after $MRP_START_TIMEOUT minutes of inactivity"
l_rtu_lsttime=$l_rtu_curtime
l_rtu_lstscn=$l_rtu_curscn

# Incur one wait interval before taking the next snapshot
sleep $MRP_REDO_PROG_INTERVAL

# Report on the MRP's progress 
display "monitoring media recovery's progress"
l_rtu_status=1
l_rtu_curtime=`perl -e 'print int(time)'`
l_rtu_numrate=0
l_rtu_totrate=0
l_rtu_lstprog=0
while [ "$l_rtu_curtime" -lt "$l_rtu_maxtime" ]
do
  # Get media recovery's current scn (ie last applied) and current time
  get_recovery_scn $user $passwd $db1tns $db1name $db1ver
  l_rtu_curscn=$l_grs_val

  if [ "$PHYSRU_DEBUG" = "1" ]; then
    display "DEBUG: cur ($l_rtu_curscn) lst ($l_rtu_lstscn)"
  fi

  # Validate the just fetched recovery scn and time
  # N.B.: I've seen this on few occasions return dirty values (either 0 or an 
  #       scn less than the previously fetched scn).  In either case, discard
  #       the values and try at the next interval.
  if [ "$l_rtu_curscn" = "0" ] || (sql_lt $user $passwd $db1tns "$l_rtu_curscn" "$l_rtu_lstscn") ; then

    # A 0 scn could indicate the MRP is no longer active.
    if [ "$l_rtu_curscn" = "0" ]; then
      display "failed to determine the last applied scn by media recovery"

      # Wait for the MRP to become active
      wait_mrp_active $user $passwd $db1tns $db1name
    else
      display "WARN: last applied scn of $l_rtu_curscn is less than $l_rtu_lstscn"
    fi

    # Wait until the next interval for the next snapshot
    sleep $MRP_REDO_PROG_INTERVAL
    l_rtu_curtime=`perl -e 'print int(time)'`
    continue
  fi

  if [ "$l_rtu_curtime" -le "$l_rtu_lsttime" ]; then
    fail "current time of $l_rtu_curtime is not greater than last time of $l_rtu_lsttime"
  fi

  # Increment samples counter since we know we'll use the scn/time values
  l_rtu_numrate=`expr $l_rtu_numrate + 1`

  # MRP is beyond upgrade redo end
  if (sql_gt $user $passwd $db1tns "$l_rtu_curscn" "$l_rtu_endscn"); then
    if [ "$task" -le "3" ]; then
      task=3
      checkpoint
      task=`expr $task + 1`
    fi

    display "media recovery has finished recovering through upgrade"
    l_rtu_status=0
    break
  else
    # MRP is before upgrade redo start
    if (sql_lt $user $passwd $db1tns "$l_rtu_curscn" "$l_rtu_begscn"); then
      if [ "$task" -eq "1" ]; then
        checkpoint
        task=`expr $task + 1`
      fi

      if [ "$l_rtu_curscn" != "$l_rtu_lstscn" ]; then
        display "last applied scn $l_rtu_curscn is approaching upgrade redo start scn $l_rtu_begscn"
      fi
    else
      # MRP is currently recovering upgrade redo
      if [ "$task" -le "2" ]; then
        task=2
        checkpoint
        task=`expr $task + 1`
      fi

      # Calculate average apply rate
      sql_eval $user $passwd $db2tns $db2name "(( ${l_rtu_curscn} - ${l_rtu_lstscn} ) / ( ${l_rtu_curtime} - ${l_rtu_lsttime} ))"
      l_rtu_currate=$l_se_val
      l_rtu_totrate=`expr $l_rtu_totrate + $l_rtu_currate`
      l_rtu_avgrate=`expr $l_rtu_totrate / \( $l_rtu_numrate \)`

      # Calculate estimated time of completion
      sql_eval $user $passwd $db2tns $db2name "(( ${l_rtu_endscn} - ${l_rtu_curscn} ) / ${l_rtu_avgrate} )"
      l_rtu_sectime=$l_se_val
      l_rtu_dattime=`date "+%b %d %R:%S" -d "+${l_rtu_sectime} second"`

      # Report progress
      sql_eval $user $passwd $db2tns $db2name "((( ${l_rtu_curscn} - ${l_rtu_begscn} ) * 100 ) / ${l_rtu_range} )"
      l_rtu_curprog=$l_se_val
      l_rtu_strprog=`printf %02d $l_rtu_curprog`
      if [ "$l_rtu_curprog" -gt "$l_rtu_lstprog" ] && [ "$l_rtu_curprog" -lt "100" ]; then
        display "recovery of upgrade redo at ${l_rtu_strprog}% - estimated complete at $l_rtu_dattime"
      fi
      l_rtu_lstprog=$l_rtu_curprog
    fi
  fi

  # Reset timeout if scn has changed from last check
  if [ "$l_rtu_curscn" != "$l_rtu_lstscn" ]; then
    l_rtu_maxtime=`expr $l_rtu_curtime + $l_rtu_exptime`
  fi

  # Retain apply scn and apply time
  l_rtu_lstscn=$l_rtu_curscn
  l_rtu_lsttime=$l_rtu_curtime

  # Sleep before we check again
  sleep $MRP_REDO_PROG_INTERVAL
  l_rtu_curtime=`perl -e 'print int(time)'`
done
chkerr $l_rtu_status "timed out after $MRP_UPGRADE_TIMEOUT minutes of inactivity"

# Checkpoint our completion of the current task
checkpoint

} # S6_recover_through_upgrade

###############################################################################
# NAME:        S7_switchback
#
# DESCRIPTION: 
#   In this stage, the physical standby and primary databases switch roles to
#   restore the original roles prior to the roling upgrade.  By the time this
#   stage is entered, both databases have been fully upgraded.
#
# INPUT(S):
#   Arguments: 
#     None
#
#   Globals:   $user $passwd $db1tns $db2tns $db1name $db2name $task
#
# RETURN:
#   None
#
###############################################################################
S7_switchback()
{
display_stage "Switch back to the original roles prior to the rolling upgrade"

if [ "$task" -eq "1" ]; then
  display_raw "\nNOTE: At this point, you have the option to perform a switchover"
  display_raw "     which will restore $db1name back to a primary database and "
  display_raw "     $db2name back to a physical standby database.  If you answer 'n'"
  display_raw "     to the question below, $db1name will remain a physical standby"
  display_raw "     database and $db2name will remain a primary database.\n"
  prompt "Do you want to perform a switchover?" "y/n"
  checkpoint
  if [ "$l_p_val" = "y" ]; then
    display "continuing"
    task=2
  else
    display "skipping final switchover"
    # Set task to switchover-end state
    task=7
  fi
fi

#
# Both db1 and db2 must be reduced to single instances for physical switchover
#
if [ "$task" -ge "1" ] && [ "$task" -le "6" ]; then
  while [ "1" ]
  do
    # Init flag which indicates prompt is needed
    l_s7_db1prompt=0
    l_s7_db2prompt=0

    # Determine if db2 (the current primary) is a RAC
    is_rac_database $user $passwd $db2tns $db2name
    if [ "$?" -eq "1" ]; then
      display "verifying instance $db2iname is the only active instance"
      display_rac_demote $user $passwd $db2tns $db2name $db2iname "primary"
      l_s7_db2prompt=$?
    fi

    # Only on 11.1 must db1 (the physical standby) reduce to a single instance
    if [ "$db1ver" = "11.1" ]; then
      is_rac_database $user $passwd $db1tns $db1name
      if [ "$?" -eq "1" ]; then
        display "verifying instance $db1iname is the only active instance"
        display_rac_demote $user $passwd $db1tns $db1name $db1iname "physical"
        l_s7_db1prompt=$?
      fi
    fi

    # Prompt user if either db1 or db2 needs to be reduced
    if [ "$l_s7_db1prompt" -eq "1" ] || [ "$l_s7_db2prompt" -eq "1" ]; then
      display_raw "      Once these steps have been performed, enter 'y' to continue the script."
      display_raw "      If desired, you may enter 'n' to exit the script to perform the required"
      display_raw "      steps, and recall the script to resume from this point.\n"
      prompt "Are you ready to continue?" "y/n"
      if [ "$l_p_val" = "y" ]; then
        display "continuing"
      else
        display "exiting"
        exit
      fi
    else
      # Not necessary to prompt
      break
    fi
  done
fi

while [ "$task" ]
do 
  case "$task" in
  2)  # Preparing media recovery for switchover

      is_database_role $user $passwd $db2tns $db2name "PRIMARY"
      if [ "$?" -eq "0" ]; then
        fail "$db2name is not a primary database"
      fi
      is_database_role $user $passwd $db1tns $db1name "PHYSICAL STANDBY"
      if [ "$?" -eq "0" ]; then
        fail "$db1name is not a physical standby database"
      fi

      is_open_mode $user $passwd $db2tns $db2name "READ WRITE"
      if [ "$?" -eq "0" ]; then
        fail "$db2name must be in READ WRITE mode"
      fi

      is_open_mode $user $passwd $db1tns $db1name "MOUNTED"
      if [ "$?" -eq "0" ]; then
        fail "$db1name must be in MOUNTED mode"
      fi

      # Start media recovery (typically it's already running)
      switch_logs $user $passwd $db2tns $db2name
      start_media_recovery $user $passwd $db1tns $db1name
      minimize_apply_lag $user $passwd $db2tns $db2name $db1tns $db1name $db1ver $MRP_APPLY_LAG $MRP_APPLY_LAG_TIMEOUT
      ;;

  3)  # Switch $db2name to the physical standby role
      switch_primary_to_physical $user $passwd $db2tns $db2name

      # Restart only if we've just switched
      if [ "$?" -eq "0" ]; then
        shutdown_database $user $passwd $db2tns $db2name
        mount_database $user $passwd $db2tns $db2name
      fi
      ;;

  4)  # Confirm $db1name has witnessed the role change
      wait_standby_eor $user $passwd $db1tns $db1name $db1ver
      ;;

  5)  # Switch $db1name to the primary role
      switch_physical_to_primary $user $passwd $db1tns $db1name

      # Open only if we've just switched
      if [ "$?" -eq "0" ]; then
        open_database $user $passwd $db1tns $db1name
      fi
      ;;

  6)  # Start media recovery
      # N.B.: We omit the 'through next switchover' option because it's possible for the MRP 
      #       to reprocess the EOR log file 
      start_media_recovery $user $passwd $db2tns $db2name "using current logfile disconnect"

      # Display a relevant message regarding how to startup the remaining RAC instances on db1
      is_rac_database $user $passwd $db1tns $db1name
      if [ "$?" -eq "1" ]; then
        if [ "$db1ver" = "11.1" ]; then
          # db1 was reduced to a single instance
          display_rac_promote $user $passwd $db1tns $db1name $db1iname "primary11.1"
        else
          # db1 has one open instance while peer instances are still mounted
          display_rac_promote $user $passwd $db1tns $db1name $db1iname "primary"
        fi
      fi

      # Display a relevant message regarding how to startup the remaining RAC instances on db2
      is_rac_database $user $passwd $db2tns $db2name
      if [ "$?" -eq "1" ]; then
        # db2 was reduced to a single instance
        display_rac_promote $user $passwd $db2tns $db2name $db2iname "physical"
      fi      
      ;;

  7)  # This task is a place-holder task which indicates switchover completion.  It is 
      # necessary since this particular checkpoint also represents the end of the script.
      ;;

  *)  break;;
  esac  

  # Checkpoint our completion of the current task
  checkpoint

  # Proceed to next task
  task=`expr $task + 1`
done

} # S7_switchback

###############################################################################
# NAME:        S8_statistics
#
# DESCRIPTION: 
#   In this stage, this script produces statistics regarding the upgrade.  
#
# INPUT(S):
#   Arguments: 
#     None
#
#   Globals:   $user $passwd $db2tns $db2name $task
#
# RETURN:
#   None
#
###############################################################################
S8_statistics()
{
display_stage "Statistics"

# 
# Step through each task
#
while [ "$task" ]
do 
  case "$task" in
  1)  # Display physical rolling upgrade statistics
      display_stats $user $passwd $db2tns $db2name
      ;;  

  *)  break;;
  esac

  # Checkpoint our completion of the current task
  checkpoint

  # Proceed to next task
  task=`expr $task + 1`
done

} # S8_statistics

###############################################################################
# NAME:        S9_cleanup
#
# DESCRIPTION: 
#   In this stage, the script purges both databases of flashback restore points
#   that it created to maintain its execution state.
#
# INPUT(S):
#   Arguments: 
#     None
#
#   Globals:   $user $passwd $db1tns $db2tns $db1name $db2name $task
#
# RETURN:
#   None
#
###############################################################################
S9_cleanup()
{
# For now just suppress all output related to cleanup
suppress=1
display_stage "Cleanup"

# 
# Step through each task
#
while [ "$task" ]
do 
  case "$task" in
  1)  # With checkpointing no longer necessary, ensure MRP is left running
      is_database_role $user $passwd $db2tns $db2name "PHYSICAL STANDBY"
      if [ "$?" -eq "1" ]; then
        start_media_recovery $user $passwd $db2tns $db2name "using current logfile disconnect"
      fi
      ;;

  2)  # Purge restore points from test script
      purge_resume_state $user $passwd $db1tns $db1name
      purge_resume_state $user $passwd $db2tns $db2name

      # Delete temp files
      rm $LOG_SQL_EXETMP > /dev/null
      ;;

  *)  break;;
  esac  

  # No checkpoint since we've purged all restore points

  # Proceed to next task
  task=`expr $task + 1`
done
	
suppress=0
} # S9_cleanup


###############################################################################
############    UTILITY ROUTINES    ###########################################
###############################################################################

###############################################################################
# NAME:        checkpoint
#
# DESCRIPTION: 
#   Create a restore point to indicate a given task has been completed.  The 
#   majority of restore points are created on db2 with the exception of the 
#   restore point needed by the original primary to flashback before its 
#   conversion into a physical standby.  Note that in order to take a
#   checkpoint media recovery must not be running.
#
# INPUT(S):
#   Arguments:
#     None
#
#   Globals:
#     $user $passwd $db1tns $db2tns $db2name $stage $task $RPFX
#
# RETURN:
#   None
# 
###############################################################################
checkpoint()
{
stagestr=`printf %02d $stage`
taskstr=`printf %02d $task`
l_checkpoint_rpname="${RPFX}_${stagestr}${taskstr}" 

suppress=1
stop_media_recovery $user $passwd $db2tns $db2name
create_restore_point $user $passwd $db2tns $db2name $l_checkpoint_rpname
suppress=0
}

###############################################################################
# NAME:        chkerr
#
# DESCRIPTION: 
#   Check if $1 is non-zero, and if so, output the message supplied in $2 and
#   exit immediately.
# 
# INPUT(S):
#   Arguments:
#     $1: status code
#     $2: error message
#
#   Globals:
#     None
#
# RETURN:
#   None
#
###############################################################################
chkerr()
{
if [ "$1" -ne "0" ]; then
  fail "$2"
  exit $1
fi
}

###############################################################################
# NAME:        convert_to_physical
#
# DESCRIPTION: 
#   Convert the flashed back database (currently only for the former primary) 
#   into a physical standby.
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#
#   Globals:
#     None
#
# RETURN:
#   None
###############################################################################
convert_to_physical()
{
display "converting $4 into physical standby"
# Convert the flashed back logical standby to a physical standby
l_ctp_sql="set pagesize 0 feedback off verify off heading off echo off tab off 
whenever sqlerror exit sql.sqlcode 
alter database convert to physical standby; 
exit;"
sql_exec $1 $2 $3 "$l_ctp_sql"
chkerr $? "faied to convert to physical standby"
}

###############################################################################
# NAME:        create_backup_ctlfile
#
# DESCRIPTION: 
#   Create a backup control file for the specified database.  If one already
#   exists, it is deleted before the backup is created.
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#     $5: name of backup control file
#
#   Globals:
#     $LOC_BACKUP_FILES
#
# RETURN:
#   None
#
###############################################################################
create_backup_ctlfile()
{
display "backing up current control file on $4"

# Delete the old backup controlfile to avoid an ORA-27038
if [ -f "${LOC_BACKUP_FILES}${5}" ]; then
  rm ${LOC_BACKUP_FILES}${5}
fi

# Create a new backup control file
l_cbc_sql="set pagesize 0 feedback off verify off heading off echo off tab off 
whenever sqlerror exit sql.sqlcode 
alter database backup controlfile to '${LOC_BACKUP_FILES}${5}'; 
exit;"
sql_exec $1 $2 $3 "$l_cbc_sql"
chkerr $? "failed to backup control file on database $4"
display "created backup control file ${LOC_BACKUP_FILES}${5}"
}

###############################################################################
# NAME:        create_restore_point
#
# DESCRIPTION: 
#   Create a named, guaranteed flashback database restore point
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#     $5: restore point name
#
#   Globals:
#     None
#
# RETURN:
#   None
#
###############################################################################
create_restore_point()
{
display "creating restore point $5 on database $4"
l_crp_sql="set pagesize 0 feedback off verify off heading off echo off tab off 
whenever sqlerror exit sql.sqlcode 
create restore point $5 guarantee flashback database; 
exit;"
sql_exec $1 $2 $3 "$l_crp_sql" 
chkerr $? "failed to create restore point"
}

###############################################################################
# NAME:        display
#
# DESCRIPTION: 
#   Display message to console and logfile, if enabled.  The suppress global,
#   if set, will suppress all output.  The $LOG_PHYSRU_ENABLED global controls
#   whether the message is also written to the log file.
#
# INPUT(S):
#   Arguments:
#     $1: message to display
#
#   Globals:
#     $stage $task $suppress $suppresst $suppressl $LOG_PHYSRU_ENABLED $LOG_PHYSRU_FILE
#
# RETURN:
#   None
#
###############################################################################
display()
{
if [ "$suppress" -eq "1" ]; then
  return 0
else
  ts=`date "+%b %d %R:%S %Y"`
  if [ "$suppresst" -eq "0" ]; then
    echo -e "$ts [$stage-$task] $1"
  fi
  if [ "$suppressl" -eq "0" ]; then  
    if [ "$LOG_PHYSRU_ENABLED" -eq "1" ]; then
      echo -e "$ts [$stage-$task] $1" >> $LOG_PHYSRU_FILE
    fi
  fi
  return 0
fi
}

###############################################################################
# NAME:        display_banner
#
# DESCRIPTION: 
#   Displays required Oracle banner
#
# INPUT(S):
#   Arguments:
#     None
#
#   Globals:
#     None
#
# RETURN:
#   None
#
###############################################################################
display_banner()
{
echo ""
}

###############################################################################
# NAME:        display_rac_demote
#
# DESCRIPTION: 
#   Displays instructions to the user about reducing the RAC.  $6 identifies one
#   of four possible states where it may be necessary to reduce the RAC.  These 
#   states are 1) instantiation of the transient logical 2) primary to physical
#   standby conversion 3) primary to physical standby switchover, and 4) physical
#   to primary switchover.  
#
#   This routine returns a 1 to indicate instructions were displayed, and 0
#   otherwise.
#
#   This routine assumes that the caller has already verified the specified 
#   database is a RAC.  
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#     $5: instance name
#     $6: context - "instantiation", "convert", "primary", "physical"
#
#   Globals:
#     None
#
# RETURN:
#   0: Instructions were not displayed
#   1: Instructions were displayed
#
###############################################################################
display_rac_demote()
{
# Variable for instruction number
i=0

# Variable for return value
l_drd_val=0

# Create a list of RAC instance peers that need to be shutdown
get_instance_peers $1 $2 $3 $4 $5
l_drd_instcnt=$l_gip_val
l_drd_instlst="$l_gip_lst"

# Instantiation requires RAC to be disabled
if [ "$6" = "instantiation" ]; then

  # Display instructions to user
  display_raw "\nWARN: $4 is a RAC database.  Before this script can continue, you"
  display_raw "      must manually reduce the RAC to a single instance, disable the RAC, and"
  display_raw "      restart instance $5 in mounted mode.  This can be accomplished "
  display_raw "      with the following steps:"

  # Only indicate shutdown if one or more peer instances is active
  if [ "$l_drd_instcnt" -gt "0" ]; then
    i=`expr $i + 1`
    display_raw "\n        $i) Shutdown all instances other than instance $5."
    display_raw "           eg: srvctl stop instance -d $4 -i $l_drd_instlst -o abort"
  fi

  # cluster_database needs to be set to FALSE
  i=`expr $i + 1`
  display_raw "\n        $i) On instance $5, set the cluster_database parameter to FALSE."
  display_raw "           eg: SQL> alter system set cluster_database=false scope=spfile;"
  i=`expr $i + 1`
  display_raw "\n        $i) Shutdown instance $5."
  display_raw "           eg: SQL> shutdown abort;"

  # Restart in target mode
  i=`expr $i + 1`
  display_raw "\n        $i) Startup instance $5 in mounted mode."
  display_raw "           eg: SQL> startup mount;\n"
  l_drd_val=1

# Conversion to a physical standby requires the RAC to be reduced to a single instance
else if [ "$6" = "convert" ]; then

  # Only indicate shutdown message if one or more peer instances are active
  if [ "$l_drd_instcnt" -gt "0" ]; then

    # Display instructions to user
    display_raw "\nWARN: $4 is a RAC database.  Before this script can continue, you"
    display_raw "      must manually reduce the RAC to a single instance.  This can be "
    display_raw "      accomplished with the following step:"

    i=`expr $i + 1`
    display_raw "\n        $i) Shutdown all instances other than instance $5."
    display_raw "           eg: srvctl stop instance -d $4 -i $l_drd_instlst -o abort\n"
      
    l_drd_val=1
  fi

# A switchover to physical requires the primary peer instances to be shutdown 
# during the switchover.  A switchover to primary requires the standby peer 
# instances to be shutdown only on Oracle version 11.1.  In 11.2 and higher, the 
# instances may remain active.
else if [ "$6" = "primary" ] || [ "$6" = "physical" ]; then

  # Display instructions only if peer instances are active
  if [ "$l_drd_instcnt" -gt "0" ]; then
    i=`expr $i + 1`
    display_raw "\nWARN: $4 is a RAC database.  Before this script can continue, you "
    display_raw "      must manually reduce the RAC to a single instance.  This can be "
    display_raw "      accomplished with the following step:"
    display_raw "\n        $i) Shutdown all instances other than instance $5."
    if [ "$6" = "primary" ]; then 
      display_raw "           eg: srvctl stop instance -d $4 -i $l_drd_instlst\n"
    else
      if [ "$6" = "physical" ]; then 
        display_raw "           eg: srvctl stop instance -d $4 -i $l_drd_instlst -o abort\n"
      fi
    fi
    l_drd_val=1
  fi
fi
fi
fi

return $l_drd_val
}

###############################################################################
# NAME:        display_rac_promote
#
# DESCRIPTION: 
#   Displays a message to the user about upgrading the single instance to a RAC.
#   The $6 argument identifies the context from which this routine is called. 
#   
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#     $5: instance name
#     $6: context - "db2upgrade", "db1upgrade", "primary11.1", "primary", "physical" 
#     $7: hint (optional) - "rac", "unknown"
#
#   Globals:
#     None
#
# RETURN:
#   None
#
###############################################################################
display_rac_promote()
{
#
# $6: db2upgrade
#
# In this state, db2 has completed the physical to transient logical setup and
# is now ready to be upgraded.  If db2 was a RAC we forced the user to disable 
# it for the instantiation.
#
if [ "$6" = "db2upgrade" ]; then

  # N.B.: $7 is a hint which allows us to present a more user-friendly message.  If the 
  #       script was uninterrupted, we'll know the user disabled RAC, and will want to
  #       re-enable it for the upgrade.  If the script was interrupted, we won't have any
  #       way of knowing, and will present a generic suggestion to enable the RAC.
  if [ "$7" = "unknown" ]; then
    display_raw "\nNOTE: If $4 was previously a RAC database that was disabled, it may be"
    display_raw "      reverted back to a RAC database upon completion of the rdbms upgrade."
    display_raw "      This can be accomplished by performing the following steps:\n"
  else if [ "$7" = "rac" ]; then
    display_raw "\nNOTE: Database $4 may be reverted back to a RAC database upon completion"
    display_raw "      of the rdbms upgrade.  This can be accomplished by performing the "
    display_raw "      following steps:\n"
  fi
  fi

  display_raw "          1) On instance $5, set the cluster_database parameter to TRUE."
  display_raw "          eg: SQL> alter system set cluster_database=true scope=spfile;\n"

  display_raw "          2) Shutdown instance $5."
  display_raw "          eg: SQL> shutdown abort;\n"

  display_raw "          3) Startup and open all instances for database $4."
  display_raw "          eg: srvctl start database -d $4\n"

#
# $6: db1upgrade
#
# In this state, db1 has completed the flashback and conversion to physical standby,
# and has been shutdown in preparation for startup on the newer version binary.
#
else if [ "$6" = "db1upgrade" ]; then
  display_raw "\nNOTE: Database $4 is no longer limited to single instance operation since"
  display_raw "      the database has been successfully converted into a physical standby."
  display_raw "      For increased availability, Oracle recommends starting all instances in"
  display_raw "      the RAC on the newer binary by performing the following step:\n"

  display_raw "        1) Startup and mount all instances for database $4"
  display_raw "        eg: srvctl start database -d $4 -o mount\n"

#
# $6: primary11.1
#
# In this state, db1 has switched back to the primary role from a physical standby on a
# target version of 11.1.X.  In 11.1, the switchover required the RAC standby to be reduced
# to a single instance. As a result, all that is needed is the startup of the inactive 
# instances.
#
else if [ "$6" = "primary11.1" ]; then
  display_raw "\nNOTE: Database $4 is no longer limited to single instance operation since"
  display_raw "      it has completed the switchover to the primary role.  For increased "
  display_raw "      availability, Oracle recommends starting the inactive instances in "
  display_raw "      the RAC by performing the following step:\n"

  display_raw "        1) Startup and open inactive instances for database $4"
  display_raw "        eg: srvctl start database -d $4"

#
# $6: primary
#
# In this state, db1 has switched back to the primary role from a physical standby on a
# target version of 11.2 or higher.  Starting in 11.2, a RAC physical standby does not
# need to be reduced to a single instance in order to switchover.  One side effect of this
# however is that upon switchover, the instance on which the switchover DDL was issued will
# be opened in READ/WRITE mode while the peer instances will remain in mounted mode.  Since
# there is no direct way to open a database from the mounted state using srvctl, we instruct
# the user to 1) shutdown the peer instances and then 2) start the database (which will 
# start only the inactive instances).  
#
else if [ "$6" = "primary" ]; then
  # Variable for instruction number
  i=0

  # Get a list of the peer instances
  get_instance_peers $1 $2 $3 $4 $5
  l_drp_instcnt=$l_gip_val
  l_drp_instlst="$l_gip_lst"

  # Display a message specific to one or more active peer instances
  if [ "$l_drp_instcnt" -gt "0" ]; then
    display_raw "\nNOTE: Database $4 has completed the switchover to the primary role, but"
    display_raw "      instance $5 is the only open instance.  For increased availability,"
    display_raw "      Oracle recommends opening the remaining active instances which are "
    display_raw "      currently in mounted mode by performing the following steps:\n"
    i=`expr $i + 1`
    display_raw "        $i) Shutdown all instances other than instance $5."
    display_raw "        eg: srvctl stop instance -d $4 -i $l_drp_instlst\n"
  else
    # Display a message specific to no active peer instances
    display_raw "\nNOTE: Database $4 has completed the switchover to the primary role, but"
    display_raw "      instance $5 is the only open instance.  For increased availability,"
    display_raw "      Oracle recommends opening all instances in the RAC by performing the"
    display_raw "      following step:\n"
  fi

  i=`expr $i + 1`
  display_raw "        $i) Startup and open all inactive instances for database $4."
  display_raw "        eg: srvctl start database -d $4"

#
# $6: physical
#
# In this state, db2 has switched back to a physical standby role from the primary role.
# Unlike the physical to primary switchover, in order to switchover the primary was 
# required to be reduced to a single instance.
#
else if [ "$6" = "physical" ]; then
  display_raw "\nNOTE: Database $4 is no longer limited to single instance operation since"
  display_raw "      it has completed the switchover to the physical standby role.  For "
  display_raw "      increased  availability, Oracle recommends starting the inactive "
  display_raw "      instances in the RAC by performing the following step:\n"

  display_raw "        1) Startup and mount inactive instances for database $4"
  display_raw "        eg: srvctl start database -d $4 -o mount"

fi
fi
fi
fi
fi
}

###############################################################################
# NAME:        display_raw
#
# DESCRIPTION: 
#   Similar to the display routine but without timestamp or stage (just echo)
# 
# INPUT(S):
#   Arguments:
#     $1: message to display
#
#   Globals:
#     $suppress $LOG_PHYSRU_ENABLED $LOG_PHYSRU_FILE
#
# RETURN:
#   None
#
###############################################################################
display_raw()
{
if [ "$suppress" -eq "1" ]; then
  return 0
else
  if [ "$suppresst" -eq "0" ]; then
    echo -e "$1"
  fi
  if [ "$suppressl" -eq "0" ]; then
    if [ "$LOG_PHYSRU_ENABLED" -eq "1" ]; then
      echo -e "$1" >> $LOG_PHYSRU_FILE
    fi
  fi
  return 0
fi
}

###############################################################################
# NAME:        display_stage
#
# DESCRIPTION: 
#   Similar to the display routine but unique to displaying the stage which
#   contains a banner.  This routine is unlike the other display routines as
#   it only produces output when task == 1.  This is to avoid multiple messages
#   since a stage routine may be re-entered numerous times if there are 
#   failures during this script.
#
# INPUT(S):
#   Arguments:
#     $1: message describing stage
#
#   Globals:
#     $stage $task $suppress $LOG_PHYSRU_ENABLED $LOG_PHYSRU_FILE
#
# RETURN:
#   None
#
###############################################################################
display_stage()
{
if [ "$suppress" -eq "1" ]; then
  return 0
else
  # Only produce stage header if first time entered
  if [ "$task" -eq "1" ]; then
    if [ "$suppresst" -eq "0" ]; then
      echo -e "\n### Stage $stage: $1"
    fi
    if [ "$suppressl" -eq "0" ]; then
      if [ "$LOG_PHYSRU_ENABLED" -eq "1" ]; then
        echo -e "\n### Stage $stage: $1" >> $LOG_PHYSRU_FILE
      fi
    fi
  fi
fi
}

###############################################################################
# NAME:        display_stats
#
# DESCRIPTION: 
#   Displays rolling upgrade statistics upon successful rolling upgrade.  This
#   routine works by performing date/time arithmetic on the flashback times 
#   associated with each of the flashback restore points created by the 
#   checkpoint routine.  This routine is heavily dependent on the assumptions
#   it makes about what event occurs for a given [stage-task].
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name of original physical standby
#     $4: database unique name of original physical standby
#
#   Globals:
#     $RPFX
#
# RETURN:
#   None
#
###############################################################################
display_stats()
{
# 
# script start time
#
get_flashback_time $1 $2 $3 $4 "${RPFX}_0000_${VERSION}"
l_ds_sst=$l_gft_val
display_raw "script start time:                                           $l_ds_sst"

# 
# script finish time
#
get_flashback_time $1 $2 $3 $4 "${RPFX}_0707"
l_ds_sft=$l_gft_val
display_raw "script finish time:                                          $l_ds_sft"

# 
# total script execution time
#
get_interval_time $1 $2 $3 "$l_ds_sft" "$l_ds_sst"
l_ds_set=$l_git_val
display_raw "total script execution time:                                       $l_ds_set"

# 
# user upgrade time
#
get_flashback_time $1 $2 $3 $4 "${RPFX}_0204"
l_ds_uut1=$l_gft_val
get_flashback_time $1 $2 $3 $4 "${RPFX}_0301"
l_ds_uut2=$l_gft_val
get_interval_time $1 $2 $3 "$l_ds_uut2" "$l_ds_uut1"
l_ds_uut=$l_git_val
display_raw "wait time for user upgrade:                                        $l_ds_uut"

#
# user startup former primary as physical on new binary wait time
#

# 
# active script execution time
#
l_ds_ase_sql="set pagesize 0 feedback off verify off heading off echo off tab off 
whenever sqlerror exit sql.sqlcode 
select cast((to_dsinterval('$l_ds_set') - to_dsinterval('$l_ds_uut')) 
as interval day(2) to second(0)) from dual; 
exit;"
sql_exec $1 $2 $3 "$l_ds_ase_sql"
chkerr $? "failed to calculate active script time"
l_ds_ase=`echo $sql_out`
display_raw "active script execution time:                                      $l_ds_ase"

# 
# logical instantiation start time
#
get_flashback_time $1 $2 $3 $4 "${RPFX}_0201"
l_ds_lis=$l_gft_val
display_raw "transient logical creation start time:                       $l_ds_lis"

# 
# logical instantiation finish time
#
get_flashback_time $1 $2 $3 $4 "${RPFX}_0202"
l_ds_lif=$l_gft_val
display_raw "transient logical creation finish time:                      $l_ds_lif"

# 
# primary switchover to logical start time
#
get_flashback_time $1 $2 $3 $4 "${RPFX}_0401"
l_ds_pls=$l_gft_val
display_raw "primary to logical switchover start time:                    $l_ds_pls"

# 
# logical switchover to primary finish time
#
get_flashback_time $1 $2 $3 $4 "${RPFX}_0404"
l_ds_lpf=$l_gft_val
display_raw "logical to primary switchover finish time:                   $l_ds_lpf"

#
# total time primary services were offline
#
get_interval_time $1 $2 $3 "$l_ds_lpf" "$l_ds_pls"
l_ds_pso=$l_git_val
display_raw "primary services offline for:                                      $l_ds_pso"

#
# total time former primary was a physical standby
#
get_flashback_time $1 $2 $3 $4 "${RPFX}_0504"
l_ds_fpp1=$l_gft_val
get_flashback_time $1 $2 $3 $4 "${RPFX}_0701"
l_ds_fpp2=$l_gft_val
get_interval_time $1 $2 $3 "$l_ds_fpp2" "$l_ds_fpp1"
l_ds_fpp=$l_git_val
display_raw "total time former primary in physical role:                        $l_ds_fpp"

#
# time to reach upgrade redo
#
get_flashback_time $1 $2 $3 $4 "${RPFX}_0601"
l_ds_bfp1=$l_gft_val
get_flashback_time $1 $2 $3 $4 "${RPFX}_0602"
l_ds_bfp2=$l_gft_val
get_interval_time $1 $2 $3 "$l_ds_bfp2" "$l_ds_bfp1"
l_ds_bfp=$l_git_val
display_raw "time to reach upgrade redo:                                        $l_ds_bfp"

#
# time to recover through upgrade redo
#
get_flashback_time $1 $2 $3 $4 "${RPFX}_0602"
l_ds_rtu1=$l_gft_val
get_flashback_time $1 $2 $3 $4 "${RPFX}_0603"
l_ds_rtu2=$l_gft_val
get_interval_time $1 $2 $3 "$l_ds_rtu2" "$l_ds_rtu1"
l_ds_rtu=$l_git_val
display_raw "time to recover upgrade redo:                                      $l_ds_rtu"

#
# no more stats if the final switchover wasn't performed
#
get_flashback_time $1 $2 $3 $4 "${RPFX}_0705"
l_ds_ppf=$l_gft_val
if [ "$l_ds_ppf" = "" ]; then
  return 0
fi

# 
# primary switchover to physical start time
#
get_flashback_time $1 $2 $3 $4 "${RPFX}_0701"
l_ds_pps=$l_gft_val
display_raw "primary to physical switchover start time:                   $l_ds_pps"

#
# physical switchover to primary finish time
#
display_raw "physical to primary switchover finish time:                  $l_ds_ppf"

#
# total time primary services were offline
#
get_interval_time $1 $2 $3 "$l_ds_ppf" "$l_ds_pps"
l_ds_pso2=$l_git_val
display_raw "primary services offline for:                                      $l_ds_pso2"
}

###############################################################################
# NAME:        display_usage
#
# DESCRIPTION: 
#   Displays usage description for physru
#
# INPUT(S):
#   Arguments:
#     None
#
#   Globals:
#     None
#
# RETURN:
#   None
#
###############################################################################
display_usage()
{
echo -e "\nUsage: physru <username> <primary_tns> <standby_tns>"
echo -e "              <primary_name> <standby_name> <upgrade_version>"
echo -e "\nPurpose:"
echo -e "  Perform a rolling upgrade between a primary and physical standby database.\n"
echo -e "  This script simplifies a physical standby rolling upgrade.  While numerous"
echo -e "  steps have been automated, this script must be called at least three times "
echo -e "  in order to complete a rolling upgrade.  When this script reaches a point"
echo -e "  where user intervention is required, it outputs a message indicating what"
echo -e "  is expected of the user.  Once the user action is complete, this script can "
echo -e "  be called to resume the rolling upgrade.  In the event of an error, a user"
echo -e "  can take corrective action, and simply call this script again to resume the"
echo -e "  rolling upgrade.  In the event one wishes to abandon the rolling upgrade, and"
echo -e "  revert the configuration back to its pre-upgrade state, this script creates "
echo -e "  guaranteed flashback database restore points on both the primary and standby"
echo -e "  databases, and backs up each databases' associated control file.  The names "
echo -e "  of the restore points and backup control files are output to the console and"
echo -e "  logfile when they are initially created.\n"
echo -e "  When this script is called, it assumes all databases to be either mounted or "
echo -e "  open.  It requires flashback database to be enabled on both the primary and "
echo -e "  standby instances.  RAC configurations are permitted but there is limited "
echo -e "  automation provided by the script.  At specific points it may become "
echo -e "  necessary to manually shutdown/startup instances and change init.ora "
echo -e "  parameter values.  When appropriate, the script will output when these "
echo -e "  requirements are expected of the user.  RAC configurations are also required"
echo -e "  to define static tns services since this script expects a given tns service"
echo -e "  name to contact the same instance on successive calls."
echo -e "\nArguments:"
echo -e "  <username>        = dba username"
echo -e "  <primary_tns>     = tns service name to primary"
echo -e "  <standby_tns>     = tns service name to physical standby"
echo -e "  <primary_name>    = db_unique_name of primary"
echo -e "  <standby_name>    = db_unique_name of standby"
echo -e "  <upgrade_version> = target rdbms version"
echo -e "\nExample:"
echo -e "  physru sys hq_tnspri hq_tnsstb hq_primary hq_standby 11.2.0.2.0"
echo -e "\n  NOTE: This script performs role transitions, and it is not necessary to "
echo -e "        adjust the tns and db name arguments to their respective database roles"
echo -e "        on successive calls.  That is, the arguments must remain the same from"
echo -e "        first-invocation to completion."
}

###############################################################################
# NAME:        sql_comp
#
# DESCRIPTION: Uses SQL to compare $4 and $6 given operator in $5.
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: num1
#     $5: operator = { < > <= >= != }
#     $6: num2
#
#   Globals:
#     None
#
# RETURN:
#   l_comp_val: 0 if ($4 $5 $6) expression is true and 1 otherwise
#
###############################################################################
sql_comp() 
{
l_comp_sql="  set pagesize 0 feedback off verify off heading off echo off tab off 
whenever sqlerror exit sql.sqlcode 
select case when (${4} ${5} ${6}) then 0 else 1 end from dual;
exit;"
sql_exec $1 $2 $3 "$l_comp_sql"
l_comp_val=`echo $sql_out | awk '{print int(\$1)}'`
return $l_comp_val
}

###############################################################################
# NAME:        sql_gt/sql_lt/sql_eq
#
# DESCRIPTION: Uses sql_comp to perform the associated (gt == greater than,
#              lt == less than, eq == equals) comparison between $4 and $5.
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: num1
#     $5: num2
#
#   Globals:
#     None
#
# RETURN:
#   l_gt/lt/eq_val: 0 if true and 1 otherwise
#
###############################################################################
sql_gt() 
{
sql_comp $1 $2 $3 $4 ">" $5
l_gt_val=$?
return $l_gt_val
}

sql_lt()
{
sql_comp $1 $2 $3 $4 "<" $5
l_lt_val=$?
return $l_lt_val
}

sql_eq()
{
sql_comp $1 $2 $3 $4 "=" $5
l_eq_val=$?
return $l_eq_val
}

###############################################################################
# NAME:        sql_eval
#
# DESCRIPTION: 
#   Evaluate an integer expression via SQL.  At various times this script needs to
#   perform arithmetic on SCNs which are larger than 32bits.  For this reason, the
#   script passes expression to the database to perform the arithmetic.  The 
#   resultant value is returned as a string.  The results are always truncated.
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#     $5: expression 
#
#   Globals:
#     None
#
# RETURN:
#   l_se_val:  result as a string
#
###############################################################################
sql_eval() {
l_se_sql="  set pagesize 0 feedback off verify off heading off echo off tab off 
whenever sqlerror exit sql.sqlcode 
select trunc(${5}) from dual;
exit;"
sql_exec $1 $2 $3 "$l_se_sql"
chkerr $? "failed to evaluate expression on database $4"
l_se_val=`echo $sql_out | awk '{print \$1}'`
}


###############################################################################
# NAME:        fail
#
# DESCRIPTION: 
#   Display $1 as error message and exit with error status
#
# INPUT(S):
#   Arguments:
#     $1: error message
#
#   Globals:
#     None
# RETURN:
#   None
#
###############################################################################
fail()
{
  errormsg="ERROR: $1"
  display "$errormsg"
  exit 1
}

###############################################################################
# NAME:        flashback_database
#
# DESCRIPTION: 
#   Flashback database to named restore point $5
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#     $5: restore point name
#
#   Globals:
#     None
#
# RETURN:
#   None
#
###############################################################################
flashback_database()
{
display "flashing back database $4 to restore point $5"
l_fd_sql="set pagesize 0 feedback off verify off heading off echo off tab off 
whenever sqlerror exit sql.sqlcode 
flashback database to restore point $5; 
exit;"
sql_exec $1 $2 $3 "$l_fd_sql"
chkerr $? "failed to flashback to restore point $5 on database $4"
}

###############################################################################
# NAME:        get_applied_scn
#
# DESCRIPTION: 
#   Get the last applied scn of the LSP.
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#
#   Globals:
#     None
#
# RETURN:
#   l_gas_val: scn of last applied redo as string
#
###############################################################################
get_applied_scn() {
l_gas_sql="  set pagesize 0 feedback off verify off heading off echo off tab off numwidth 20 
  whenever sqlerror exit sql.sqlcode 
  select nvl(applied_scn, 0) from v\$logstdby_progress;
  exit;"
sql_exec $1 $2 $3 "$l_gas_sql"
chkerr $? "failed to query last applied scn by logical standby on database $4"
l_gas_val=`echo $sql_out | awk '{print \$1}'`
}

###############################################################################
# NAME:        get_db_unique_name
#
# DESCRIPTION: 
#   Gets the db_unique_name for the database.  If one exists, the name is returned
#   in l_dun_val, and 0 is returned from this routine.  A 0 is returned if a 
#   db_unique_name does not exist.
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name (passed to script)
#
#   Globals:
#     None
#
# RETURN:
#   0: db_unique_name was found, l_dun_val: db_unique_name
#   1: db_unique_name not found
#
###############################################################################
get_db_unique_name() {
l_dun2_sql="set pagesize 0 feedback off verify off heading off echo off tab off 
whenever sqlerror exit sql.sqlcode 
select count(db_unique_name) from v\$database; 
exit;" 
sql_exec $1 $2 $3 "$l_dun2_sql"
chkerr $? "failed to query db_unique_name from database $4"
l_dun2_val=`echo $sql_out`
if [ "$l_dun2_val" -eq "0" ]; then
  return 1
else
  l_dun_sql="  set pagesize 0 feedback off verify off heading off echo off tab off
  whenever sqlerror exit sql.sqlcode
  select db_unique_name from v\$database;
  exit;"
  sql_exec $1 $2 $3 "$l_dun_sql"
  chkerr $? "failed to query db_unique_name from database $4"
  l_dun_val=`echo $sql_out`
  return 0
fi
}

###############################################################################
# NAME:        get_primary_scn
#
# DESCRIPTION: 
#   Get the current scn on the specified database.  The current scn is the 
#   value obtained from v$database.current_scn.  This procedure is currently 
#   used to obtain a starting point on the primary from which to measure the 
#   time until the redo is recovered or applied.
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#
#   Globals:
#     None
#
# RETURN:
#   l_gps_val:  scn as string
#
###############################################################################
get_primary_scn() {
l_gps_sql="  set pagesize 0 feedback off verify off heading off echo off tab off numwidth 20 
whenever sqlerror exit sql.sqlcode 
select nvl(current_scn,0) from v\$database;
exit;"
sql_exec $1 $2 $3 "$l_gps_sql"
chkerr $? "failed to query current scn on database $4"
l_gps_val=`echo $sql_out | awk '{print \$1}'`
}

###############################################################################
# NAME:        get_flashback_restore_count
# DESCRIPTION: 
#   Get the total number of flashback restore point entries on the specified
#   database.  The maximum number Oracle supports is 2048 so we need to ensure
#   there are enough free entries for this script's use.  
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#
#   Globals:
#     None
#
# RETURN:
#   l_gfr_val: no. of existing restore point entries
#
###############################################################################
get_flashback_restore_count() {
l_gfr_sql="set pagesize 0 feedback off verify off heading off echo off tab off 
whenever sqlerror exit sql.sqlcode 
select count(1) from v\$restore_point; 
exit;"
sql_exec $1 $2 $3 "$l_gfr_sql"
chkerr $? "failed to query total number of flashback restore points on database $4" 
l_gfr_val=`echo $sql_out`
}

###############################################################################
# NAME:        get_flashback_scn
#
# DESCRIPTION: 
#   Get the scn associated with a flashback restore point.
#
# INPUT(S):
#   $1: database user
#   $2: user password
#   $3: tns service name
#   $4: database unique name
#   $5: restore point name
#
# RETURN:
#   l_gfs_val: scn value associated with restore point $5
#
###############################################################################
get_flashback_scn() {
l_gfs_sql="set pagesize 0 feedback off verify off heading off echo off tab off numwidth 20 
whenever sqlerror exit sql.sqlcode 
select nvl(max(scn),0) from v\$restore_point where name = '$5'; 
exit;"
sql_exec $1 $2 $3 "$l_gfs_sql"
chkerr $? "failed to query flashback scn of restore point $5 on database $4"
l_gfs_val=`echo $sql_out | awk '{print \$1}'`
}

###############################################################################
# NAME:        get_flashback_time
#
# DESCRIPTION: 
#  Get the time associated with a flashback restore point.
#
# INPUT(S):
#   $1: database user
#   $2: user password
#   $3: tns service name
#   $4: database unique name
#   $5: restore point name
#
# RETURN:
#   l_gft_val: time associated with restore point $5
#
###############################################################################
get_flashback_time() {
l_gft_sql="set pagesize 0 feedback off verify off heading off echo off tab off 
whenever sqlerror exit sql.sqlcode 
select to_char(time, 'DD-Mon-RR HH24:MI:SS') from v\$restore_point where name = '$5'; 
exit;"
sql_exec $1 $2 $3 "$l_gft_sql"
chkerr $? "failed to query flashback time of restore point $5 on database $4"
l_gft_val=`echo $sql_out`
}

###############################################################################
# NAME:        get_instance_id
#
# DESCRIPTION: 
#   Gets the instance id from the instance specified at $3.
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#
#   Globals:
#     None
#
# RETURN:
#   l_gii_val: instance_number from v$instance
#
###############################################################################
get_instance_id()
{
l_gii_sql="set pagesize 0 feedback off verify off heading off echo off tab off 
whenever sqlerror exit sql.sqlcode 
select instance_number from v\$instance;
exit;" 
sql_exec $1 $2 $3 "$l_gii_sql"
chkerr $? "failed to query instance_number from database $4"
l_gii_val=`echo $sql_out`
}

###############################################################################
# NAME:        get_instance_name
#
# DESCRIPTION: 
#   Gets the instance name from the specified database.
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#
#   Globals:
#     None
#
# RETURN:
#   l_gin_val: instance_name from v$instance
#
###############################################################################
get_instance_name()
{
l_gin_sql="set pagesize 0 feedback off verify off heading off echo off tab off 
whenever sqlerror exit sql.sqlcode 
select instance_name from v\$instance;
exit;" 
sql_exec $1 $2 $3 "$l_gin_sql"
chkerr $? "failed to query instance_name from database $4"
l_gin_val=`echo $sql_out`
}

###############################################################################
# NAME:        get_instance_peers
#
# DESCRIPTION: 
#   Gets a comma delimited list of instances that are peers with instance $5 
#   which is supplied to this routine.  This routine assumes that the specified 
#   database has already been verified to be a RAC.
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#     $5: instance name
#
#   Globals:
#     None
#
# RETURN:
#   l_gip_val: # of instance peers in $l_gip_lst
#   l_gip_lst: comma delimited list of instances that are peers with $5
#
#select instance_name from gv\$instance where instance_name != '$5';
###############################################################################
get_instance_peers()
{
l_gip_sql="set pagesize 0 feedback off verify off heading off echo off tab off 
whenever sqlerror exit sql.sqlcode 
select instance_name from gv\$instance where instance_name != '$5' 
order by instance_number;
exit;" 
sql_exec $1 $2 $3 "$l_gip_sql"
chkerr $? "failed to query active instances for database $4"
l_gip_lst=`echo $sql_out | tr '\n' ' '`
l_gip_lst=`echo $l_gip_lst`
l_gip_val=`echo $l_gip_lst | wc -w`
l_gip_lst=`echo $l_gip_lst | tr ' ' ','`
}

###############################################################################
# NAME:        get_interval_time
#
# DESCRIPTION: 
#   Return $4 - $5 as a day to second interval
#
# INPUT(S):
#   $1: database user
#   $2: user password
#   $3: tns service name
#   $4: timestamp 1
#   $5: timestamp 2
#
# RETURN:
#   l_git_val: difference between $4 and $5
#
###############################################################################
get_interval_time() 
{
l_git_sql="set pagesize 0 feedback off verify off heading off echo off tab off 
whenever sqlerror exit sql.sqlcode 
select cast((to_timestamp('$4', 'DD-Mon-RR HH24:MI:SS') 
- to_timestamp('$5', 'DD-Mon-RR HH24:MI:SS')) 
as interval day(2) to second(0)) from dual;
exit;"
sql_exec $1 $2 $3 "$l_git_sql"
chkerr $? "failed to calculate interval between $4 and $5"
l_git_val=`echo $sql_out`
}

###############################################################################
# NAME:        get_protection_mode
#
# DESCRIPTION: 
#   Get database protection mode for the specified database.
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#
#   Globals:
#     None
#
# RETURN:
#   l_gpm_val: value of protection_mode from v$database
#
###############################################################################
get_protection_mode() {
l_gpm_sql="set pagesize 0 feedback off verify off heading off echo off tab off 
whenever sqlerror exit sql.sqlcode 
select protection_mode from v\$database; 
exit;"
sql_exec $1 $2 $3 "$l_gpm_sql"
chkerr $? "failed to query database protection mode on database $4"
l_gpm_val=$sql_out
}

###############################################################################
# NAME:        get_rdbms_version
#
# DESCRIPTION: 
#   Get the software version of the Oracle RDBMS
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#
#   Globals:
#     None
#
# RETURN:
#   l_grv_val: version from v$instance
# 
###############################################################################
get_rdbms_version() {
l_grv_sql="set pagesize 0 feedback off verify off heading off echo off tab off
whenever sqlerror exit sql.sqlcode 
select version from v\$instance; 
exit;"
sql_exec $1 $2 $3 "$l_grv_sql"
chkerr $? "failed to query rdbms version on database $4"
l_grv_val=`echo $sql_out`
}

###############################################################################
# NAME:        get_recovery_scn
#
# DESCRIPTION: 
#   Get the last applied scn of the MRP.  If the v$recovery_progress view has
#   not been initialized, the scn is returned as 0.  This query varies 
#   depending on database version.  In 11.1, the scn is displayed in the SOFAR
#   column while in 11.2, the scn must be parsed out of the COMMENTS column.
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#     $5: database version
#
#   Globals:
#     None
#
# RETURN:
#   l_grs_val: scn of last applied redo as a string
#
###############################################################################
get_recovery_scn() {

if [ "$5" = "11.1" ]; then
  l_grs_sql="  set pagesize 0 feedback off verify off heading off echo off tab off numwidth 20
  whenever sqlerror exit sql.sqlcode 
  select to_number(nvl(max(sofar),0)) from v\$recovery_progress 
  where item = 'Last Applied Redo' and timestamp = (select max(timestamp) from 
  v\$recovery_progress where item = 'Last Applied Redo'); 
  exit;"
else
  l_grs_sql="  set pagesize 0 feedback off verify off heading off echo off tab off numwidth 20
  whenever sqlerror exit sql.sqlcode 
  select to_number(nvl(substr(max(comments), 6), 0)) from v\$recovery_progress 
  where item = 'Last Applied Redo' and timestamp = (select max(timestamp) from 
  v\$recovery_progress where item = 'Last Applied Redo'); 
  exit;"
fi

sql_exec $1 $2 $3 "$l_grs_sql"
chkerr $? "failed to query last applied scn by media recovery on database $4"

l_grs_val=`echo $sql_out | awk '{print $1}'`
if [ "$PHYSRU_DEBUG" = "1" ]; then
  display "DEBUG: get_recovery_scn() - aft ($l_grs_val) bef ($sql_out)"
fi
}

###############################################################################
# NAME:        get_resume_state
#
# DESCRIPTION: 
#   Get the stage and task values which identifies the last completed operation.
#   These values are parsed from the restore point name composed in the 
#   checkpoint routine.
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#
#   Globals:
#     $RPFX
#
# RETURN:
#   l_grs2_stage: stage # from most recent checkpoint restore point
#   l_grs2_task:  task  # from most recent checkpoint restore point
# 
###############################################################################
get_resume_state() {
l_grs2_sql="set pagesize 0 feedback off verify off heading off echo off tab off 
whenever sqlerror exit sql.sqlcode 
select nvl(substr(max(name), length('${RPFX}')+2, length('0000')), '0000') 
from v\$restore_point where time = (select max(time) from v\$restore_point 
where name like '${RPFX}_%'); 
exit;"
sql_exec $1 $2 $3 "$l_grs2_sql"
chkerr $? "failed to query script resume state on datbase $4"
l_grs2_stage=`echo $sql_out | cut -b 1-2`
l_grs2_task=`echo $sql_out | cut -b 3-4`
}

###############################################################################
# NAME:        get_resume_version
#
# DESCRIPTION: 
#   Get the script version # from the oldest script-related restore point on
#   the specified database.  This query assumes we adhere to a naming 
#   convention for the initial restore point which is as follows:
# 
#     <restore-point-prefix>_0000_<4-digit version#> (eg: PRU_0000_0001)
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#
#   Globals:
#     $RPFX
#
# RETURN:
#   l_grv_val: version string from the oldest checkpoint restore point
# 
###############################################################################
get_resume_version() {
l_grv_sql="set pagesize 0 feedback off verify off heading off echo off tab off 
whenever sqlerror exit sql.sqlcode 
select nvl(substr(max(name), -4), '0000') from v\$restore_point where 
name like '${RPFX}_0000_%';
exit;"
sql_exec $1 $2 $3 "$l_grv_sql"
chkerr $? "failed to query script resume version on database $4"
l_grv_val=$sql_out
}

###############################################################################
# NAME:        inthandler
#
# DESCRIPTION: 
#   This routine traps SIGINTs during the script.  The only current use for
#   the handler is to restore the tty back to its original state.
#
# INPUT(S):
#   Arguments:
#     None
#
#   Globals:
#     $orig_stty
#
# RETURN:
#   None
# 
###############################################################################
inthandler()
{
stty $origstty
exit 1
}

###############################################################################
# NAME:        is_database_role
#
# DESCRIPTION: 
#   Check if the database_role in v$database for the specified database
#   matches $5.  If it matches, a 1 is returned, and 0 otherwise.
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#     $5: database role string (eg: PRIMARY, LOGICAL STANDBY, PHYSICAL STANDBY)
#
#   Globals:
#     None
#
# RETURN:
#    0: database role does not match
#    1: database role matches
#
###############################################################################
is_database_role() {
l_idr_sql="set pagesize 0 feedback off verify off heading off echo off tab off 
whenever sqlerror exit sql.sqlcode 
select count(1) from v\$database where database_role='$5'; 
exit;"
sql_exec $1 $2 $3 "$l_idr_sql"
chkerr $? "failed to verify database role of $4 is $5"
l_idr_val=`echo $sql_out`
return $l_idr_val
}

###############################################################################
# NAME:        is_dg_enabled
#
# DESCRIPTION: 
#   Check if the specified database has an enabled DG Broker.  This routine 
#   returns a 1 if the check succeeds, and 0 otherwise.
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#
# RETURN:
#    0: DG Broker is disabled
#    1: DG Broker is enabled
#
###############################################################################
is_dg_enabled() {
l_ide_sql="set pagesize 0 feedback off verify off heading off echo off tab off 
whenever sqlerror exit sql.sqlcode 
select count(1) from v\$parameter where name='dg_broker_start' and value='TRUE'; 
exit;"
sql_exec $1 $2 $3 "$l_ide_sql"
chkerr $? "failed to query DG_BROKER_START parameter on database $4"
l_ide_val=`echo $sql_out`
return $l_ide_val
}

###############################################################################
# NAME:        is_flashback_enabled
#
# DESCRIPTION: 
#   Check if flashback database is enabled on the specified database.  If
#   flashback is enabled, a 1 is returned, and 0 otherwise.
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#
#   Globals:
#     None
#
# RETURN:
#   0: flashback is not enabled
#   1: flashback is enabled
#
###############################################################################
is_flashback_enabled() {
l_ife_sql="set pagesize 0 feedback off verify off heading off echo off tab off 
whenever sqlerror exit sql.sqlcode 
select count(1) from v\$database where flashback_on = 'YES' or 
flashback_on = 'RESTORE POINT ONLY'; 
exit;"
sql_exec $1 $2 $3 "$l_ife_sql"
chkerr $? "failed to query flashback-enable state on database $4"
l_ife_val=`echo $sql_out`
return $l_ife_val
}

###############################################################################
# NAME:        is_lsp_running
#
# DESCRIPTION: 
#   Check if logical standby apply is running.  If running, the instance id is
#   on which it is running is returned.  If not running, a 0 is returned.
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#
#   Globals:
#     None
#
# RETURN:
#   0: lsp0 is not running on any instance
#   N: the instance id on which the lsp0 is running
#
###############################################################################
is_lsp_running() {
l_ilr_sql="set pagesize 0 feedback off verify off heading off echo off tab off 
whenever sqlerror exit sql.sqlcode 
select count(1) from v\$logstdby_state where state != 'SQL APPLY NOT ON'; 
exit;"
sql_exec $1 $2 $3 "$l_ilr_sql"
chkerr $? "failed to query logical standby apply run state on database $4"
l_ilr_val=`echo $sql_out`
return $l_ilr_val
}

###############################################################################
# NAME:        is_mrp_running
#
# DESCRIPTION: 
#   Check if media recovery is running on any instance in the specified 
#   database.  If running, the instance id on which it is running is returned.
#   If not running, a 0 is returned.
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#
#   Globals:
#     None
#
# RETURN:
#   0: mrp is not running on any instance
#   N: the instance id on which the mrp is running
#
###############################################################################
is_mrp_running() {
l_imr_sql="set pagesize 0 feedback off verify off heading off echo off tab off 
whenever sqlerror exit sql.sqlcode 
select nvl(max(inst_id),0) from gv\$managed_standby where process='MRP0'; 
exit;" 
sql_exec $1 $2 $3 "$l_imr_sql" 
chkerr $? "failed to query media recovery run state on database $4" 
l_imr_val=`echo $sql_out`
return $l_imr_val
}

###############################################################################
# NAME:        is_rac_database
#
# DESCRIPTION: 
#   Check if the specified instance is a RAC database.  This routine returns a 1 
#   if the instance is in a RAC, and 0 otherwise.
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#
# RETURN:
#    0: instance is in a RAC
#    1: instance is not in a RAC
#
###############################################################################
is_rac_database() {
l_ird_sql="set pagesize 0 feedback off verify off heading off echo off tab off 
whenever sqlerror exit sql.sqlcode 
select count(1) from v\$instance where PARALLEL='YES'; 
exit;"
sql_exec $1 $2 $3 "$l_ird_sql"
chkerr $? "failed to verify if database $4 is a RAC"
l_ird_val=`echo $sql_out`
return $l_ird_val
}

###############################################################################
# NAME:        is_open_mode
#
# DESCRIPTION: 
#   Check if the specified database is in an open mode matching $5.  Typically
#   the open_mode in v$database is compared against $5.  The exception to this
#   is 'OPEN MIGRATE' which is displayed in v$instance.  If the open mode
#   matches, a 1 is returned, and 0 otherwise.
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#     $5: open mode (eg: OPEN, MOUNTED, OPEN MIGRATE)
#
# RETURN:
#    0: open mode does not match
#    1: open mode matches
#
###############################################################################
is_open_mode() {
if [ "$5" = "OPEN MIGRATE" ]; then
  l_iom_sql="  set pagesize 0 feedback off verify off heading off echo off tab off 
  whenever sqlerror exit sql.sqlcode 
  select count(1) from v\$instance where status = '$5'; 
  exit;"
else
  l_iom_sql="  set pagesize 0 feedback off verify off heading off echo off tab off 
  whenever sqlerror exit sql.sqlcode 
  select count(1) from v\$database where open_mode='$5'; 
  exit;"
fi
sql_exec $1 $2 $3 "$l_iom_sql"
chkerr $? "failed to verify database $4 is in $5 mode"
l_iom_val=`echo $sql_out`
return $l_iom_val
}

###############################################################################
# NAME:        mount_database
#
# DESCRIPTION: 
#   Startup and mount the specified database.
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#
#   Globals:
#     None
#
# RETURN:
#   None
#
###############################################################################
mount_database()
{
display "mounting database $4"
l_md_sql=`sqlplus -L -s $1/$2@$3 as sysdba <<EOF
set pagesize 0 feedback off verify off heading off echo off tab off
whenever sqlerror exit sql.sqlcode
startup mount;
exit;
EOF > /dev/null`
chkerr $? "failed to mount database $4"
is_open_mode $1 $2 $3 $4 "MOUNTED"
if [ "$?" -eq "0" ]; then
  fail "$4 is not in MOUNTED mode"
fi
}

###############################################################################
# NAME:        open_database
#
# DESCRIPTION:
#   Opens the specified database.
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#
#   Globals:
#     None
#
# RETURN:
#   None
#
###############################################################################
open_database()
{
display "opening database $4"
l_od_sql=`sqlplus -s $1/$2@$3 as sysdba <<EOF 
set pagesize 0 feedback off verify off heading off echo off tab off 
whenever sqlerror exit sql.sqlcode
alter database open; 
exit; 
EOF > /dev/null`
chkerr $? "failed to open datdabase $4"
}

###############################################################################
# NAME:        purge_resume_state
# 
# DESCRIPTION:
#   Deletes all flashback restore points associated with this script on the 
#   specified database.
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#
#   Globals:
#     $RPFX
#
# RETURN:
#   None
#
###############################################################################
purge_resume_state() {
display "purging script execution state from database $4"
l_prs_sql="set pagesize 0 feedback off verify off heading off echo off tab off 
whenever sqlerror exit sql.sqlcode 
declare 
  cursor curs is 
    select name from v\$restore_point where name like '${RPFX}_%'; 
begin 
  for r_curs in curs loop 
    execute immediate 'drop restore point ' || r_curs.name; 
  end loop; 
end;
/
exit;"
sql_exec $1 $2 $3 "$l_prs_sql"
chkerr $? "failed to purge script state from database $4"
}

###############################################################################
# NAME:        recover_to_logical
#
# DESCRIPTION: 
#   Instantiates a transient logical standby from a physical standby.
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#
#   Globals:
#     None
#
# RETURN:
#   None
#
###############################################################################
recover_to_logical()
{
display "converting physical standby into transient logical standby"

l_rtl_sql="set pagesize 0 feedback off verify off heading off echo off tab off; 
whenever sqlerror exit sql.sqlcode 
alter database recover to logical standby keep identity; 
exit;"
sql_exec $1 $2 $3 "$l_rtl_sql"
chkerr $? "failed to convert database $4 into a transient logical standby"

is_database_role $1 $2 $3 $4 "LOGICAL STANDBY"
if [ "$?" -eq "0" ]; then
  fail "failed to convert database $4 into a transient logical standby"
fi
}

###############################################################################
# NAME:     minimize_apply_lag
#
# DESCRIPTION:
#   Wait for the 'apply lag' to fall below $5 seconds.  Rather than look at the
#   apply lag in v$dataguard_stats, this procedure will measure the time it 
#   takes the current scn at the primary to be processed by media recovery or
#   or the apply process, depending on the standby type.  If the time to apply 
#   the redo exceeds the specified threshold, this procedure will retry for up 
#   to $9 minutes, after which it will return an error.
#
# INPUT(S): 
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name to primary
#     $4: database unique name of primary
#     $5: tns service name to standby
#     $6: database unique name of standby
#     $7: database version of standby
#     $8: apply lag target in seconds
#     $9: timeout in minutes
#
#   Globals:
#     None
#
# RETURN:
#   None
#
###############################################################################
minimize_apply_lag()
{
# Don't perform the wait if on 11.1 (see 14174798)
if [ "$7" = "11.1" ]; then
  return 0
fi

display "waiting for apply lag to fall under $8 seconds"

# Determine the database role of the standby
is_database_role $1 $2 $5 $6 "PHYSICAL STANDBY"
if [ "$?" -eq "1" ]; then
  l_mal_dbtype="physical"
else
  is_database_role $1 $2 $5 $6 "LOGICAL STANDBY"
  if [ "$?" -eq "1" ]; then
    l_mal_dbtype="logical"
  else
    fail "database $6 is neither a physical nor logical standby"
  fi
fi

# Loop until within apply delay or timeout
l_mal_curtime=0
l_mal_maxtime=1
l_mal_reset=1
l_mal_status=1
while [ "$l_mal_status" -eq "1" ] && [ "$l_mal_curtime" -lt "$l_mal_maxtime" ]
do
  # Reset the timeouts
  if [ "$l_mal_reset" -eq "1" ]; then
    l_mal_curtime=`perl -e 'print int(time)'`
    l_mal_exptime=`expr $9 "*" 60`
    l_mal_engtime=`expr $l_mal_curtime + 60`
    l_mal_maxtime=`expr $l_mal_curtime + $l_mal_exptime`
    l_mal_reset=0
  fi

  # Grab the base time from which to measure the apply delay
  l_mal_basetime=`perl -e 'print int(time)'`

  # Grab the current scn associated with base time
  get_primary_scn $1 $2 $3 $4
  l_mal_basescn=$l_gps_val

  # Switch logs to ensure delivery to the standby
  switch_logs $1 $2 $3 $4

  # Loop until the base scn has been applied
  l_mal_pstscn="0"
  l_mal_curscn="0"
  while (sql_lt $1 $2 $5 "$l_mal_curscn" "$l_mal_basescn") && [ "$l_mal_curtime" -lt "$l_mal_maxtime" ]
  do
    # Get the last processed scn on the standby
    if [ "$l_mal_dbtype" = "logical" ]; then
      get_applied_scn $1 $2 $5 $6
      l_mal_curscn=$l_gas_val
    else
      get_recovery_scn $1 $2 $5 $6 $7
      l_mal_curscn=$l_grs_val
    fi

    # Grab the time associated with processed scn
    l_mal_curtime=`perl -e 'print int(time)'`

    # The base scn has been processed
    if (sql_lt $1 $2 $5 "$l_mal_basescn" "$l_mal_curscn"); then 

      # Calculate the apply lag
      l_mal_lag=`expr $l_mal_curtime - $l_mal_basetime`
      display "apply lag measured at ${l_mal_lag} seconds"

      # Success if it was applied within the delay
      if [ "$l_mal_lag" -le "$8" ]; then
        l_mal_status=0
      else
        # Reset the timeout and try again since we're making progress
        l_mal_reset=1
      fi
   
      # Break to the main loop to proceed or retry
      break
    fi

    # The processed scn has advanced from the last check
    if [ "$l_mal_pstscn" != "$l_mal_curscn" ]; then
      l_mal_pstscn=$l_mal_curscn
      l_mal_engtime=`expr $l_mal_curtime + 60`
    else
      # Check the engine status if the processed scn was stagnant for 60 seconds
      if [ "$l_mal_curtime" -gt "$l_mal_engtime" ]; then
        if [ "$l_mal_dbtype" = "logical" ]; then
          is_lsp_running $1 $2 $5 $6
          if [ "$?" -eq "0" ]; then
            fail "failed to find a running logical standby apply on $6"
          fi
        else
          is_mrp_running $1 $2 $5 $6
          if [ "$?" -eq "0" ]; then
            fail "failed to find a running media recovery process on $6"
          fi 
        fi

        # Reset the engine check time
        l_mal_engtime=`expr $l_mal_curtime + 60`
      fi
    fi 

    # Sleep and try again
    sleep $STB_VIEW_INIT_INTERVAL
  done
done

chkerr $l_mal_status "timed out after $9 minutes of inactivity"
}

###############################################################################
# NAME:        prompt 
# 
# DESCRIPTION: 
#   Displays the message supplied in $1 and returns the user input.  The $2
#   argument is a / delimited list of valid answers.
#
# INPUT(S):
#   Arguments:
#     $1: message to display to user
#     $2: valid answers list eg: y/n
#
#   Globals:
#     None
#
# RETURN:
#   l_p_val:  One of the values supplied in $2
#
###############################################################################
prompt()
{
# Create a space delimited list of valid answers
l_p_anslst=`echo $2 | tr '/' ' '`

# Create the full message text
l_p_msg="$1 ($2): "

while [ "1" ]
do
  # Write to logfile only since prompting writes to the terminal
  suppresst=1
  display_raw "$l_p_msg"
  suppresst=0

  l_p_val=""
  read -p "$l_p_msg" selection
  for validans in $l_p_anslst
  do
    if [ "$selection" = "$validans" ]; then
      l_p_val="$selection"
      display_raw ""
      return 0
    fi
  done
  
  display "not a valid option - '$selection'\n"
done
}

###############################################################################
# NAME:        set_rolling_upg_params
# 
# DESCRIPTION: 
#   Setup logical standby parameters suitable for physical rolling upgrade on
#   the specified database.
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#
#   Globals:
#     None
#
# RETURN:
#   None
#
###############################################################################
set_rolling_upgrade_params()
{
display "configuring transient logical standby parameters for rolling upgrade"
l_rup_sql="set pagesize 0 feedback off verify off heading off echo off tab off 
whenever sqlerror exit sql.sqlcode 
execute sys.dbms_logstdby.apply_set('LOG_AUTO_DELETE', 'FALSE'); 
execute sys.dbms_logstdby.apply_set('MAX_EVENTS_RECORDED', dbms_logstdby.max_events); 
execute sys.dbms_logstdby.apply_set('RECORD_UNSUPPORTED_OPERATIONS', 'TRUE'); 
execute sys.dbms_logstdby.apply_set('MAX_SERVERS', '15'); 
execute sys.dbms_logstdby.apply_set('MAX_SGA', '50'); 
exit;"
sql_exec $1 $2 $3 "$l_rup_sql"
chkerr $? "failed to configure logical standby for rolling upgrade"
}

###############################################################################
# NAME:        shutdown_database
#
# DESCRIPTION: 
#   Shutdown the specified database.
# 
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#
#   Globals:
#     None
#
# RETURN:
#   None
#
###############################################################################
shutdown_database() 
{
display "shutting down database $4"
l_sd_sql=`sqlplus -s $1/$2@$3 as sysdba <<EOF
set pagesize 0 feedback off verify off heading off echo off tab off 
shutdown immediate;
exit;
EOF > /dev/null`
}

###############################################################################
# NAME:        sql_exec
#
# DESCRIPTION: 
#   Execute a sql string via the supplied credentials and tns service.  The exit
#   code from sqlplus is returned from this routine.  Note that this return value
#   varies across platforms and should not be relied on beyond simple 
#   success/failure distinction.  The output from the sql script is stored in 
#   the sql_out global variable, and should not be modified in any way.  This
#   routine will also handle displaying the output and entire sql script should
#   a failure occur during execution.
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: sql string to execute
#
#   Globals:
#     sql_out:  raw output from sql script 
#
# RETURN:
#   status returned from sqlplus
#
###############################################################################
sql_exec()
{
# write sql string to temporary file
echo "$4" > $LOG_SQL_EXETMP

# execute sql
sql_out=`sqlplus -L -s $1/$2@$3 as sysdba @${LOG_SQL_EXETMP}`

# save sqlplus return value
l_se_ret=$?

# display offending sql code
if [ "$l_se_ret" -ne "0" ] && [ "$LOG_SQL_ERRORS" -eq "1" ]; then
  display_raw "\n### The following error was encountered:"
  display_raw "$sql_out"
  display_raw "\n### The offending sql code in its entirety:"
  display_raw "$4\n"
fi

return $l_se_ret
}

###############################################################################
# NAME:        start_logical_apply
#
# DESCRIPTION: 
#   Start logical standby apply on the specified database.  Since the START 
#   LOGICAL DDL returns immediately after spawning the LSP0 process, this 
#   routine waits until is_lsp_running can confirm the startup.  If logical 
#   standby is already running, this routine concludes success.
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#
#   Globals:
#     $LSP_START_INTERVAL $LSP_START_TIMEOUT 
#
# RETURN:
#   None
#
###############################################################################
start_logical_apply()
{
# check if logical needs to be started
is_lsp_running $1 $2 $3 $4
if [ "$?" -eq "0" ]; then

  # Start logical standby
  display "starting logical standby on database $4"
  l_sla_sql="  set pagesize 0 feedback off verify off heading off echo off tab off 
  whenever sqlerror exit sql.sqlcode 
  alter database start logical standby apply immediate; 
  exit;"
  sql_exec $1 $2 $3 "$l_sla_sql"
  chkerr $? "failed to start logical standby on database $4"

  # Confirm startup
  l_sla_status=1
  l_sla_curtime=`perl -e 'print int(time)'`
  l_sla_exptime=`expr $LSP_START_TIMEOUT "*" 60`
  l_sla_maxtime=`expr $l_sla_curtime + $l_sla_exptime`
  while [ "$l_sla_curtime" -lt "$l_sla_maxtime" ]
  do
    is_lsp_running $1 $2 $3 $4
    if [ "$?" -eq "1" ]; then
      l_sla_status=0
      break
    fi

    sleep $LSP_START_INTERVAL
    l_sla_curtime=`perl -e 'print int(time)'`
  done
  chkerr $l_sla_status "timed out after $LSP_START_TIMEOUT minutes of inactivity"
fi
}

###############################################################################
# NAME:        start_logical_build
#
# DESCRIPTION: 
#   Invokes dbms_logstdb.build on the specified database as required for 
#   logical standby instantiation.
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#
#   Globals:
#     None
#
# RETURN:
#   None
#
###############################################################################
start_logical_build()
{
display "executing dbms_logstdby.build on database $4"
l_slb_sql="set pagesize 0 feedback off verify off heading off echo off tab off 
whenever sqlerror exit sql.sqlcode 
execute dbms_logstdby.build; 
exit;"
sql_exec $1 $2 $3 "$l_slb_sql"
chkerr $? "failed to complete dbms_logstdby.build"
}

###############################################################################
# NAME:        start_media_recovery
#
# DESCRIPTION: 
#   This routine starts media recovery on the specified database.  If media 
#   recovery is already running, this routine concludes success.  The $5
#   argument allows for customized options to media recovery startup.  If not
#   specified it assumes a default.
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#     $5: recovery options (optional)
#
#   Globals:
#     $MRP_START_INTERVAL $MRP_START_TIMEOUT
#
# RETURN:
#   None
#
###############################################################################
start_media_recovery()
{
# check if media recovery needs to be started
is_mrp_running $1 $2 $3 $4
l_smr_inst=$?
if [ "$l_smr_inst" -eq "0" ]; then
  if [ "$5" ]; then
    l_smr_opt="$5"
  else
    l_smr_opt="using current logfile through next switchover disconnect"
  fi

  # start media recovery
  display "starting media recovery on $4"
  l_smr_sql="  set pagesize 0 feedback off verify off heading off echo off tab off 
  whenever sqlerror exit sql.sqlcode 
  alter database recover managed standby database ${l_smr_opt}; 
  exit;"
  sql_exec $1 $2 $3 "$l_smr_sql"
  chkerr $? "failed to start media recovery"

  # confirm the MRP has started
  wait_mrp_active $1 $2 $3 $4
else
  # ensure the MRP is running on the instance associated with the tns service name
  get_instance_id $1 $2 $3 $4
  if [ "$l_smr_inst" -ne "$l_gii_val" ]; then
    display "media recovery on database $4 is unexpectedly running on instance id $l_smr_inst"
    fail "restart media recovery on instance id $l_gii_val or supply a tns name to instance id $l_smr_inst"
  fi
fi
}

###############################################################################
# NAME:        stop_logical_apply
#
# DESCRIPTION: 
#   Stops logical standby apply on the specified database.  If apply is not
#   running, this routine concludes success.
#   
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#
#   Globals:
#     None
#
# RETURN:
#   None
#
###############################################################################
stop_logical_apply()
{
# check if logical needs to be stopped
is_lsp_running $1 $2 $3 $4
if [ "$?" -eq "1" ]; then

  # stop logical standby
  display "stopping logical standby on $4"
  l_sla_sql="  set pagesize 0 feedback off verify off heading off echo off tab off 
  whenever sqlerror exit sql.sqlcode 
  alter database stop logical standby apply; 
  exit;"
  sql_exec $1 $2 $3 "$l_sla_sql"
  chkerr $? "failed to stop logical standby apply"
fi
}

###############################################################################
# NAME:        stop_media_recovery
#
# DESCRIPTION: 
#   Stop media recovery on the specified database.  If media recovery is not 
#   running, this routine concludes success.
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#
#   Globals:
#     None
#
# RETURN:
#   None
#
###############################################################################
stop_media_recovery()
{
# check if media recovery needs to be stopped
is_mrp_running $1 $2 $3 $4
l_smr_inst=$?
if [ "$l_smr_inst" -gt "0" ]; then
  # ensure the MRP is running on the instance associated with the tns service name
  get_instance_id $1 $2 $3 $4
  if [ "$l_smr_inst" -ne "$l_gii_val" ]; then
    display "media recovery on database $4 is unexpectedly running on instance id $l_smr_inst"
    fail "restart media recovery on instance id $l_gii_val or supply a tns name to instance id $l_smr_inst"
  fi

  # stop media recovery
  display "stopping media recovery on $4"
  l_smr2_sql="  set pagesize 0 feedback off verify off heading off echo off tab off 
  whenever sqlerror exit sql.sqlcode 
  alter database recover managed standby database cancel; 
  exit;"
  sql_exec $1 $2 $3 "$l_smr2_sql"
  chkerr $? "failed to stop media recovery"
fi
}

###############################################################################
# NAME:        switch_logs
#
# DESCRIPTION: 
#   Switch logs on the database solely for the purpose of refreshing the 
#   connection status with the standby database.  
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#
#   Globals:
#     None
#
# RETURN:
#   None
#
###############################################################################
switch_logs()
{
l_sl_sql="  set pagesize 0 feedback off verify off heading off echo off tab off 
whenever sqlerror exit sql.sqlcode 
alter system switch logfile;
exit;"
sql_exec $1 $2 $3 "$l_sl_sql"
chkerr $? "failed to switch logfiles on database $4"
}

###############################################################################
# NAME:        switch_logical_to_primary
#
# DESCRIPTION: 
#   Switchover the specified logical standby database to the primary role.  If 
#   the database is already a primary, this routine concludes success.
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#
#   Globals:
#     None
#
# RETURN:
#   None
#
###############################################################################
switch_logical_to_primary()
{
# Assume success if db is already a primary
is_database_role $1 $2 $3 $4 "PRIMARY"
if [ "$?" -eq "1" ]; then
  display "$4 is already a primary"
  return 1
fi

# Ensure we're switching from a logical
is_database_role $1 $2 $3 $4 "LOGICAL STANDBY"
if [ "$?" -eq "0" ]; then
  fail "$4 is neither a primary nor logical standby database"
fi

# Switchover
display "switching $4 to become the new primary"
l_slp_sql="set pagesize 0 feedback off verify off heading off echo off tab off 
whenever sqlerror exit sql.sqlcode 
alter database commit to switchover to primary; 
exit;"
sql_exec $1 $2 $3 "$l_slp_sql"
chkerr $? "failed to switchover to primary"
display "$4 is now the new primary"
return 0
}

###############################################################################
# NAME:        switch_physical_to_primary
#
# DESCRIPTION: 
#   Switchover the specified physical standby database to the primary role.  If 
#   the database is already a primary, this routine concludes success.
# 
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#
#   Globals:
#     None
#
# RETURN:
#   None
#
###############################################################################
switch_physical_to_primary()
{
# Assume success if db is already a primary
is_database_role $1 $2 $3 $4 "PRIMARY"
if [ "$?" -eq "1" ]; then
  display "$4 is already a primary"
  return 1
fi

# Ensure we're switching from a physical
is_database_role $1 $2 $3 $4 "PHYSICAL STANDBY"
if [ "$?" -eq "0" ]; then
  fail "$4 is neither a primary nor physical standby database"
fi

# Switchover
display "switching $4 to become the new primary"
l_spp_sql="set pagesize 0 feedback off verify off heading off echo off tab off 
whenever sqlerror exit sql.sqlcode 
alter database commit to switchover to primary; 
exit;"
sql_exec $1 $2 $3 "$l_spp_sql"
chkerr $? "failed to switchover to primary"
display "$4 is now the new primary"
return 0
}


###############################################################################
# NAME:        switch_primary_to_logical
#
# DESCRIPTION: 
#   Switchover the specified primary database to a logical standby role.  If the
#   database is already a logical standby, this routine concludes success.
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#
#   Globals:
#     None
#
# RETURN:
#   None
#
###############################################################################
switch_primary_to_logical()
{
# Assume success if db is already a logical
is_database_role $1 $2 $3 $4 "LOGICAL STANDBY"
if [ "$?" -eq "1" ]; then
  display "$4 is already a logical standby"
  return 1
fi

# Ensure we're switching from a primary
is_database_role $1 $2 $3 $4 "PRIMARY"
if [ "$?" -eq "0" ]; then
  fail "$4 is neither a primary nor logical standby database"
fi

# Switchover
display "switching $4 to become a logical standby"
l_spl_sql="set pagesize 0 feedback off verify off heading off echo off tab off 
whenever sqlerror exit sql.sqlcode 
alter database commit to switchover to logical standby; 
exit;"
sql_exec $1 $2 $3 "$l_spl_sql"
chkerr $? "failed to switchover to logical standby"
display "$4 is now a logical standby"
return 0
}

###############################################################################
# NAME:        switch_primary_to_physical
#
# DESCRIPTION: 
#   Switchover the specified primary database to a physical standby role.  If 
#   the database is already a physical standby, this routine concludes success.
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#
#   Globals:
#     None
#
# RETURN:
#   None
#
###############################################################################
switch_primary_to_physical()
{
# Assume success if db is already a physical
is_database_role $1 $2 $3 $4 "PHYSICAL STANDBY"
if [ "$?" -eq "1" ]; then
  display "$4 is already a physical standby"
  return 1
fi

# Ensure we're switching from a primary
is_database_role $1 $2 $3 $4 "PRIMARY"
if [ "$?" -eq "0" ]; then
  fail "$4 is neither a primary nor physical standby database"
fi

# Switchover
display "switching $4 to become a physical standby"
l_spp_sql="set pagesize 0 feedback off verify off heading off echo off tab off 
whenever sqlerror exit sql.sqlcode 
alter database commit to switchover to physical standby with session shutdown; 
exit;"
sql_exec $1 $2 $3 "$l_spp_sql"
chkerr $? "failed to switchover to physical standby"
display "$4 is now a physical standby"
return 0
#
# NOTE: no further queries permitted since the database will no longer mounted 
#
}

###############################################################################
# NAME:        wait_mrp_active
#
# DESCRIPTION: 
#   Wait for $MRP_START_TIMEOUT minutes to confirm that the MRP is active.  If
#   we can't detect an active MRP, abort the script with an error.
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#
#   Globals:
#     None
#
# RETURN:
#   None
#
###############################################################################
wait_mrp_active()
{
  display "confirming media recovery is running"
  l_wma_status=1
  l_wma_curtime=`perl -e 'print int(time)'`
  l_wma_exptime=`expr $MRP_START_TIMEOUT "*" 60`
  l_wma_maxtime=`expr $l_wma_curtime + $l_wma_exptime`
  while [ "$l_wma_curtime" -lt "$l_wma_maxtime" ]
  do
    is_mrp_running $1 $2 $3 $4
    if [ "$?" -gt "0" ]; then
      l_wma_status=0
      break
    fi

    sleep $MRP_START_INTERVAL
    l_wma_curtime=`perl -e 'print int(time)'`
  done
  chkerr $l_wma_status "could not detect an active MRP after $MRP_START_TIMEOUT minutes"
}

###############################################################################
# NAME:        wait_standby_eor
#
# DESCRIPTION: 
#   Wait for specified standby database to process the end-of-redo and shutdown 
#   apply/recovery.  This routine will wait for up to $STB_EOR_TIMEOUT minutes
#   before timing out.  If the apply/recovery is found to be shutdown, this 
#   routine will make one startup attempt.  
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#     $5: database version of standby
#
#   Globals:
#     None
#
# RETURN:
#   None
#
###############################################################################
wait_standby_eor()
{
display "waiting for standby $4 to process end-of-redo from primary"

# Identify the standby type
is_database_role $1 $2 $3 $4 "LOGICAL STANDBY"
if [ "$?" -eq "1" ]; then
  l_wse_islogical=1
else
  is_database_role $1 $2 $3 $4 "PHYSICAL STANDBY"
  if [ "$?" -eq "1" ]; then
    l_wse_islogical=0
  else
    fail "database $4 is neither a physical nor logical standby"
  fi
fi

# Wait for 'TO PRIMARY' switchover status to appear -- end-of-redo success
#display "waiting until end-of-redo complete (switchover_status of 'TO PRIMARY')"
l_wse_expdelta=`expr $STB_EOR_TIMEOUT "*" 60`
l_wse_resdelta=`expr $STB_EOR_RESTART_AFTER "*" 60`
l_wse_pstscn=0
l_wse_curscn=1
l_wse_restarted=0
l_wse_status=1
l_wse_curtime=0
l_wse_maxtime=1
l_wse_reset=1
while [ "$l_wse_curtime" -lt "$l_wse_maxtime" ]
do
  # Grab the current time
  l_wse_curtime=`perl -e 'print int(time)'`

  # Reset the timeouts
  if [ "$l_wse_reset" -eq "1" ]; then
    l_wse_maxtime=`expr $l_wse_curtime + $l_wse_expdelta`
    l_wse_restime=`expr $l_wse_curtime + $l_wse_resdelta`
    l_wse_reset=0
  fi

  # Check for end-of-redo completion
  l_wse_sql="    set pagesize 0 feedback off verify off heading off echo off tab off 
  whenever sqlerror exit sql.sqlcode 
  select count(1) from v\$database where SWITCHOVER_STATUS='TO PRIMARY' or SWITCHOVER_STATUS='SESSIONS ACTIVE'; 
  exit;"
  sql_exec $1 $2 $3 "$l_wse_sql"
  chkerr $? "failed to query switchover status on $4"
  l_wse_val=`echo $sql_out`

  # Success
  if [ "$l_wse_val" = "1" ]; then
    l_wse_status=0
    break
  fi

  # Get the last processed scn on the standby
  if [ "$l_wse_islogical" -eq "1" ]; then
    get_applied_scn $1 $2 $3 $4
    l_wse_curscn=$l_gas_val
  else
    get_recovery_scn $1 $2 $3 $4 $5
    l_wse_curscn=$l_grs_val
  fi

  # Reset all timeouts if last applied scn has changed
  if [ "$l_wse_pstscn" != "$l_wse_curscn" ]; then
    l_wse_pstscn=$l_wse_curscn
    l_wse_reset=1
  else
    # Consider a one-time restart if last applied scn has stagnated for l_wse_resdelta seconds
    if [ "$l_wse_curtime" -gt "$l_wse_restime" ]; then

      # Check if apply/recovery is currently running
      if [ "$l_wse_islogical" -eq "1" ]; then
        is_lsp_running $1 $2 $3 $4
      else
        is_mrp_running $1 $2 $3 $4
      fi
      l_wse_running=$?

      # Perform a one-time restart if apply/recovery is not running.
      if [ "$l_wse_restarted" -eq "0" ]; then
        if [ "$l_wse_running" -eq "0" ]; then
          display "WARNING: making one attempt to start apply/recovery until end-of-redo"
          if [ "$l_wse_islogical" -eq "1" ]; then
            start_logical_apply $1 $2 $3 $4
          else
            start_media_recovery $1 $2 $3 $4
          fi
          l_wse_restarted=1
          l_wse_reset=1
        fi
      else
        if [ "$l_wse_running" -eq "0" ]; then
          fail "standby $4 failed to process end-of-redo"
        fi
      fi
    fi
  fi
  sleep $STB_EOR_INTERVAL
done
chkerr $l_wse_status "timed out after $l_wse_expdelta seconds of inactivity"
}

###############################################################################
# NAME:        wait_logical_dictload
#
# DESCRIPTION: 
#   Wait for the logminer dictionary to load.  This routine will wait for up to
#   $LSP_DICT_LOAD_TIMEOUT minutes before timing out.  In order to timeout,
#   successive checks of the dictionary load progress must remain the same for
#   the entire timeout period.  Any change in progress resets the timeout.
#
# INPUT(S):
#   Arguments:
#     $1: database user
#     $2: user password
#     $3: tns service name
#     $4: database unique name
#
#   Globals:
#     None
#
# RETURN:
#   None
#
###############################################################################
wait_logical_dictload()
{
display "waiting until logminer dictionary has fully loaded"

# Wait for dictionary to load
l_wld_lstpct=0
l_wld_retried=0
l_wld_status=1
l_wld_wasloading=0
l_wld_curtime=`perl -e 'print int(time)'`
l_wld_exptime=`expr $LSP_DICT_LOAD_TIMEOUT "*" 60`
l_wld_maxtime=`expr $l_wld_curtime + $l_wld_exptime`
while [ "$l_wld_curtime" -lt "$l_wld_maxtime" ]
do 
  # Lookup current dictionary load completion
  l_wld_sql="  set pagesize 0 feedback off verify off heading off echo off tab off 
  whenever sqlerror exit sql.sqlcode 
  select nvl(translate((select substr(l.status, 12, 4) from 
  v\$logstdby l, v\$logstdby_state s where l.status like 'ORA-16115%' 
  and s.state = 'LOADING DICTIONARY'), '%', ' '), '0') from dual; 
  exit;"
  sql_exec $1 $2 $3 "$l_wld_sql"
  chkerr $? "failed to query dictionary load status"
  l_wld_curpct=`echo $sql_out | awk '{print int(\$0)}'`

  # has dictionary loading stopped ?
  if [ "$l_wld_curpct" -eq "0" ]; then
    
    # Upon successful load, we should be in either of these states
    l_wld_sql="    set pagesize 0 feedback off verify off heading off echo off tab off 
    whenever sqlerror exit sql.sqlcode 
    select count(1) from v\$logstdby_state where 
    state = 'APPLYING' or state = 'IDLE'; 
    exit;"
    sql_exec $1 $2 $3 "$l_wld_sql"
    chkerr $? "failed to query logical standby apply status"
    l_wld_loaded=`echo $sql_out`

    # Success
    if [ "$l_wld_loaded" -eq "1" ]; then
      l_wld_status=0
      break
    fi

    # Give apply one chance to reload the dictionary
    if [ "$l_wld_retried" -eq "0" ]; then
      start_logical_apply $1 $2 $3 $4
      l_wld_retried=1
    fi
  else
    # Set flag indicating we've seen the dictionary loading
    l_wld_wasloading=1

    # NOTE: this view hangs at 100%...show 99% instead
    if [ "$l_wld_curpct" -eq "100" ]; then
      l_wld_curpct=99
    fi

    # Report if progress was made since last check
    if [ "$l_wld_curpct" -gt "$l_wld_lstpct" ] && [ "$l_wld_curpct" -ne "100" ]; then
      l_wld_strpct=`printf %02d $l_wld_curpct`
      display "dictionary load ${l_wld_strpct}% complete"

      # Reset timeout
      l_wld_maxtime=`expr $l_wld_curtime + $l_wld_exptime`

      # Retain last retain last percentage
      l_wld_lstpct=$l_wld_curpct
    fi
  fi

  sleep $LSP_DICT_LOAD_INTERVAL
  l_wld_curtime=`perl -e 'print int(time)'`
done

if [ "$l_wld_status" -eq "0" ]; then
  if [ "$l_wld_wasloading" -eq "1" ]; then
    display "dictionary load is complete"
  else
    display "dictionary already loaded"
  fi
else
  fail "timed out after $LSP_DICT_LOAD_TIMEOUT minutes of inactivity"
fi
}

autopru $1 $2 $3 $4 $5 $6
