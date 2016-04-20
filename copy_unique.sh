#!/bin/bash
#title          :copy_unique.sh
#description    :This script recursively goes through the file names of all the files in the source directory
#		 and finds out files which are not present in the detination directory. 
#		 Furthermore, it copies the latest version (if multiple copies present) of the 'unique' files in 
#		 the ./unique_files folder. While copying it maintains the directory structure/tree as the file was in the 
#		 source folder and also preserve the file attributes like timestamps, permissions etc. instact.
#author         :Sujoy Sarkar (s.sujoy@gmail.com)
#date           :20160420
#version        :1.0    
#usage          :./copy_unique.sh [source directory] [destination directory]
#notes          :This script comes with absolutely NO WARRANTY whatsover. 
#		 User of the script is at his/her own risk for all the consequences of running this script.    
#bash_version   :4.2.24(1)-release
#============================================================================

if [[ $# -ne 2 && $1 == "-help" ]]
then
    echo "$0 [source directory] [destination directory]"
    echo "$0 -help for help/usage"
    exit 0
fi

if [ $# -lt 2 ]
then
  echo "$0 : Insufficient Arguments"
  echo "$0 [source directory] [destination directory]"
  echo "$0 -help for help/usage"
  exit 0
fi

if [ ! -d "$1" ]
then
    echo "Error: Source Directory $1 does not exist"
    exit 1
fi

if [ ! -d "$2" ]
then
    echo "Error: Destination Directory $2 does not exist"
    exit 1
fi

SRC=$1 
DST=$2

source_count=0
destination_count=0

#ls -lR "$DST"|awk {'print $9'} > destination_list.txt #skips portion of file names with white spaces -hence discarded
#ls -lR "$SRC"|awk {'$1=$2=$3=$4=$5=$6=$7=$8=""; print $0'} > source_list.txt #adds leading white space and hence discarded

#ls -lRt is used to sort the ls output by time (most recent first)
ls -lRt "$DST"|awk '{for(i=9;i<=NF;i++){printf "%s ", $i}; printf "\n"}' > destination_list.txt
ls -lRt "$SRC"|awk '{for(i=9;i<=NF;i++){printf "%s ", $i}; printf "\n"}' > source_list.txt
#exit 0


if [ ! -d unique_files ]
then
  mkdir unique_files
else
  rm -Rf unique_files
  mkdir unique_files
fi

export unique_count=0
export copy_count=0

while read line
   do
      match_count=$(grep -c "$line" destination_list.txt)
      if [ ${match_count} -eq 0 ]
      then
	
	file_path="$(find "$SRC" -name "$line"|head -1)"
	
	if [[ -d "$file_path" || ! -f "$file_path" ]]
	then
	    continue
	fi
	
	echo "Unique FILE=$file_path found."
	unique_count=$(expr $unique_count + 1)
	
	#prevent duplicate or multiple copies of files being copied
	is_duplicate=$(find ./unique_files -name "$line"|wc -l)
	
	if [ ${is_duplicate} -ne 0 ]
	then
	    echo "File "$file_path" already exists in unique files repository. Multiple copies are not kept"
	    continue
	fi
	
	#retain only the directory path after the SRC directory
	relative_path="$(echo ${file_path:${#SRC}})"
	relative_path=$(echo ${relative_path:0:$(expr ${#relative_path} - ${#line})})
	#echo "RELATIVE PATH=./unique_files$relative_path"
	if [ ! -d "./unique_files$relative_path" ]
	then
	    mkdir -p "./unique_files$relative_path"
	fi
	
	cp -p "$file_path" "./unique_files$relative_path"
	copy_count=$(expr $copy_count + 1)
      fi
      
   done <  source_list.txt

echo "=========================SUMMARY REPORT=========================="
echo "$unique_count Unique Files Found in $SRC directory which are missing from $DST directory"
echo "$copy_count Unique Files Copied from $SRC directory"
   
if [ -f source_list.txt ]
then
  rm -f source_list.txt
fi

if [ -f destination_list.txt ]
then
  rm -f destination_list.txt
fi

