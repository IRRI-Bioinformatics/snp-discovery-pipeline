#!/usr/bin/perl -w
use strict;

#define variables
my $file=$ARGV[0]; #input file containing genome: fastq pair count  (eg. IRIS_313-9939: 12)
my $disk=$ARGV[1]; #directory of the fastq files (eg. 07)
my $analysis_dir="";
my $input_dir="";
my $reference_dir="";
my $scripts_dir="";
my $output_dir="";
my $software="";
my $picard="";
my $gatk="";
my $jvm="8g";
my $tmp_dir="";
my $genome="";
my $count="";
my $email="";
my $partition="";
my $fp= 'config';

#get values from the config file
open my $info, $fp or die "Could not open $fp: $!";

while( my $line = <$info>){
	if($line =~ m/analysis_dir/){
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
	elsif($line =~ m/tmp_dir/){
		$tmp_dir=(split '=', $line)[-1];
		chomp($tmp_dir);
	}
	elsif($line =~ m/picard/){
		$picard=(split '=', $line)[-1];	
		chomp($picard);
	}
	elsif($line =~ m/gatk/){
		$gatk=(split '=', $line)[-1];
		chomp($gatk);		
	}
	elsif($line =~ m/email/){
		$email=(split '=', $line)[-1];
		chomp($email);
	}
	elsif($line =~ m/software_dir/){
		$software=(split '=', $line)[-1];
		chomp($software);
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
	
	system("mkdir $analysis_dir/$disk/$genome/logs");
	my $outfile="$analysis_dir/$disk/$genome/$genome"."-sam2bam.slurm";
	
	#create a submit shell script containing the slurm script for each genome
	#with a sleep of 60s in between job submission to prevent timeout
	my $execute="$analysis_dir/$disk/submit_sam2bam_slurm.sh";
	open EXE, ">>", $execute or die $!;
	print EXE "#!/bin/bash\n";
	print EXE "sbatch $outfile\n";
	print EXE "sleep 10m\n";
	close EXE;
	
	#create the slurm script for each genome
	open OUT, ">", $outfile or die $!;
	print OUT "#!/bin/bash\n";
	print OUT "\n";
	print OUT "#SBATCH -J ".$genome."\n";
	print OUT "#SBATCH -o ".$genome."-sam2bam.%j.out\n";
	print OUT "#SBATCH --cpus-per-task=6\n"; #use this for multithreading 	
	print OUT "#SBATCH --array=1-".$count."\n";
	print OUT "#SBATCH --partition=$partition\n";
	print OUT "#SBATCH -e ".$genome."-sam2bam.%j.error\n";
	print OUT "#SBATCH --mail-user=$email\n";
	print OUT "#SBATCH --mail-type=begin\n";
	print OUT "#SBATCH --mail-type=end\n";
	print OUT "#SBATCH --requeue\n";
	#print OUT "#SBATCH -N 3\n";
	print OUT "\n";
	print OUT "module load python\n";
	print OUT "module load jdk\n";
	print OUT "\n";
	#get the first pair of a fastq file and assign for use
	print OUT "filename=`find $output_dir/$genome -name \"*.sam\" | tail -n +\${SLURM_ARRAY_TASK_ID} | head -1`\n";
	print OUT "\n";
	#execute the command
	print OUT "python $scripts_dir/sam2bam.py -s \$filename -r $reference_dir -p $picard -g $gatk -j $jvm -t $tmp_dir\n";
	print OUT "mv $genome-fq2sam.*.error $genome-fq2sam.*.out $analysis_dir/$disk/$genome/logs";	
	close OUT;
}
close FILE;
