#!/bin/bash

#SBATCH -J format_reference
#SBATCH -o format_reference.%j.out
#SBATCH --partition=batch
#SBATCH -e format_reference.%j.error
#SBATCH --mail-user=rosechellejoyoraa@gmail.com
#SBATCH --mail-type=begin
#SBATCH --mail-type=end
#SBATCH --requeue
formatted=1

module load samtools/1.0-intel
module load bwa/0.7.10-intel
module load jdk

if [ -f /home/rosechelle.oraa/reference/MH63RS1.LNNK00000000.fa.amb -a -f /home/rosechelle.oraa/reference/MH63RS1.LNNK00000000.fa.ann -a -f /home/rosechelle.oraa/reference/MH63RS1.LNNK00000000.fa.bwt -a -f /home/rosechelle.oraa/reference/MH63RS1.LNNK00000000.fa.fai -a -f /home/rosechelle.oraa/reference/MH63RS1.LNNK00000000.fa.pac -a -f /home/rosechelle.oraa/reference/MH63RS1.LNNK00000000.fa.sa -a -f /home/rosechelle.oraa/reference/MH63RS1.LNNK00000000.dict ]; then
formatted=0
fi

if [ "$formatted" -eq 1 ]; then
bwa index -a is /home/rosechelle.oraa/reference/MH63RS1.LNNK00000000.fa

java -Xmx8g -jar /home/rosechelle.oraa/software/picard-tools-1.119/CreateSequenceDictionary.jar REFERENCE=/home/rosechelle.oraa/reference/MH63RS1.LNNK00000000.fa OUTPUT=/home/rosechelle.oraa/reference/MH63RS1.LNNK00000000.dict

samtools faidx /home/rosechelle.oraa/reference/MH63RS1.LNNK00000000.fa
fi