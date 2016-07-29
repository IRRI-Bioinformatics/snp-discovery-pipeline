#!/usr/bin/perl -w
use strict;

my $file=$ARGV[0];
my $disk=$ARGV[1];
my $analysis_dir="";
my $input_dir="";
my $reference_dir="";
my $scripts_dir="";
my $output_dir="";
my $software_dir="";
my $gatk="";
my $tmp_dir="";
my $email="";
my $genome="";
my $tabix="";
my $bgzip="";
my $partition="";
my $fp = 'config';
open my $info, $fp or die "Could not open $fp: $!";

#get values from the config file
while(my $line = <$info>){
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
	elsif($line =~ m/gatk/){
                $gatk=(split '=', $line)[-1];
                chomp($gatk);
        }
	elsif($line =~ m/software_dir/){
                $software_dir=(split '=', $line)[-1];
                chomp($software_dir);
        }
	elsif($line =~ m/tmp_dir/){
                $tmp_dir=(split '=', $line)[-1];
                chomp($tmp_dir);
        }
	elsif($line =~ m/bgzip/){
                $bgzip=(split '=', $line)[-1];
                chomp($bgzip);
        }
        elsif($line =~ m/tabix/){
                $tabix=(split '=', $line)[-1];
                chomp($tabix);
        }
	elsif($line =~ m/partition/){
                $partition=(split '=', $line)[-1];
                chomp($partition);
        }
}
close $fp;

open FILE, $file or die $!;
while (my $line=readline*FILE){
	$line=~/(.*):(.*)/;
	$genome=$1;	
	my $outfile="$analysis_dir/$disk/$genome/$genome"."-bam2vcf.slurm";

	my $execute="$analysis_dir/$disk/submit_bam2vcf_slurm.sh";
	open EXE, ">>", $execute or die $!;
	print EXE "#!/bin/bash\n";
	print EXE "sbatch $outfile\n";
	print EXE "sleep 10m\n";
	close EXE;

	open OUT, ">", $outfile or die $!;
	print OUT "#!/bin/bash\n";
	print OUT "\n";
	print OUT "#SBATCH -J ".$genome."-bam2vcf\n";
	print OUT "#SBATCH -o ".$genome."-bam2vcf.%j.out\n";
	print OUT "#SBATCH --cpus-per-task=8\n";
	print OUT "#SBATCH --partition=$partition\n";
	print OUT "#SBATCH -e ".$genome."-bam2vcf.%j.error\n";
	print OUT "#SBATCH --mail-user=$email\n";
	print OUT "#SBATCH --mail-type=ALL\n";
	print OUT "#SBATCH --requeue\n";
	#print OUT "#SBATCH -N 3\n";
	print OUT "\n";
	print OUT "module load python/2.7.11\n";
	print OUT "module load jdk\n";
	print OUT "module load samtools/1.0-intel\n";
	print OUT "\n";
	print OUT "python $scripts_dir/bam2vcf.py -b $output_dir/$genome/*.merged.bam -r $reference_dir -g $gatk -t $tmp_dir -z $bgzip -x $tabix\n";	
	print OUT "mv $genome-mergebam.*.error $genome-mergebam.*.out $genome-bam2vcf.*.error $genome-bam2vcf.*.out $analysis_dir/$disk/$genome/logs";
	close OUT;
}
close FILE;	
