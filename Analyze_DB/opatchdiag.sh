#!/bin/sh
#
# Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
#
# DESCRIPTION
#   opatchdiag.sh script collects necessary information to troubleshoot OPatch related issues
#                 either set ENV varilables like ORACLE_HOME, ORACLE_BASE else it prompts the
#                 user to enter these details
#
# USAGE
#   ./opatchdiag.sh
#
# NOTES
#   Search for Note ID 1430571.1 in My Oracle Support
#
# ###########################
#
# Author : uaswatha
# Date   : 27/2/2012
#
# ###########################
#
# Modified         (DD/MM/YYYY)
# uaswatha           06/02/2012  - support to non-default location of oraInst.loc
# uaswatha           20/02/2012  - Zip was not zipping .xml files, fixed it
# uaswatha           31/08/2013  - added a new feature to compare ORACLE_HOME path and HOME INDEX between Local and Central Inventory
#
#
#####################################################################################################



UNAME=`which uname`
PLATFORMNAME=`$UNAME`;

case $PLATFORMNAME in
    AIX)
        ORA_INST_LOC='/etc'
        LLS='/usr/bin/ls -l'
        LS='/usr/bin/ls'
        ID='/usr/bin/id'
        GREP='/usr/bin/grep'
        ENV='/usr/bin/env'
        UNAME='/usr/bin/uname'
        WHICH='/usr/bin/which'
        FILE='/usr/bin/file'
        WC='/usr/bin/wc'
        SORT='/usr/bin/sort'
        CAT='/usr/bin/cat'
        ZIP='/usr/bin/zip'
        MKDIR='/usr/bin/mkdir'
        CP='/usr/bin/cp'
        OSLEVEL='/usr/bin/oslevel'
        AWK='/usr/bin/awk'
        DATE='/usr/bin/date'
        BASENAME='/usr/bin/basename'
        ULIMIT='/usr/bin/ulimit'
        CAT='/usr/bin/cat'
        EGREP='/usr/bin/egrep'
        TEE='/usr/bin/tee'

        HARDPLATFORM=`$UNAME -M`
        HOSTNAME=`$UNAME -n`
        RELEASE=`$UNAME -r`
        VERSION=`$UNAME -v`
        KERNELRELEASE="$VERSION.$RELEASE"
      ;;
    Linux)
        ORA_INST_LOC='/etc'
        LLS='/bin/ls -l'
        LS='/bin/ls'
        ID='/usr/bin/id'
        GREP='/bin/grep'
        ENV='/usr/bin/env'
        UNAME='/bin/uname'
        WHICH='/usr/bin/which'
        FILE='/usr/bin/file'
        WC='/usr/bin/wc'
        SORT='/bin/sort'
        CAT='/bin/cat'
        GREP='/bin/grep'
        ZIP='/usr/bin/zip'
        MKDIR='/bin/mkdir'
        DATE='/bin/date'
        CP='/bin/cp'
        AWK='/usr/bin/awk'
        BASENAME='/bin/basename'
        ULIMIT='ulimit'
        CAT='/bin/cat'
        EGREP='/bin/egrep'
        TEE='/usr/bin/tee'

        HARDPLATFORM=`$UNAME -i`
        HOSTNAME=`$UNAME -n`
        KERNELRELEASE=`$UNAME -r`
      ;;
    HP-UX)
        ORA_INST_LOC='/etc'
        LLS='/usr/bin/ll'
        LS='/usr/bin/ls'
        ID='/usr/bin/id'
        GREP='/usr/bin/grep'
        ENV='/usr/bin/env'
        UNAME='/usr/bin/uname'
        WHICH='/usr/bin/which'
        FILE='/usr/bin/file'
        WC='/usr/bin/wc'
        SORT='/usr/bin/sort'
        CAT='/usr/bin/cat'
        GREP='/usr/bin/grep'
        ZIP='/usr/bin/zip'
        MKDIR='/usr/bin/mkdir'
        DATE='/usr/bin/date'
        CP='/usr/bin/cp'
        AWK='/usr/bin/awk'
        BASENAME='/usr/bin/basename'
        ULIMIT='/usr/bin/ulimit'
        CAT='/usr/bin/cat'
        EGREP='/usr/bin/egrep'
        TEE='/usr/bin/tee'

        HARDPLATFORM=`$UNAME -m`
        HOSTNAME=`$UNAME -n`
        KERNELRELEASE="`$UNAME -s` `$UNAME -r`"
      ;;
    IBM)
        ORA_INST_LOC='/etc'
      ;;
    SunOS)
        ORA_INST_LOC='/var/opt/oracle'
        LLS='/usr/bin/ls -l'
        LS='/usr/bin/ls'
        ID='/usr/bin/id'
        GREP='/usr/bin/grep'
        ENV='/usr/bin/env'
        UNAME='/usr/bin/uname'
        WHICH='/usr/bin/which'
        FILE='/usr/bin/file'
        WC='/usr/bin/wc'
        SORT='/usr/bin/sort'
        CAT='/usr/bin/cat'
        ZIP='/usr/bin/zip'
        CP='/usr/bin/cp'
        DATE='/usr/bin/date'
        AWK='/usr/bin/awk'
        BASENAME='/usr/bin/basename'
        ULIMIT='/usr/bin/ulimit'
        CAT='/usr/bin/cat'
        EGREP='/usr/bin/egrep'
        MKDIR='/usr/bin/mkdir'
        TEE='/usr/bin/tee'

        HARDPLATFORM="`$UNAME -i` $`UNAME -p`"
        HOSTNAME=`$UNAME -n`
        KERNELRELEASE="`$UNAME -r` `$UNAME -v`"
      ;;
