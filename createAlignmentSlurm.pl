#!/usr/bin/perl -w
use strict;
use warnings;

#define variables
my $file=$ARGV[0]; #input file containing genome: fastq pair count  (eg. IRIS_313-9939: 12)
my $disk=$ARGV[1]; #directory of the fastq files (eg. 07)
my $analysis_dir="";
my $input_dir="";
my $reference_dir="";
my $scripts_dir="";
my $output_dir="";
my $genome="";
my $count="";
my $email="";
my $partition="";
my $fp = 'config';
open my $info, $fp or die "Could not open $fp: $!";

#get values from the config file
while( my $line = <$info>)  {   
	if ($line =~ m/analysis_dir/) {
		$analysis_dir=(split '=', $line)[-1];
		chomp($analysis_dir);
	}
	elsif($line =~ m/input_dir/){
		$input_dir=(split '=', $line)[-1];
		chomp($input_dir);
	}
	elsif($line =~ m/reference_dir/){
		$reference_dir=(split '=', $line)[-1];
		chomp($reference_dir);
	}
	elsif($line =~ m/scripts_dir/){
		$scripts_dir=(split '=', $line)[-1];
		chomp($scripts_dir);
	}    
	elsif($line =~ m/output_dir/){
		$output_dir=(split '=', $line)[-1];
		chomp($output_dir);
	}
	elsif($line =~ m/email/){
		$email=(split '=', $line)[-1];
		chomp($email);
	}
	elsif($line =~ m/partition/){
                $partition=(split '=', $line)[-1];
                chomp($partition);
        }
}
close($fp);

open FILE, $file or die $!;
while (my $line=readline*FILE){
	$line=~/(.*):(.*)/; #get the genome/accession/variety name and the fastq pair count
	$genome=$1;
	$count=$2;
	$count=$count/2; #divide by half to get variable for job array limit	

	#make individual directory for each genome and put slurm script in that directory
	system("mkdir $analysis_dir/$disk/$genome");
	system("mkdir $output_dir/$genome");
	my $outfile="$analysis_dir/$disk/$genome/$genome"."-fq2sam.slurm";
	
	#create a submit shell script containing the slurm script for each genome
	#with a sleep of 60s in between job submission to prevent timeout
	my $execute="$analysis_dir/$disk/submit_slurm.sh";
	open EXE, ">>", $execute or die $!;
	print EXE "#!/bin/bash\n";
	print EXE "sbatch $outfile\n";
	print EXE "sleep 10m\n";
	close EXE;
	
	#create the slurm script for each genome
	open OUT, ">", $outfile or die $!;
	print OUT "#!/bin/bash\n";
	print OUT "\n";
	print OUT "#SBATCH -J ".$genome."-fq2sam\n";
	print OUT "#SBATCH -o ".$genome."-fq2sam.%j.out\n";
	#print OUT "#SBATCH -n 1\n";
	print OUT "#SBATCH --cpus-per-task=8\n"; #use this for multithreading 	
	print OUT "#SBATCH --array=1-".$count."\n";
	print OUT "#SBATCH --partition=$partition\n";
	print OUT "#SBATCH -e ".$genome."-fq2sam.%j.error\n";
	print OUT "#SBATCH --mail-user=$email\n";
	print OUT "#SBATCH --mail-type=begin\n";
	print OUT "#SBATCH --mail-type=end\n";
	print OUT "#SBATCH --requeue\n";
	#print OUT "#SBATCH -N 3\n"
	print OUT "\n";
	print OUT "module load bwa/0.7.10-intel\n";
	print OUT "module load python/2.7.10\n";
	print OUT "\n";
	#get the first pair of a fastq file and assign for use
	#print OUT "mkdir $output_dir"
	print OUT "filename=`find $input_dir/$genome -name \"*1.fq.gz\" | tail -n +\${SLURM_ARRAY_TASK_ID} | head -1`\n";
	print OUT "\n";
	#execute the command
	print OUT "python $scripts_dir/fq2sam.py -r $reference_dir -p \$filename -o $output_dir -t \$SLURM_CPUS_PER_TASK\n";	
	close OUT;
}
close FILE;
