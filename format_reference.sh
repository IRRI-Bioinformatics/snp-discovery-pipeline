#	Filename: format_reference.sh
#	Description: formats the reference genome
#	Created By: Jeffrey Detras
#	Modified By: Rosechelle Joy Oraa
#!/bin/bash

#SBATCH -J format_reference
#SBATCH -o format_reference.%j.out
#SBATCH -e format_reference.%j.error
#SBATCH --partition=batch
#SBATCH --mail-user=rosechellejoyoraa@gmail.com
#SBATCH --mail-type=ALL
#SBATCH --requeue

conf=`grep -n "reference_dir" config`
reference=${conf##*=}
conf=`grep -n "bwa" config`
bwa_index=${conf##*=}
conf=`grep -n "picard" config`
create_dictionary=${conf##*=}
conf=`grep -n "samtools" config`
samtools_faidx=${conf##*=}
dictionary_output=${reference/.fa/.dict}

module load bwa/0.7.10-intel
module load samtools/1.0-intel
module load jdk

#Index reference (bwa)
$bwa_index $home/$reference

#Create sequence dictionary (picard)
java -Xmx8g -jar $create_dictionary/CreateSequenceDictionary.jar REFERENCE=$reference OUTPUT=$dictionary_output

#Create fasta index (samtools)
$samtools_faidx $reference
