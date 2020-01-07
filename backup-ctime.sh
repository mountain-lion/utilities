#!/bin/bash
#title          :backup-ctime.sh
#description    :This script recursively goes through the file names of all the files in the specified backup directory
#		 and finds out files which were created or modified in the last number of specifid days (in integer) in the arguments. 
#		 Furthermore, it creats GZIP tar of the created and modified files. While copying it maintains the directory structure/tree as the file was in the 
#		 backup folder and also excludes ./.cache/* if present.
#                Note: Backup of more than 30 days is not supported currently.
#author         :Sujoy Sarkar (s.sujoy@gmail.com)
#date           :20200106
#version        :1.0    
#usage          :./:backup-ctime.sh [backup directory] [No. of days of backup]
#notes          :This script comes with absolutely NO WARRANTY whatsover. 
#		 User of the script is at his/her own risk for all the consequences of running this script.    
#bash_version   :4.4.12(1)-release (x86_64-redhat-linux-gnu)
#============================================================================

if [[ $# -ne 2 && $1 == "-help" ]]
then
    echo "$0 [source directory] [No. of days of backup]"
    echo "$0 -help for help/usage"
    exit 0
fi

if [ $# -lt 2 ]
then
  echo "$0 : Insufficient Arguments"
  echo "$0 [backup directory] [No. of days of backup]"
  echo "$0 -help for help/usage"
  exit 0
fi

if [ ! -d "$1" ]
then
    echo "Error: Backup Directory $1 does not exist"
    exit 1
fi

if [ "$2" -gt 30 ]
then
    echo "Error: Backup of more than 30 days not supported"
    exit 1
fi

#find . -ctime -1 -ls -print0|awk '{for(i=15;i<=NF;i++){printf "%s ", $i}; printf "\n"}'|xargs tar cvfz modified24hrs.tar.gz --exlcude=./.cache/*


#find . -ctime -2 -type f -ls|awk '{for(i=11;i<=NF;i++){printf "%s ", $i}; printf "\n"}'|xargs -p tar -cvf x.tar --exclude=./.cache/*

DIR=$1
DAYS=$2

_TAG_=`date +%s`

_FILE_=` date +%y%m%d`

find "$DIR" -ctime -"$DAYS" -type f -ls|awk '{for(i=11;i<=NF;i++){printf "%s ", $i}; printf "\n"}'|xargs -p tar -zcvf "$DAYS"_days_backup_"$_FILE_"_"$_TAG_".tar.gz --exclude="$DIR"/.cache/* --exclude="$DIR"/.recoll/*

exit 0


