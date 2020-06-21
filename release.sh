#!/bin/sh

files=$(ls docs/)
for file in $files
do
	[ -f docs/$file ] &&  sed -r -e 's/\((.*)\.jpg\)/\(\/assets\/\1\.jpg\)/g'  docs/$file > _posts/`date -r docs/$file +%Y-%m-%d`-$file
	[ -d docs/$file ] && cp -rf docs/$file ./assets/
done

bundle update github-pages
