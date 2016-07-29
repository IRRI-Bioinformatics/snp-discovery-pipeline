#!/usr/bin/perl -w
use strict;

my $starttime=localtime();
print "Start time: $starttime\n";
#directories

my $refDir="";
my $softwareDir="";
my $refSeq=$ARGV[2]; #"os.ir64.cshl.draft.1.0.scaffold.fa";
my $refGenome=$ARGV[3]; #"indica/ir64";
my $samtools="";
my $gatk="";
my $javaMemory="-Xmx8g";
my $vcfOutMode="EMIT_ALL_SITES";

my $outputDir=$ARGV[0];
my $rawDir=$ARGV[1];

my $fp = 'config';
open my $info, $fp or die "Could not open $fp: $!";

while( my $line = <$info>)  {
        if ($line =~ m/reference_dir/) {
                $refDir=(split '=', $line)[-1];
                chomp($refDir);           
        }
	elsif($line =~ m/gatk/){
                $gatk=(split '=', $line)[-1];
                chomp($gatk);           
        }
	elsif($line =~ m/software_dir/){
                $softwareDir=(split '=', $line)[-1];
                chomp($softwareDir);
        }
	elsif($line =~ m/samtools/){
                $samtools=(split '=', $line)[-1];
                chomp($samtools);
        }
}
close($fp);


#print "Removing intermdediate files...\n";
#system("rm $outputDir/$rawDir/*.sam");
#print "SAM files removed.\n";
#system("rm $outputDir/$rawDir/*.fxmt.ba*");
#print "Fixmate BAM files removed.\n";
#system("rm $outputDir/$rawDir/*.mkdup.ba*");
#print "Mark duplicate BAM files removed.\n";
#system("rm $outputDir/$rawDir/*.addrep.ba*");
#print "Add replaced BAM files removed.\n";
#system("rm $outputDir/$rawDir/*.metrics");
#print "Metrics files removed.\n";
#system("rm $outputDir/$rawDir/*.list");
#print "List files removed.\n";

my $mergeBam="$rawDir.merged.bam";
if (-e "$outputDir/$rawDir/$mergeBam"){
	print "$mergeBam already exists.\n";
} else {
	print "Merging realigned BAM files...\n";
	system("samtools merge $outputDir/$rawDir/$mergeBam $outputDir/$rawDir/*.realign.bam");
	print "Realigned BAM files merged into $mergeBam.\n";
}
if (-e "$outputDir/$rawDir/$mergeBam.bai"){
	print "$mergeBam.bai already exists.\n";
} else {
	system("samtools index $outputDir/$rawDir/$mergeBam");
	print "$mergeBam indexed.\n";
}
#my $snp_calling_output="$rawDir.vcf";
#print "Calling variants...\n";
#system("java $javaMemory -XX:ParallelGCThreads=2 -jar $softwareDir/$gatk/GenomeAnalysisTK.jar -T UnifiedGenotyper -nt 10 -R $refDir/$refGenome/$refSeq -I $outputDir/$rawDir/$mergeBam -o $outputDir/$rawDir/$snp_calling_output -glm BOTH -mbq 20 --genotyping_mode DISCOVERY -out_mode $vcfOutMode");

#print "Compressing VCF file...\n";
#system("/home/jdetras/software/samtools-1.0/htslib-1.0/./bgzip $outputDir/$rawDir/$snp_calling_output");

my $endtime=localtime();
print "End time: $endtime. Done.\n";
exit();