esac

LOGDIR="/tmp/opatchdiag"
INVFILE='ContentsXML/inventory.xml'   #### Central Inventory file
COMPSFILE='ContentsXML/comps.xml'     #### Central Inventory file
ORA_INST_FILENAME='oraInst.loc'
FILEDATE="`$DATE +%d_%m_%y_%H_%M_%S`"


echo -n "Currently LOGDIR is $LOGDIR, do you want to change it [Y/N] "
read CHLOG

while ( [ "$CHLOG" != "Y" ] && [ "$CHLOG" != "N" ] ) && ( [ "$CHLOG" != "y" ] && [ "$CHLOG" != "n" ] )
do
   echo -n "Please enter [Y/N] : "
   read CHLOG
done;

if [ "$CHLOG" = "Y" ] || [ "$CHLOG" = "y" ]; then
   echo -n "Enter directory location where you have permission : "
   read LOGDIR
   if [ ! -O "$LOGDIR" ]; then
      echo "Either directory does not exists or not owned by current user"
      echo "hence retaining /tmp/opatchdiag as LOGDIR"
      echo
      LOGDIR="/tmp/opatchdiag"
   fi
fi

echo "Logdir : " $LOGDIR

if [ ! -f $ORA_INST_LOC/oraInst.loc ]; then
   echo "oraInst.loc is not in default location $ORA_INST_LOC"
   echo "Please enter the location oraInst.loc file : "
   read ORA_INST_LOC

   if [ ! -f $ORA_INST_LOC/oraInst.loc ]; then
      echo "$ORA_INST_LOC/oraInst.loc not found, locate the file and rerun the script"
      exit 1
   fi
fi

ORACLE_CENTRAL_INVENTORY=`$GREP "inventory_loc" $ORA_INST_LOC/oraInst.loc | awk -F'=' '{print $2}'`

if [ ${ORACLE_BASE:-x} = 'x' ]; then
    echo "Oracle Base not set"
    echo -n "Enter Oracle Base path : "
    read ORACLEBASE
    echo $ORACLEBASE
else 
    ORACLEBASE=$ORACLE_BASE
    echo "Current Oracle Base is $ORACLE_BASE"
fi

if [ ! -d $ORACLEBASE ] || [ "$ORACLEBASE" = "" ] ; then
   echo "Not able identify $ORACLE_BASE path..."
   echo "You need to enter valid ORACLE_BASE path..."
   echo "Would like to manually enter the ORACLE_BASE path [Y/N] "
   read CHLOG
   while ( [ "$CHLOG" != "Y" ] && [ "$CHLOG" != "N" ] ) && ( [ "$CHLOG" != "y" ] && [ "$CHLOG" != "n" ] )
   do
      echo -n "Please enter [Y/N] : "
      read CHLOG
   done;
   if [ "$CHLOG" = "Y" ] || [ "$CHLOG" = "y" ]; then
      echo -n "Enter the path to ORACLE_BASE "
      read ORACLEBASE
   fi
   exit 1
fi

####echo Test ${ORACLEBASE}${INVFILE} 
####if [ ! -f ${ORACLEBASE}${INVFILE} ]; then
if [ ! -f ${ORACLE_CENTRAL_INVENTORY}/${INVFILE} ]; then 
    echo "Inventory file missing....think you have not entered valid ORACLE_BASE"
    echo "Enter valid ORACLE_BASE path"
    exit 1
fi

#if [ "$ORACLEBASE" != */ ]; then
#   ORACLEBASE="$ORACLEBASE"/
#fi

[[ $ORACLEBASE != */ ]] && ORACLEBASE="$ORACLEBASE"/

####echo $ORACLEBASE


if [ ${ORACLE_HOME:-x} = 'x' ]; then
    echo "Oracle Home not set"
    echo -n "Enter Oracle home path : "
    read ORACLEHOME
    echo $ORACLEHOME
else 
    ORACLEHOME=$ORACLE_HOME
    echo "Current Oracle Home is $ORACLE_HOME"
fi

if [ ! -d $ORACLEHOME ] || [ "$ORACLEHOME" = "" ]; then
   echo "You need to enter valid ORACLE_HOME path..."
   exit 1
fi

[[ $ORACLEHOME = */ ]] && ORACLEHOME=`echo $ORACLEHOME | sed -e 's/\/$//g'`

SEARCHSTRING="LOC=\"$ORACLEHOME\""

CHECK_OH=`$GREP $SEARCHSTRING ${ORACLE_CENTRAL_INVENTORY}/${INVFILE}`

#if [ ${CHECK_OH:-x} = 'x' ]; then

