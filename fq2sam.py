#!/usr/bin/python

import sys, getopt, re, os, subprocess

def main(argv):

    #define variables
    bwa_threads = ''
    reference = ''
    read_pair1 = ''
    output_dir = ''
    #bwa_dir = '/home1/02818/jdetras/software/bwa-0.7.10/'

    #get arguments
    try:
        opts, args = getopt.getopt(
            argv,
            "hr:p:o:t:",
            ["ref=","read1=","out=","thread="])
    except getopt.GetoptError:
        print 'fq2sam.py ' + \
                '-r <reference> ' + \
                '-p <read_pair1> ' + \
                '-o <output_dir> ' + \
                '-t <bwa_threads>'
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print 'fq2sam.py ' + \
                    '-r <reference> ' + \
                    '-p <read_pair1> ' + \
                    '-o <output_dir> ' + \
                    '-t <bwa_threads>' 
            sys.exit()
        elif opt in ("-r", "--ref"):
            reference = arg
        elif opt in ("-p", "--read1"):
            read_pair1 = arg
        elif opt in ("-o", "--output_dir"):
            output_dir = arg
        elif opt in ("-t", "--bwa_threads"):
            bwa_threads = arg

    #get read pair names and sam assignment
    read_pair2 = read_pair1.replace("1.fq.gz", "2.fq.gz")
    sam = read_pair1.replace("_1.fq.gz", ".sam")

    #extract directories and sam filename
    split_dir = re.search(r'(.*)/(.*)/(.*sam)', sam, re.M)
    if split_dir:
        input_dir = split_dir.group(1)
        genome_dir = split_dir.group(2)
        sam = split_dir.group(3)
    else:
        print "Nothing found!"

    #output directory check
    output_path = output_dir + '/' + genome_dir
    #output_path = output_dir
    #if not os.path.exists(output_path):
    #    os.makedirs(output_path)

    #command for alignment
    align = 'bwa mem -M -t ' + \
            bwa_threads + ' ' + \
            reference + ' ' + \
            read_pair1 + ' ' + \
            read_pair2 + ' ' + \
            '>' + ' ' + \
            output_path + \
            '/' + \
            sam
    #print align
    #execute command
    os.system(align)

if __name__ == "__main__":
    main(sys.argv[1:])
