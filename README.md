# snp-discovery-pipeline

The SNP discovery pipeline is used to detect variants including SNPs and indels (insertion/deletions) from next-generation sequencing (NGS) reads. The pipeline includes the following:
  
  1) Alignment: The sequence reads are aligned to the reference genome using BWA (Burrows-Wheeler Aligner) – bwa 0.7.10 http://bio-bwa.sourceforge.net/ 
  
  2) BAM Processing: A series of intermediate steps to process and prepare the BAM file for variant calling. Picard Tools is used for BAM processing – Picard Tools 1.119 http://broadinstitute.github.io/picard/ 
  
  3) Variant calling: Variants are called using the GATK Unified Genotyper – GATK 3.2-2 https://www.broadinstitute.org/gatk/ 

The pipeline is intended to work on High-Performance Computing (HPC) clusters that has SLURM as a job scheduler. However, the individual python scripts can also be used for specific steps independently. 

1. Clone repository on your working directory. 
2. Modify config file accordingly. The config file contains parameters for the directories, software and user information required to run the pipeline. 
3. Run createInput.sh to create input.info file which contains information for the genomes/lines and the number of fastq files for each genome. 
4. Run snp.sh to submit jobs that will run the pipeline. 
5. Run log.sh to check for error report. 

To see the specific commands, go to https://github.com/IRRI-Bioinformatics/snp-discovery-pipeline/wiki/How-to-run-the-pipeline.