if [ $? -ne 0 ]; then
    echo "Not able to find $ORACLEHOME in ${ORACLE_CENTRAL_INVENTORY}/${INVFILE}'}"
    echo "think you have entered invalid ORACLE_HOME path"
    echo "Enter valid ORACLE_HOME path"
    exit 1
fi


####echo $ORACLEHOME

####
#### Define some varilales based on Oracle home value
####

ORACLE_HOME_PROPERTIES="$ORACLEHOME/inventory/ContentsXML/oraclehomeproperties.xml"
ORACLE_HOME_COMPS="$ORACLEHOME/inventory/ContentsXML/comps.xml"
ORACLE_HOME_INVENTORY="$ORACLEHOME/inventory/ContentsXML/inventory.xml"
OPATCH_HISTORY="$ORACLEHOME/cfgtoollogs/opatch/opatch_history.txt"
ORACLEHOMENAME=`$GREP $SEARCHSTRING ${ORACLE_CENTRAL_INVENTORY}/${INVFILE} | $AWK -F'=' '{print $2}'| $AWK -F'"' '{print $2}'`

echo "Oracle home name : " $ORACLEHOMENAME

LOGFILENAME="$LOGDIR/opatchdiag_${ORACLEHOMENAME}_${FILEDATE}.log"
INVLOGFILENAME="$LOGDIR/invlogfile_${ORACLEHOMENAME}_$FILEDATE.log"
LOGZIP="$LOGDIR/opatchlog_${ORACLEHOMENAME}_${FILEDATE}.zip"
OPATCHZIP="opatchdiag_${ORACLEHOMENAME}_${FILEDATE}.zip"

MD5SUM=`$WHICH md5sum`
FOUND=0

if [ $? -eq 0 ]; then 
   echo "md5sum found at $MD5SUM"
   FOUND=1
fi

MD5_Y_N='Y'

if [ $FOUND -eq 0 ]; then
     while ( [ "$MD5_Y_N" != "Y" ] && [ "$MD5_Y_N" != "N" ] ) && ( [ "$MD5_Y_N" != "y" ] && [ "$MD5_Y_N" != "n" ] )
     do
         echo -n "Do you have md5sum utility installed on your system [Y/N] : "
         read MD5_Y_N
###    MD5_Y_N=`echo $MD5_Y_N | /usr/bin/tr '[a..z]' '[A..Z]'`
         echo $MD5_Y_N
     done ;

     if [ "$MD5_Y_N" = "Y" ] || [ "$MD5_Y_N" = "y" ]; then
         echo -n "Please enter the path along with filename of md5sum command : "
         read MD5SUM

###    MD5SUM=`echo $MD5SUM | tr '[A..Z]' '[a..z]'`

         if [ ! -x $MD5SUM ]; then
            echo "Either md5sum not found or not in entered path $MD5SUM"
            echo "hence assuming md5sum not installed"
            MD5_Y_N="N"
         else
            FOUND=1
###            echo "Enter the filename of the patch downloaded along with path <path to patch>/<filename.zip>"
###            read PATCH_ZIP_FILENAME
###
###            if [ ! -f $PATCH_ZIP_FILENAME ]; then
###               echo "File not found !!!!....skipping md5sum checking...."
###               MD5_Y_N="N"
###            fi
         fi
     fi
fi

if [ $FOUND -eq 1 ] && [ "$MD5_Y_N" = "Y" ]; then
     echo "*******************************************************"
     echo "To check the integrity of the patch downloaded from MOS"
     echo "or press ENTER continue"
     echo "*******************************************************"
     echo "Enter the filename of the patch along with path <path to patch>/<filename.zip>"
     read PATCH_ZIP_FILENAME

     if [ ! -f "$PATCH_ZIP_FILENAME" ]; then
        echo "File not found !!!!....skipping md5sum checking...."
        MD5_Y_N="N"
     fi
fi

echo $MD5_Y_N
if [ "$MD5_Y_N" = "Y" ] ; then
   PATCH_NAME=`$BASENAME $PATCH_ZIP_FILENAME`
   PATCHID=`echo $PATCH_NAME |awk -F'_' '{print $1}'|awk -F 'p' '{print $2}'`
fi

###echo "Enter the patch id details which is scheduled to be installed"
###echo
echo "Patch ID : " $PATCHID
###read PATCHID
###echo -n "Enter Path where $PATCHID is unzipped : "
###read PATCHPATH

###if [ ! -d $PATCHPATH ]; then
###   echo "Enter a valid Patch Path"
###   exit 1
###fi

###if [ ! -d ${PATCHPATH}/${PATCHID} ]; then
###    echo "$PATCHID not found in $PATCHPATH..."
###    echo "You need to valid information...."
###    exit 1
###fi

###if [ `$LS ${PATCHPATH}/${PATCHID} | $WC -l` -eq 0 ] ; then
###    echo "${PATCHPATH}/${PATCHID} directory empty..."
###    echo "Enter valid information"
###    exit 1
###fi

echo "**** Gathering Data ****"
 

if [ ! -d $LOGDIR ]; then
    $MKDIR -p $LOGDIR
fi
#########################################################

# Printing progress bar
echo -n .


echo "Diagnostic data for OPatch Utility" >$LOGFILENAME

echo >> $LOGFILENAME
echo >> $LOGFILENAME

