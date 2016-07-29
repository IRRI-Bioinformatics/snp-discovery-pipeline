#!/usr/bin/python

import sys, re, getopt, os, subprocess

def main(argv):

    #get arguments
    try:
        opts, args = getopt.getopt(
            argv,
            "hb:r:g:t:z:x:",
            ["bam=", "ref=", "gatk=", "temp=", "bgzip", "tabix"])
    except getopt.GetoptError:
        print 'bam2vcf.py ' + \
                '-b <BAM file> ' + \
                '-r <reference> ' + \
                '-g <gatk> ' + \
                '-t <temp_dir> ' + \
                '-z <bgzip> ' + \
                '-x <tabix>'
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print 'bam2vcf.py ' + \
                    '-b <BAM file> ' + \
                    '-r <reference> ' + \
                    '-g <gatk> ' + \
                    '-t <temp_dir> ' + \
                    '-z <bgzip> ' + \
                    '-x <tabix>'
            sys.exit()
        elif opt in ("-b", "--bamfile"):
            bam = arg
        elif opt in ("-r", "--reference"):
            reference = arg
        elif opt in ("-g", "--gatk"):
            gatk = arg
        elif opt in ("-t", "--temp_dir"):
            temp_dir = arg
        elif opt in ("-z", "bgzip"):
            bgzip = arg
        elif opt in ("-x", "tabix"):
            tabix = arg
               
    vcf = bam.replace('merged.bam', 'vcf')
    
    subprocess.call(['java', '-Xmx8g',
            '-Djava.io.tmpdir=' + temp_dir,
           '-jar', gatk,
            '-T', 'UnifiedGenotyper',
            '-R', reference,
            '-I', bam,
            '-o', vcf,
            '-glm', 'BOTH',
            '-mbq', '20',
            '-gt_mode', 'DISCOVERY',
            '-out_mode', 'EMIT_ALL_SITES',
            '-nt', '8'])

    vcfgz = vcf.replace('vcf', 'vcf.gz')
    subprocess.call([bgzip, vcf])
    subprocess.call([tabix, vcfgz])

if __name__ == "__main__":
    main(sys.argv[1:])
