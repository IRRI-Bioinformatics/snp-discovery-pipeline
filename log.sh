#!/bin/bash

filename="input.info"
conf=`grep -n "output_dir" config`
output_dir=${conf##*=}
conf=`grep -n "disk" config`
disk=${conf##*=}
rm log.txt
while read -r line
do
	IFS=':' read -ra info <<< "$line"
	count=`ls -1 $output_dir/$info/*.vcf.gz 2>/dev/null | wc -l`
	if [ $count -eq 0 ]
	then 
	echo "$info" >> log.txt
	fi
	
done < "$filename"
