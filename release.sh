#!/bin/sh

files=$(ls docs/)
for file in $files
do
	cp -rf docs/$file _posts/`date +%Y-%m-%d`-$file
done

bundle update github-pages
