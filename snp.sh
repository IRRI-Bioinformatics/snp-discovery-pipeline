#!/bin/bash
conf=`grep -n "analysis_dir" config`
analysis_dir=${conf##*=}
conf=`grep -n "disk" config`
disk=${conf##*=}
conf=`grep -n "input_dir" config`
input_dir=${conf##*=}
filename="input.info"
inc_pairs=false

mkdir $analysis_dir/$disk
#check if read pairs are complete
while read -r line		#read each line
do
	IFS=':' read -ra info <<< "$line" #split, get each genome
	for pair in `ls $input_dir/$info`
		do
			if [[ $pair == *"1.fq.gz"* ]]
			then
  				pair2="$input_dir/$info/${pair/1.fq.gz/2.fq.gz}"
			elif [[ $pair == *"2.fq.gz"* ]]
			then
				pair2="$input_dir/$info/${pair/2.fq.gz/1.fq.gz}"	
			fi 

			if [ ! -f $pair2 ]
			then
				echo "$pair does not have a pair"
				inc_pairs=true		
			fi
		done
done < "$filename"

if [ "$inc_pairs" = true ]	#if there are incomplete pairs
then
	exit $			#exit program
fi
perl createformat_reference.pl
format=$(sbatch format.sh)		#format reference

perl createAlignmentSlurm.pl $filename $disk		#create slurm scripts for each step
perl createBAMProcessingSlurm.pl $filename $disk
perl createMergeBAMSlurm.pl $filename $disk
perl createBAMtovcfslurm.pl $filename $disk

while read -r line			#read each line to get the genomes
do
	IFS=':' read -ra info <<< "$line" #split, get each genome
	job=`ls $analysis_dir/$disk/$info/*fq2sam.* `

	#submit *fq2sam. to the job scheduler, set format_reference as its dependency
	dep=$(sbatch --dependency=afterok:${format##* } $job)
	 
	samtobam=${job/fq2sam./sam2bam.}
	#submit its corresponding sam2bam to the job scheduler w/ fq2sam as its dependency
	sbatch --dependency=afterok:${dep##* } $samtobam
	sleep 3m        

        mergebam=${job/fq2sam./mergebam.}
	#submit *mergebam. to the job scheduler, set all sam2bam of the same genome as its dependency
	dep=$(sbatch --dependency=singleton $mergebam)

	bamtovcf=${job/fq2sam./bam2vcf.}
	#submit its corresponding bam2vcf to the job scheduler w/ mergebam as its dependency
	sbatch --dependency=afterok:${dep##* } $bamtovcf
	sleep 3m
done < "$filename"
