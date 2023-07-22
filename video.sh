#!/bin/bash

echo "PROCESS ARGUMENTS"
VIDEOIN="${1}"
IMAGEIN="${2}"
TITLE="${3}"
DESC="${4}"
LURL="${5}"
LNAME="${6}"
TAG1="${7}"
PROCESS="${8}"

echo "SET GLOBAL VARIABLES"
YEAR="$(date "+%Y")"
MONTH="$(date "+%m")"
DAY="$(date "+%d")"
HOUR="$(date "+%H")"
MINUTE="$(date "+%M")"
SECOND="$(date "+%S")"
TNAME="CahlenLee_""$YEAR""$MONTH""$DAY""_""$TITLE"
FNAME=$(echo "$TNAME" | sed 's/ //g')
URL=$(echo "${TITLE,,}" | sed 's/ /-/g')
HNAME="$YEAR""-""$MONTH""-""$DAY""-""$URL"
FILE="./${HNAME}.html"
VIDEOOUT="./jekyll/files/videos/$YEAR/$MONTH/$FNAME/$FNAME.mp4"
IMAGEOUT="./jekyll/files/videos/$YEAR/$MONTH/$FNAME/$FNAME.jpg"
FOLDEROUT="./jekyll/files/videos/$YEAR/$MONTH/$FNAME"

echo "CREATE DIRECTORY"
mkdir ./jekyll/files/videos/"$YEAR"
mkdir ./jekyll/files/videos/"$YEAR"/"$MONTH"
mkdir ./jekyll/files/videos/"$YEAR"/"$MONTH"/"$FNAME"

echo "PROCESS FILES"
if  [[ $PROCESS = "1" ]]; then
    ffmpeg -i "$VIDEOIN" -c:v libx264 -r 24 -vf scale=854:480 -b:v 999k -c:a aac -ac 1 -b:a 128k -movflags faststart -af "dynaudnorm=f=33:g=65:p=0.66:m=33.3" -n "$VIDEOOUT"
    jpegoptim -S 96 "$IMAGEIN"
    cp "$IMAGEIN" "$IMAGEOUT"
else
    cp $VIDEOIN $VIDEOOUT
    cp $IMAGEIN $IMAGEOUT
fi
VIDEOPATH=$(realpath "$VIDEOOUT")

echo "GET IPFS CID"
FLDCID=$(ipfs add -r -Q $FOLDEROUT)
JPGCID=$(ipfs add --quiet $IMAGEOUT)
MP4CID=$(ipfs add --quiet $VIDEOOUT)

echo "WRITE HTML"
/bin/cat <<EOM >$FILE
---
layout: post
title:  "$TITLE"
date:   $YEAR-$MONTH-$DAY $HOUR:$MINUTE:$SECOND -0600
tags: $TAG1
categories: Blog
permalink: /$URL/
image: /files/videos/$YEAR/$MONTH/$FNAME/$FNAME.jpg
video: /files/videos/$YEAR/$MONTH/$FNAME/$FNAME.mp4
description: $DESC
---
<video controls preload="none" width="100%" height="auto" poster="{{ page.image }}" src="{{ page.video }}"></video>
<hr>
<p>{{ page.description }}</p>
<!--more-->
<p>
<a href="$LURL">$LNAME</a>
</p>
EOM

echo "BUILD SITE"
mv ${HNAME}.html ./jekyll/_posts
cd ./jekyll
mv ./_site/files/videos ../
rsync -avr --delete ./files/videos/ ../videos/
bundle exec jekyll build --quiet
mv ../videos/ ./_site/files/

echo "SITE TO IPFS"
ipfs name publish "$(ipfs add -Q -r _site)" > /dev/null

echo "ALL DONE!"