echo ============================ >>$LOGFILENAME
echo "     System Details"         >>$LOGFILENAME
echo ============================ >>$LOGFILENAME
echo "OS Platform : $PLATFORMNAME">>$LOGFILENAME
echo "Kernel Ver  : $KERNELRELEASE">>$LOGFILENAME 
echo "Hardware    : $HARDPLATFORM">>$LOGFILENAME 
echo "Hostname    : $HOSTNAME">>$LOGFILENAME 

if [ "$PLATFORMNAME" = "AIX" ]; then
    echo "OSLEVEL     : " `$OSLEVEL -s` >>$LOGFILENAME
fi

echo >> $LOGFILENAME
echo >> $LOGFILENAME

# Printing progress bar
echo -n .

echo ============================ >>$LOGFILENAME
echo "     ULIMIT Details"         >>$LOGFILENAME
echo ============================ >>$LOGFILENAME
$ULIMIT -a 2>&1 >>$LOGFILENAME

echo >> $LOGFILENAME
echo >> $LOGFILENAME


# Printing progress bar
echo -n .

echo ============================ >>$LOGFILENAME
echo "     OS release Details"    >>$LOGFILENAME
echo ============================ >>$LOGFILENAME

if [ "$PLATFORM" = "AIX" ] ; then
   $OSLEVEL -s 2>&1 >>$LOGFILENAME
elif [ "$PLATFORM" = "HPUX" ] ; then
   $UNAME -r 2>&1 >>$LOGFILENAME
