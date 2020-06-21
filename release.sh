#!/bin/bash

workDir=$(pwd)

GeneratePost() {
	local file=$1
	local categiory=$2
	fname="$(basename -- $file)"
	post=$workDir/_posts/`date -r $file +%Y-%m-%d`-$fname

	[ -f $file ] && \
		echo "---\ncategories: $categiory\n---\n" > $post && \
		sed -r -e 's/\((.*)\.jpg\)/\(\/assets\/\1\.jpg\)/g'  $file >> $post
	[ -d $file ] && [ -z "${file##*image*}" ] && { cp -rf $file ./assets/ ; return; }

	if [ -d $file ]; then
		files=$(ls $file/)
		for f in $files
		do
			GeneratePost $file/$f $(basename -- $file)
		done
	fi

}

for file in $(ls notepad/)
do
	GeneratePost notepad/$file "General"
done

bundle update github-pages

bundle exec jekyll serve
