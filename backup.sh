#!/bin/bash

# This checks if the number of arguments is correct
# If the number of arguments is incorrect ( $# != 2) print error message and exit
if [[ $# != 2 ]]
then
  echo "backup.sh target_directory_name destination_directory_name"
  exit
fi

# This checks if argument 1 and argument 2 are valid directory paths
if [[ ! -d $1 ]] || [[ ! -d $2 ]]
then
  echo "Invalid directory path provided"
  exit
fi

# Set Variables
targetDirectory=$1
destinationDirectory=$2

# Display Variables Value
echo "Target Directory: $targetDirectory"
echo "Destination Directory: $destinationDirectory"

# Take the Current Time
currentTS=$(date +%s)

# Set Value for backupfile
backupFileName="backup-$(date +%Y-%m-%d_%H-%M-%S).tar.gz"

# Take the actual path
origAbsPath=$(pwd)

# Set absolute path
cd "$destinationDirectory" 
destDirAbsPath=$(realpath "$destinationDirectory")

# Goto target directory
cd $origAbsPath
cd $targetDirectory 

# Set the limit time for which files should be checked

yesterdayTS=$(($currentTS - 86400))

declare -a toBackup #making an array

for file in $(ls -p | grep -v /) # Check all file in the current path
do

  # choose correct files
  fileTS=$(date -r "$file" +%s) 
  if ((fileTS > yesterdayTS))
  then
    toBackup+=("$file") # add correct file to the array
  fi
done

# Make an archive
if [ ${#toBackup[@]} -ne 0 ]; then
    tar -czvf $backupFileName ${toBackup[@]}
else
    echo "No file to archive."
fi

# Moving the archive to the correct path
if [ -f "$backupFileName" ]; then
    mv "$backupFileName" "$destDirAbsPath/"
    echo "Backup file $backupFileName move to $destDirAbsPath."
else
    echo "Backup file $backupFileName doesn't exist in the dictionary."
fi
