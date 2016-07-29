#!/bin/bash
conf=`grep -n "input_dir=" config`
input_dir=${conf##*=}
conf=`grep -n "disk=" config`
disk=${conf##*=}
#remove previous input.info
rm input.info 

#create new input.info
#list all genomes with no of reads
for genome in `ls -d $input_dir/*`; do
	count=`ls $genome | wc -l`
	echo ${genome##*/}:$count >> input.info
done
