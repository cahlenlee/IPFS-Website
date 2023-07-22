#!/bin/bash

echo "GO TO PROJECT FOLDER"
cd /home/cahlen/cahlen.org/

echo "GET DAY OF WEEK"
DOW=$(date +%u)

echo "PUBLISH IF EXISTS"
if [ -z "$(ls -A ./uploads/$DOW)" ]; then
   exit 1
else
   title=$(sed -n 1p ./uploads/$DOW/data.txt)
   desc=$(sed -n 2p ./uploads/$DOW/data.txt)
   lurl=$(sed -n 3p ./uploads/$DOW/data.txt)
   ldesc=$(sed -n 4p ./uploads/$DOW/data.txt)
   tag1=$(sed -n 5p ./uploads/$DOW/data.txt)
   proc=$(sed -n 6p ./uploads/$DOW/data.txt)
   video=$(readlink -f ./uploads/$DOW/*.mp4)
   image=$(readlink -f ./uploads/$DOW/*.jpg)

   echo "PUBLISH VIDEO"
   bash ./video.sh "$video" "$image" "$title" "$desc" "$lurl" "$ldesc" "$tag1" "$proc"

   echo "REMOVE FILES"
   rm -r "./uploads/$DOW/"
   mkdir "./uploads/$DOW"
fi

echo "DAILY DONE"
