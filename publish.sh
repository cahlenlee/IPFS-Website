#!/bin/bash

echo "BUILD SITE"
cd ./jekyll
mv ./_site/files/videos ../
rsync -avr --delete ./files/videos/ ../videos/
bundle exec jekyll build --quiet
mv ../videos/ ./_site/files/

echo "SITE TO IPFS"
ipfs name publish "$(ipfs add -Q -r _site)" > /dev/null
