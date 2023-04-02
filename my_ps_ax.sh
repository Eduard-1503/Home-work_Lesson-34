#!/bin/bash

function GetCommandName ()
{
  if [ -e /proc/$1/cmdline ]
  then
#    CMD=`tr '\0' ' ' < /proc/$1/cmdline`
    CMD=`cat /proc/$1/cmdline  | tr -d '\00' | sed 's/\./\ /g' | awk '{print $1}'`
  fi
}

function GetTTY ()
{
  if [ -e /proc/$1/fd ]
  then
    TTY=`ls -l /proc/$1/fd | grep dev | grep -v null | head -n1 | awk '{print $NF}' | sed 's/\//\ /g' | awk '{print $2, $3}' | sed 's/\ /\//g'`
    if [ -z $TTY ]
    then
      TTY='  ?  '
    fi
  else
    TTY='  ?  '
  fi
}

function GetTotalCpu () 
{
  UTIME=`cat /proc/$1/stat | awk '{print $14}'`
  STIME=`cat /proc/$1/stat | awk '{print $15}'`
  TTIME=$((UTIME + STIME))
  TTIME=$((TTIME / 100))
}

function GetStat () 
{
  if [ -e /proc/$1/status ]
  then
    STAT=`cat /proc/$1/status | grep State | awk '{print $2}'`
  fi
}

printf "%-10s %-5s %-5s %-10s %s\n" "PID" "TTY" "STAT" "TIME" "COMMAND"

PIDS=$( find /proc -maxdepth 1 -regex ".*[0-9]" | sed 's/\/proc\///' )

for PID in $PIDS 
do
  GetTTY $PID
  GetStat $PID
  GetCommandName $PID
  GetTotalCpu $PID
  printf "%-10s %-5s %-5s %02d:%02d:%02d %s\n" "$PID" "$TTY" "$STAT" "$(($TTIME / 3600))" "$((($TTIME % 3600) / 60))" "$(($TTIME % 60))" "$CMD"
done
exit 0
