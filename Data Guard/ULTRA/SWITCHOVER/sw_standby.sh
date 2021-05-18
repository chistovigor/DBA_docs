#!/bin/bash
echo SQLplus started at `date`
sqlplus / as sysdba < sw_standby.sql
