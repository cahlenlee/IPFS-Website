#!/bin/bash

echo "GET USER VARIABLES"
read -p "Title: " TITLE
read -p "Description: " DESC
read -p "Link: " LURL
read -p "Link Desc: " LDESC
read -p "Tag 1: " TAG1
read -p "Publish Day: " PUB

echo "SET GLOBAL VARIABLES"
YEAR="$(date "+%Y")"
MONTH="$(date "+%m")"
DAY="$(date "+%d")"
TNAME="CahlenLee_""$YEAR""$MONTH""$DAY""_""$TITLE"
FNAME=$(echo "$TNAME"  | sed 's/ //g')
PROC=0

echo "PROCESS MP4"
for file in *.mp4
do
  ffmpeg -i "$file" -c:v libx264 -r 24 -vf scale=854:480 -b:v 999k -c:a aac -ac 1 -b:a 128k -movflags faststart -af "dynaudnorm=f=33:g=65:p=0.66:m=33.3" -n "${FNAME}.mp4"
  rm "$file"
done

echo "PROCESS JPG"
for file in *.jpg
do
  jpegoptim -S 96 "$file"
  mv "$file" "${FNAME}.jpg"
done

echo "CREATE DATA FILE"
/bin/cat <<EOM >data.txt
$TITLE
$DESC
$LURL
$LDESC
$TAG1
$PROC
EOM

echo "UPLOAD FILES"
scp -r "${FNAME}.mp4" "cahlen@cahlen.org:~/IPFS-Website/uploads/$PUB/"
scp -r "${FNAME}.jpg" "cahlen@cahlen.org:~/IPFS-Website/uploads/$PUB/"
scp -r "data.txt" "cahlen@cahlen.org:~/IPFS-Website/uploads/$PUB/"

echo "DONE"
