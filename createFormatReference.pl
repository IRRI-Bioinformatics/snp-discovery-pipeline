#!/usr/bin/perl -w
use strict;

my $reference_dir="";
my $scripts_dir="";
my $picard="";
my $email="";
my $partition="";
my $dictionary_out="";
my $regex=".fa";
my $dict=".dict";
my $fp = 'config';

#get values from config file
open my $info, $fp or die "Could not open $fp: $!";

while(my $line=<$info>){
        if($line =~ m/scripts_dir=/){
                $scripts_dir=(split '=', $line)[-1];
                chomp($scripts_dir);
        }
        elsif($line =~ m/reference_dir=/){
                $reference_dir=(split '=', $line)[-1];
                chomp($reference_dir);
		$dictionary_out=$reference_dir;
		$dictionary_out=~ s/$regex/$dict/g;
        }
        elsif($line =~ m/picard=/){
                $picard=(split '=', $line)[-1];
                chomp($picard);
        }
        elsif($line =~ m/email=/){
                $email=(split '=', $line)[-1];
                chomp($email);
        }
	elsif($line =~ m/partition=/){
                $partition=(split '=', $line)[-1];
                chomp($partition);
        }

}
close($fp);
#create "format.sh" to format reference
my $outfile="$scripts_dir/format.sh";

open OUT, ">", $outfile or die $!;
print OUT "#!/bin/bash\n";
print OUT "\n";
print OUT "#SBATCH -J format_reference\n";
print OUT "#SBATCH -o format_reference.%j.out\n";
print OUT "#SBATCH --partition=$partition\n";
print OUT "#SBATCH -e format_reference.%j.error\n";
print OUT "#SBATCH --mail-user=$email\n";
print OUT "#SBATCH --mail-type=begin\n";
print OUT "#SBATCH --mail-type=end\n";
print OUT "#SBATCH --requeue\n";
#print OUT "#SBATCH -N 3\n";
print OUT "formatted=1\n";
print OUT "\n"; 
print OUT "module load samtools/1.0-intel\n";
print OUT "module load bwa/0.7.10-intel\n";
print OUT "module load jdk\n";
print OUT "\n";

#checks if reference has already been formatted
print OUT "if [ -f $reference_dir.amb -a -f $reference_dir.ann -a -f $reference_dir.bwt -a -f $reference_dir.fai -a -f $reference_dir.pac -a -f $reference_dir.sa -a -f $dictionary_out ]; then\n";
print OUT "formatted=0\n";
print OUT "fi\n\n";

#format if not yet formatted	
print OUT "if [ \"\$formatted\" -eq 1 ]; then\n";
print OUT "bwa index -a is $reference_dir\n\n";
print OUT "java -Xmx8g -jar $picard/CreateSequenceDictionary.jar REFERENCE=$reference_dir OUTPUT=$dictionary_out\n\n";
print OUT "samtools faidx $reference_dir\n";
print OUT "fi";

close OUT;
