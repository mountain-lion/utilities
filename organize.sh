#!/bin/bash
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

if [ ! -d "$1" ]
then
    echo "Error: Source Directory $1 does not exist"
    exit 1
fi


#dir_list=($(ls -lR "$1"|egrep '^d'|awk '{for(i=9;i<=NF;i++){printf "%s ", $i}; printf "\n"}'))
#ls -lR |egrep '^d'|awk '{for(i=9;i<=NF;i++){printf "%s ", $i}; printf "\n"}'> dir_list.txt

cd "$1"

dir_list=($(ls -d */|sed 's/\///g'))


if [ $(ls *.jpg 2>/dev/null |wc -l) -gt 0 ] || [ $(ls *.JPG 2>/dev/null |wc -l) -gt 0 ]
then
    for x in *.jpg *.JPG; do
            echo -ne "."
            d=$(exiftool -p '$DateTimeOriginal' "$x"|cut -f 1 -d " "|sed 's/[: ]/-/g')
            #d=$(exiftool -p '$DateTimeOriginal' "$x" |sed 's/[: ]//g')
            if [ -z "$d" ]
            then
                d=$(exiftool -p '$CreateDate' "$x"|cut -f 1 -d " "|sed 's/[: ]/-/g')
            fi
            #d=$(date -r "$x" +%Y-%m-%d)
            d=$(echo ${d:0:$(expr ${#d} - 3)})
            
            
            parent_dir=$(basename "${PWD}")
            
            if [ ! -z "$d" ]
            then
                if [ ! "$d" == "$parent_dir" ]
                then
                    if [ ! -d "$d" ]
                    then
                        #echo "Make Directory '$d'"
                        mkdir -p "$d"
                    fi
                    mv "$x" "$d/"
                    echo -ne "|"
                else
                    echo "Most likely the directory ["$d"] is already organized. Hence, skipping this step of organizing ["$x"]... "
                fi
            fi
    done
fi
#echo "Changing back to script directory"
cd - >/dev/null

#echo "Present working directory before recursion : ${PWD}"


for folder in ${dir_list[@]}; do
    echo "Organizing Folder '${folder}'. Please wait ... "
    folder_path=`find "$1" -type d -name "${folder}"|head -1`
    ./$0 "$folder_path"
    #subfolder_list=($(find "$1" -type d -name "${folder}"))
    #./$0 "${subfolder_list[0]}"
    #for each_subfolder in ${subfolder_list[@]}; do
        #./$0 "$each_subfolder"
    #done

done

IFS=$SAVEIFS

exit 0