else 
   $CAT /etc/*release  2>&1 >>$LOGFILENAME
fi

echo >> $LOGFILENAME
echo >> $LOGFILENAME


# Printing progress bar
echo -n .

echo ============================ >>$LOGFILENAME
echo "     Opatch Version"        >>$LOGFILENAME
echo ============================ >>$LOGFILENAME
echo `$ORACLEHOME/OPatch/opatch version | $GREP -i version` >>$LOGFILENAME

echo >> $LOGFILENAME
echo >> $LOGFILENAME

# Printing progress bar
echo -n .

echo ============================    >>$LOGFILENAME
echo "       oraInst.loc"            >>$LOGFILENAME
echo ============================    >>$LOGFILENAME
$CAT $ORA_INST_LOC/$ORA_INST_FILENAME >>$LOGFILENAME

echo >> $LOGFILENAME
echo >> $LOGFILENAME

# Printing progress bar
echo -n .

echo ============================ >>$LOGFILENAME
echo "    ORACLE_HOME & BASE"     >>$LOGFILENAME
echo ============================ >>$LOGFILENAME
echo "ORACLE_BASE = $ORACLEBASE"  >>$LOGFILENAME
echo "ORACLE_HOME = $ORACLEHOME"  >>$LOGFILENAME
echo -n "Oracle Base Owned by : " >>$LOGFILENAME
echo `$LS -ld $ORACLEBASE | awk '{print $3, ":", $4}'`>>$LOGFILENAME
echo -n "Oracle Home Owned by : "                     >>$LOGFILENAME
echo `$LS -ld $ORACLEHOME | awk '{print $3, ":", $4}'`>>$LOGFILENAME

# Printing progress bar
echo -n .

BUFFER=`$GREP -w "ARU_ID" $ORACLE_HOME_PROPERTIES`

if [ $? -ne 0 ] ; then
   echo "Not able to find ARU ID in oraclehomeproperties.xml, check the file manually">>$LOGFILENAME
else
   echo "Platform ID : `$GREP -w "ARU_ID" $ORACLE_HOME_PROPERTIES|awk -F'>' '{print $2}'|awk -F'<' '{print $1}'`">>$LOGFILENAME
fi

BUFFER=`$GREP -w "ARU_ID_DESCRIPTION" $ORACLE_HOME_PROPERTIES`

if [ $? -ne 0 ] ; then
   echo "Not able to find ARU_ID_DESCRIPTION in oraclehomeproperties.xml, check the file manually">>$LOGFILENAME
else
   echo "Platform Name : `$GREP -w "ARU_ID_DESCRIPTION" $ORACLE_HOME_PROPERTIES|awk -F'>' '{print $2}'|awk -F'<' '{print $1}'`">>$LOGFILENAME
fi

$CP $ORACLE_HOME_PROPERTIES ${LOGDIR}/${ORACLEHOMENAME}_local_oraclehomeproperties.xml

echo >> $LOGFILENAME

if [ -f $ORACLEHOME/.patch_storage/patch_lock ]; then
   echo "$ORACLEHOME/.patch_storage/patch_lock file found !!!!"                                        >>$LOGFILENAME
   echo "I think either currently there is an active opatch session or old session has ended abruptly" >>$LOGFILENAME
fi

echo >> $LOGFILENAME
echo >> $LOGFILENAME

# Printing progress bar
echo -n .


echo ============================ >>$LOGFILENAME
echo "        env output"         >>$LOGFILENAME
echo ============================ >>$LOGFILENAME
$ENV|$SORT                        >>$LOGFILENAME>>$INVLOGFILENAME
echo "ORACLE_HOME = $ORACLEHOME"  >>$LOGFILENAME

echo >> $LOGFILENAME
echo >> $LOGFILENAME

echo ============================ >>$LOGFILENAME
echo "Inventory file is owned by" >>$LOGFILENAME
echo ============================ >>$LOGFILENAME

PERM=`$LLS ${ORACLE_CENTRAL_INVENTORY}/${INVFILE}|awk '{print $1}'`
USER=`$LLS ${ORACLE_CENTRAL_INVENTORY}/${INVFILE} |awk '{print $3}'`
OWNER=`$LLS ${ORACLE_CENTRAL_INVENTORY}/${INVFILE}|awk '{print $4}'`

echo "Username   = $USER"         >> $LOGFILENAME
echo "Group      = $OWNER"        >> $LOGFILENAME
echo "Permission = $PERM"         >> $LOGFILENAME

echo >> $LOGFILENAME
echo >> $LOGFILENAME

echo ============================ >>$LOGFILENAME
echo "Current OS USER"            >>$LOGFILENAME
echo ============================ >>$LOGFILENAME
if [ "$PLATFORM" = "SunOS" ] || [ "$PLATFORM" = "Linux" ]; then
   $ID -a >> $LOGFILENAME
else
   $ID >> $LOGFILENAME
fi

echo >> $LOGFILENAME
echo >> $LOGFILENAME

echo ============================ >>$LOGFILENAME
echo "      Java version"         >>$LOGFILENAME
echo ============================ >>$LOGFILENAME
echo "OH Java version : " `$ORACLEHOME/jdk/bin/java -version 2>&1 | $TEE /tmp/jver; $CAT /tmp/jver` >>$LOGFILENAME
echo >> $LOGFILENAME

# Printing progress bar
echo -n .

$WHICH java >/dev/null 2>&1

if [ $? -ne 0 ] ; then
   echo "OS Java not found in PATH=$PATH">>$LOGFILENAME
else
   echo "OS Java found at path " `$WHICH java` >> $LOGFILENAME
fi

if [ ${JAVA_HOME:-x} = 'x' ]; then
    echo "JAVA_HOME env variable not set">>$LOGFILENAME
else 
    echo "Currently JAVA_HOME is set to $JAVA_HOME">>$LOGFILENAME
fi

echo >> $LOGFILENAME
echo >> $LOGFILENAME

echo ============================ >>$LOGFILENAME
echo "Oracle binary BIT details"  >>$LOGFILENAME
echo ============================ >>$LOGFILENAME
echo `$FILE $ORACLEHOME/bin/oracle` >>$LOGFILENAME

echo >> $LOGFILENAME
echo >> $LOGFILENAME


echo ============================ >>$LOGFILENAME
echo "  Patch $PATCHID details"   >>$LOGFILENAME
echo ============================ >>$LOGFILENAME

###if [ -f ${PATCHPATH}/${PATCHID}/etc/config/inventory ]; then
###   echo `$GREP "platform name" ${PATCHPATH}/${PATCHID}/etc/config/inventory | awk -F '=' '{print $2}'|sed 's/id//'`>>$LOGFILENAME
###   echo `$GREP "Platform ID" ${PATCHPATH}/${PATCHID}/etc/config/inventory | awk -F '=' '{print $3}'|sed 's/\/>//'|sed 's/\"//g'`>>$LOGFILENAME
###   echo "Platform name : " `$GREP "platform name" ${PATCHPATH}/${PATCHID}/etc/config/inventory | awk -F '\"' '{print $2}'`>>$LOGFILENAME
###   echo "Platform id   : " `$GREP "platform name" ${PATCHPATH}/${PATCHID}/etc/config/inventory | awk -F '\"' '{print $4}'`>>$LOGFILENAME
###elif [ -f ${PATCHPATH}/${PATCHID}/etc/config/inventory.xml ]; then 
###   echo `$GREP "platform name" ${PATCHPATH}/${PATCHID}/etc/config/inventory.xml | awk -F '=' '{print $2}'|sed 's/id//'`>>$LOGFILENAME
###   echo `$GREP "Platform ID" ${PATCHPATH}/${PATCHID}/etc/config/inventory.xml | awk -F '=' '{print $3}'|sed 's/\/>//'|sed 's/\"//g'`>>$LOGFILENAME
###   echo "Platform name : " `$GREP "platform name" ${PATCHPATH}/${PATCHID}/etc/config/inventory.xml | awk -F '\"' '{print $2}'`>>$LOGFILENAME
###   echo "Platform id   : " `$GREP "platform name" ${PATCHPATH}/${PATCHID}/etc/config/inventory.xml | awk -F '\"' '{print $4}'`>>$LOGFILENAME
###fi

if [ "$MD5_Y_N" = "Y" ] || [ "$MD5_Y_N" = "y" ]; then
    echo "MD5SUM : " `$MD5SUM $PATCH_ZIP_FILENAME` >>$LOGFILENAME
    echo "$PATCH_ZIP_FILENAME listing" >> $LOGFILENAME
    $LLS $PATCH_ZIP_FILENAME >>$LOGFILENAME
else
    echo "MD5SUM details not entered" >>$LOGFILENAME
fi

if [ "$PATCHID" = "" ]; then
   echo "No Patch has been scheduled to be installed, hence not collecting logs" >>$LOGFILENAME
fi
echo >> $LOGFILENAME
echo >> $LOGFILENAME


# Printing progress bar
echo -n .

echo ============================ >>$LOGFILENAME
echo "  Integrity of Inventory"   >>$LOGFILENAME
echo ============================ >>$LOGFILENAME


CINV=`basename $INVFILE`
CCOMP=`basename $COMPSFILE`
LCOMP=`basename $ORACLE_HOME_COMPS`
LINV=`basename $ORACLE_HOME_INVENTORY`

echo "Local Inventory">> $LOGFILENAME
echo >> $LOGFILENAME

if [ -f $ORACLE_HOME_COMPS ]; then
     $ORACLEHOME/OPatch/opatch util loadxml -invPtrLoc $ORA_INST_LOC/oraInst.loc -xmlInput $ORACLE_HOME_COMPS 1>$LOGDIR/checkinv.out
     ERROR=$?

     if [ $? -ne 0 ]; then
        echo "$ORACLE_HOME_COMPS Integrity check failed...">>$LOGFILENAME
        echo "Opatch failed with error $ERROR"                               >>$LOGFILENAME
        echo >> $LOGFILENAME
        echo "Error Message"                                                 >>$LOGFILENAME
        echo "-------------"                                                 >>$LOGFILENAME
        $CAT $LOGDIR/checkinv.out                                               >>$LOGFILENAME
     else
        echo "$ORACLE_HOME_COMPS Integrity check passed...">>$LOGFILENAME
     fi
     $CP $ORACLE_HOME_COMPS ${LOGDIR}/${ORACLEHOMENAME}_local_${LCOMP}
   else
     echo "File not found $ORACLE_HOME_COMPS...">>$LOGFILENAME
fi


if [ -f $ORACLE_HOME_INVENTORY ]; then
    $ORACLEHOME/OPatch/opatch util loadxml -invPtrLoc $ORA_INST_LOC/oraInst.loc -xmlInput $ORACLE_HOME_INVENTORY 1>$LOGDIR/checkinv1.out
    ERROR=$?

    if [ $? -ne 0 ]; then
       echo "$ORACLE_HOME_INVENTORY integrity check failed...">>$LOGFILENAME
       echo "Opatch failed with error $ERROR"                               >>$LOGFILENAME
       echo >> $LOGFILENAME
       echo "Error Message"                                                 >>$LOGFILENAME
       echo "-------------"                                                 >>$LOGFILENAME
       $CAT $LOGDIR/checkinv1.out                                               >>$LOGFILENAME
    else
       echo "$ORACLE_HOME_INVENTORY integrity check passed...">>$LOGFILENAME
    fi
    $CP $ORACLE_HOME_INVENTORY ${LOGDIR}/${ORACLEHOMENAME}_local_${LINV}
   else
       echo "File not found $ORACLE_HOME_INVENTORY...">>$LOGFILENAME
fi

# Printing progress bar
echo -n .


echo >> $LOGFILENAME
echo "Central Inventory">> $LOGFILENAME
echo >> $LOGFILENAME

if [ -f ${ORACLE_CENTRAL_INVENTORY}/${INVFILE} ]; then
      $ORACLEHOME/OPatch/opatch util loadxml -invPtrLoc $ORA_INST_LOC/oraInst.loc -xmlInput ${ORACLE_CENTRAL_INVENTORY}/${INVFILE} 1>$LOGDIR/checkinv2.out
      ERROR=$?

      if [ $? -ne 0 ]; then
         echo "$ORACLE_CENTRAL_INVENTORY/$INVFILE integrity check failed...">>$LOGFILENAME
         echo "Opatch failed with error $ERROR"                                   >>$LOGFILENAME
         echo                                                                     >>$LOGFILENAME
         echo "Error Message"                                                     >>$LOGFILENAME
         echo "-------------"                                                     >>$LOGFILENAME
         $CAT $LOGDIR/checkinv2.out                                                   >>$LOGFILENAME
      else
         echo "$ORACLE_CENTRAL_INVENTORY/$INVFILE integrity check passed..." >>$LOGFILENAME
      fi
      $CP ${ORACLE_CENTRAL_INVENTORY}/${INVFILE} ${LOGDIR}/${ORACLEHOMENAME}_central_${CINV}
   else
       echo "File not found  ${ORACLE_CENTRAL_INVENTORY}/${INVFILE}...">>$LOGFILENAME
fi

if [ -f ${ORACLE_CENTRAL_INVENTORY}/${COMPSFILE} ]; then
     $ORACLEHOME/OPatch/opatch util loadxml -invPtrLoc $ORA_INST_LOC/oraInst.loc -xmlInput ${ORACLE_CENTRAL_INVENTORY}/${COMPSFILE} 1>$LOGDIR/checkinv3.out
     ERROR=$?

     if [ $? -ne 0 ]; then
        echo "Central inventory $ORACLE_CENTRAL_INVENTORY/$COMPSFILE integrity check failed...">>$LOGFILENAME
        echo "Opatch failed with error $ERROR"                                                   >>$LOGFILENAME
        echo                                                                                     >>$LOGFILENAME
        echo "Error Message"                                                                     >>$LOGFILENAME
        echo "-------------"                                                                     >>$LOGFILENAME
        $CAT $LOGDIR/checkinv3.out                                                                   >>$LOGFILENAME
     else
        echo "$ORACLE_CENTRAL_INVENTORY/$COMPSFILE integrity check passed..."                  >>$LOGFILENAME
     fi
     $CP ${ORACLE_CENTRAL_INVENTORY}/${COMPSFILE} ${LOGDIR}/${ORACLEHOMENAME}_central_${CCOMP}
   else
       echo "File not found $ORACLE_CENTRAL_INVENTORY}/${COMPSFILE}...">>$LOGFILENAME
fi


# Printing progress bar
echo -n .

####echo $PATCHID $OPATCH_HISTORY

if [ ! -f $ZIP ]; then
   ZIP="$ORACLEHOME/bin/zip"
fi

if [ "$PATCHID" != '' ]; then
    for i in `grep -n $PATCHID $OPATCH_HISTORY |awk -F':' '{ printf "%d %s",$1,":";  gsub(/ *$/,"",$2);print $2 }'|awk -F':' '{if ($2 == "Current Dir") print $1+2; else if ($2 == "Command") print $1+1;}'|uniq`; do awk "NR==$i" $OPATCH_HISTORY | awk -F':' '{print $2}' | xargs $ZIP -q -j $LOGZIP 2>&1 > /dev/null; done; 
fi


# Printing progress bar
echo -n .


echo "======================" > $INVLOGFILENAME
echo "OPatch lsinventory"     >>$INVLOGFILENAME
echo "======================" >>$INVLOGFILENAME
echo "opatch lsinventory" >>$INVLOGFILENAME
$ORACLEHOME/OPatch/opatch lsinventory -invPtrLoc $ORA_INST_LOC/oraInst.loc 2>&1 >> $INVLOGFILENAME
echo >> $INVLOGFILENAME
echo >> $INVLOGFILENAME

echo "===========================" >>$INVLOGFILENAME
echo "OPatch lsinventory -detail"     >>$INVLOGFILENAME
echo "===========================" >>$INVLOGFILENAME

$ORACLEHOME/OPatch/opatch lsinventory -detail -invPtrLoc $ORA_INST_LOC/oraInst.loc 2>&1 >>$INVLOGFILENAME
echo >> $INVLOGFILENAME
echo >> $INVLOGFILENAME

echo "========================" >>$INVLOGFILENAME
echo "OPatch lsinventory -all"  >>$INVLOGFILENAME
echo "========================" >>$INVLOGFILENAME

$ORACLEHOME/OPatch/opatch lsinventory -all -invPtrLoc $ORA_INST_LOC/oraInst.loc 2>&1 >>$INVLOGFILENAME
echo >> $INVLOGFILENAME
echo >> $INVLOGFILENAME

# Printing progress bar
echo -n .

echo "===========================" >>$INVLOGFILENAME
echo "OPatch bugs_fixed (CPU/PSU)"  >>$INVLOGFILENAME
echo "===========================" >>$INVLOGFILENAME

echo "======">>$INVLOGFILENAME
echo " PSU  ">>$INVLOGFILENAME
echo "======">>$INVLOGFILENAME
$ORACLEHOME/OPatch/opatch lsinventory -bugs_fixed -invPtrLoc $ORA_INST_LOC/oraInst.loc |$EGREP 'PSU|PATCH SET UPDATE' 2>&1 >>$INVLOGFILENAME
echo >>$INVLOGFILENAME
echo >>$INVLOGFILENAME
echo "======">>$INVLOGFILENAME
echo " CPU  ">>$INVLOGFILENAME
echo "======">>$INVLOGFILENAME
$ORACLEHOME/OPatch/opatch lsinventory -bugs_fixed -invPtrLoc $ORA_INST_LOC/oraInst.loc |$EGREP "CPU.* DATABASE" 2>&1 >>$INVLOGFILENAME
echo >> $INVLOGFILENAME
echo >> $INVLOGFILENAME


OPATCH_DEBUG=true
export OPATCH_DEBUG

echo "==================================" >>$INVLOGFILENAME
echo "Debug output of OPatch lsinventory" >>$INVLOGFILENAME
echo "==================================" >>$INVLOGFILENAME

$ORACLEHOME/OPatch/opatch lsinventory -all -invPtrLoc $ORA_INST_LOC/oraInst.loc 2>&1 >>$INVLOGFILENAME
echo >> $INVLOGFILENAME
echo >> $INVLOGFILENAME


# Printing progress bar
echo -n .

echo "===================================================" >>$INVLOGFILENAME
echo "Oracle executable/library last built (relinked) on" >>$INVLOGFILENAME
echo "check the time stamp of these files"                >>$INVLOGFILENAME
echo "==================================================" >>$INVLOGFILENAME

$LLS $ORACLEHOME/bin/ 2>&1 >>$INVLOGFILENAME
echo >> $INVLOGFILENAME
echo >> $INVLOGFILENAME


echo "==================================" >>$INVLOGFILENAME
echo "$ORACLEHOME/.patch_storage listing" >>$INVLOGFILENAME
echo "==================================" >>$INVLOGFILENAME

$LLS -R $ORACLEHOME/.patch_storage 2>&1 >>$INVLOGFILENAME
echo >> $INVLOGFILENAME
echo >> $INVLOGFILENAME

echo "=====================================" >>$INVLOGFILENAME
echo "$ORACLEHOME/inventory/oneoff listing" >>$INVLOGFILENAME
echo "=====================================" >>$INVLOGFILENAME

if [ -d  $ORACLEHOME/inventory/oneoffs ]; then
   $LLS -R $ORACLEHOME/inventory/oneoffs 2>&1 >>$INVLOGFILENAME
else 
   echo "No one off directories found or installed">>$INVLOGFILENAME
fi
echo >> $INVLOGFILENAME
echo >> $INVLOGFILENAME


# Printing progress bar
echo -n .

echo "=====================================" >>$INVLOGFILENAME
echo "Comparing Central and Local Inventory" >>$INVLOGFILENAME
echo "Comparing ORACLE_HOME and HOME IDEX"   >>$INVLOGFILENAME
echo "=====================================" >>$INVLOGFILENAME


while read -r invEntry ;
do
   case $invEntry in
       "<HOME "*)
                  ORACLE_HOME_LOC=`echo $invEntry | awk '{print $3}' | awk -F'"' '{print $2}'`
                  ORACLE_HOME_IDX=`echo $invEntry | awk '{print $5}' | awk -F'"' '{print $2}'`
#                  echo $ORACLE_HOME_LOC "    " $ORACLE_HOME_IDX
                  LOCAL_INVENTORY_FILE="${ORACLE_HOME_LOC}/inventory/ContentsXML/comps.xml"

                  echo "************************" >>$INVLOGFILENAME
                  if [ -f $LOCAL_INVENTORY_FILE ] ; then

                  ORACLE_HOME_IDX_LOCAL=`sed -n '/HOME_IDX/{p;q;}' $LOCAL_INVENTORY_FILE | awk '{print $NF}' |awk -F'"' '{print $2}'`
                  ORACLE_HOME_LOC_LOCAL=`sed -n '/INST_LOC/{p;q;}' $LOCAL_INVENTORY_FILE | awk '{print $NF}'|awk -F'"' '{print $2}'|xargs dirname`
#                  echo $LOCAL_INVENTORY_FILE "   " $ORACLE_HOME_LOC_LOCAL "    " $ORACLE_HOME_IDX_LOCAL
                 if [ $ORACLE_HOME_LOC = $ORACLE_HOME_LOC_LOCAL ]; then
                    echo ORACLE_HOME path $ORACLE_HOME_LOC matches in local and central inventory >>$INVLOGFILENAME
                 else
                    echo ORACLE_HOME path does not match in local and central inventory >>$INVLOGFILENAME
                    echo Central Inventory $ORACLE_HOME_LOC                             >>$INVLOGFILENAME
                    echo Local Inventory $ORACLE_HOME_LOC_LOCAL                         >>$INVLOGFILENAME
                 fi

                 if [ $ORACLE_HOME_IDX -eq $ORACLE_HOME_IDX_LOCAL ]; then
                    echo HOME INDEX $ORACLE_HOME_IDX matches in local and central inventory >>$INVLOGFILENAME
                 else
                    echo ORACLE_HOME_INDEX does not match in local and central inventory >>$INVLOGFILENAME
                    echo Central Inventory $ORACLE_HOME_IDX                              >>$INVLOGFILENAME
                    echo Local Inventory $ORACLE_HOME_IDX_LOCAL                          >>$INVLOGFILENAME
                 fi

#                     echo $ORACLE_HOME_LOC_LOCAL
#                     echo $ORACLE_HOME_IDX_LOCAL
                 else
                     echo $ORACLE_HOME_LOC directory not found !!! >>$INVLOGFILENAME
                     echo OR                                       >>$INVLOGFILENAME
                     echo $LOCAL_INVENTORY_FILE file not found !!! >>$INVLOGFILENAME
                 fi
                  echo "************************" >>$INVLOGFILENAME
;;
   esac ;
done < ${ORACLE_CENTRAL_INVENTORY}/${INVFILE}


# Printing progress bar
echo -n .
echo



#echo "Please zip following file(s) and upload to SR"
#echo "$LOGZIP"
#echo "$LOGFILENAME"
#echo "$INVLOGFILENAME"
#echo "${LOGDIR}/local_${LCOMP}"
#echo "${LOGDIR}/local_${LINV}"
#echo "${LOGDIR}/central_${CINV}"
#echo "${LOGDIR}/central_${CCOMP}"

$ZIP -q -j $LOGDIR/$OPATCHZIP $LOGZIP $LOGFILENAME $INVLOGFILENAME ${LOGDIR}/${ORACLEHOMENAME}_local_${LCOMP} ${LOGDIR}/${ORACLEHOMENAME}_local_${LINV} ${LOGDIR}/${ORACLEHOMENAME}_central_${CINV} ${LOGDIR}/${ORACLEHOMENAME}_central_${CCOMP} ${LOGDIR}/${ORACLEHOMENAME}_local_oraclehomeproperties.xml

echo "Please upload $LOGDIR/$OPATCHZIP file to SR"
echo 
echo "After uploading the file, you can clean up $LOGDIR"
