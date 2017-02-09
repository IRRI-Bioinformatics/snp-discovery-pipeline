#!/usr/bin/python

import sys, getopt, subprocess, os, re
from subprocess import Popen

def main(argv):

    #get arguments
    try:
        opts, args = getopt.getopt(
            argv,
            "hb:o:",
            ["bam=", "outputdir="])
    except getopt.GetoptError:
        print 'bamvalidator.py ' + \
                '-b <BAM file> ' + \
                '-o <output dir>'
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print 'bamvalidator.py ' + \
                    '-b <BAM file> ' + \
                    '-o <output dir>'
            sys.exit()
        elif opt in ("-b", "--bamfile"):
            bam = arg
        elif opt in ("-o", "--outputdir"):
            output_dir = arg
    bam = bam.rstrip('\n')
    split_dir = re.search(r'(.*)/(.*)/(.*bam)', bam, re.M)
    if split_dir:
        input_dir = split_dir.group(1)
        genome = split_dir.group(2)
        bamfile = split_dir.group(3)
    else:
        print "Nothing found!"

    bam_out = bamfile.replace('bam', 'txt')
    out = open(output_dir + '/' + bam_out, 'w')
    run = subprocess.call(['bam', 'validate', '--in', bam, '--verbose'], stdout=out, stderr=subprocess.STDOUT)
    print "Input:" + bam

if __name__ == "__main__":
    main(sys.argv[1:])
