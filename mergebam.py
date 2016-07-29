#!/usr/bin/python

import sys, getopt, re, os, subprocess

def main(argv):

    #get arguments
    try:
        opts, args = getopt.getopt(
            argv,
            "hg:",
            ["genome_dir="])
    except getopt.GetoptError:
        print 'mergebam.py ' + \
                '-g <genome_dir> ' + \
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print 'mergebam.py ' + \
                    '-g <genome_dir> ' + \
            sys.exit()
        elif opt in ("-g", "--genome_dir"):
            genome_dir = arg
    
    genome = re.search(r'(.*)/(.*)$', genome_dir, re.M)
    if genome:
        genome = genome.group(2)
    mergedbam_output = genome_dir + '/' + genome + '.bam'
   
    loadsamtools = 'module load samtools/1.0-intel' 
    os.system(loadsamtools)

    mergebam = 'samtools merge ' + \
        mergedbam_output + ' ' + \
        genome_dir + '/*.realign.bam'
    os.system(mergebam)

   
    #ind = 'samtools ind ' + \
#	mergedbam_output

    #os.system(ind)
   
    subprocess.call(['samtools', 'index', mergedbam_output]) 
	
if __name__ == "__main__":
    main(sys.argv[1:])
