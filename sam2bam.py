#!/usr/bin/python

import sys, getopt, re, os, subprocess

def main(argv):

    #define variables
    sam = ''
    reference = ''
    picard = ''
    gatk = ''
    java_memory = ''
    temp_dir = ''

    #get arguments
    try:
        opts, args = getopt.getopt(
            argv,
            "hs:r:p:g:j:t:",
            ["sam=","ref=","picard=", "gatk=", "jvm=", "temp="])
    except getopt.GetoptError:
        print 'sam2bam.py ' + \
            '-s <sam_file> ' + \
            '-r <reference> ' + \
            '-p <picard_dir> ' + \
            '-g <gatk> ' + \
            '-j <java_memory> ' + \
            '-t <temp_dir>'
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print 'sam2bam.py ' + \
                '-s <sam_file> ' + \
                '-r <reference> ' + \
                '-p <picard> ' + \
                '-g <gatk> ' + \
                '-j <java_memory> ' + \
                '-t <temp_dir>'
            sys.exit()
        elif opt in ("-s", "--sam"):
            sam = arg
        elif opt in ("-r", "--ref"):
            reference = arg
        elif opt in ("-p", "--picard"):
            picard = arg
        elif opt in ("-g", "--gatk"):
            gatk = arg
        elif opt in ("-j", "--jvm"):
            java_memory = arg
        elif opt in ("-t", "--temp"):
            temp_dir = arg
    
    #additional variables
    memory = '-Xmx' + java_memory 
    tmp_dir = 'TMP_DIR=' + temp_dir 
   
    #1. SORT SAM 
    sorted_bam = sam.replace("sam", "sorted.bam")
    sort_sam = picard + '/' + 'SortSam.jar'
    input_sam = 'INPUT=' + sam
    output_sorted = 'OUTPUT=' + sorted_bam
    
    run_sort = 'java ' + memory + ' ' + '-jar ' + sort_sam + \
        ' ' + 'SO=coordinate ' + input_sam + ' ' + output_sorted + \
        ' ' + 'VALIDATION_STRINGENCY=LENIENT ' + 'CREATE_INDEX=TRUE' + \
        tmp_dir        

    os.system(run_sort)

    #2. FIX MATE INFORMATION
    fixmate_bam = sam.replace("sam", "fxmt.bam")
    fixmate = picard + '/' + 'FixMateInformation.jar'
    input_sorted = 'INPUT=' + sorted_bam
    output_fixmate = 'OUTPUT=' + fixmate_bam
    
    run_fixmate = 'java ' + memory + ' ' + '-jar ' + fixmate + \
        ' ' + 'SO=coordinate ' + input_sorted + ' ' + output_fixmate + \
        ' ' + 'VALIDATION_STRINGENCY=LENIENT ' + 'CREATE_INDEX=TRUE' + \
        tmp_dir    
    
    os.system(run_fixmate)
    
    #3. MARK DUPLICATES 
    mark_duplicate_bam = sam.replace("sam", "mkdup.bam")
    metrics = sam.replace("sam", "metrics")
    mark_duplicate = picard + '/' + 'MarkDuplicates.jar'
    input_fixmate = 'INPUT=' + fixmate_bam
    output_mark_dup = 'OUTPUT=' + mark_duplicate_bam
    metrics_out = 'METRICS_FILE=' + metrics
    
    run_mark_dup = 'java ' + memory + ' ' + '-jar ' + mark_duplicate + \
        ' ' + input_fixmate + ' ' + output_mark_dup + \
        ' ' + 'VALIDATION_STRINGENCY=LENIENT ' + 'CREATE_INDEX=TRUE' + \
        ' ' + metrics_out + ' ' + tmp_dir + ' ' + \
        'MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000'

    os.system(run_mark_dup)

    #4. ADD OR REPLACE GROUPS
    #get_rgid = re.search(r'/.*/.*/.*/.*/(.*)/.*sam', sam, re.M)
    get_rgid = re.search(r'(.*/)(.*)/.*sam', sam, re.M)
    rgid = get_rgid.group(2)
    pl = 'ILLUMINA'
    sm = rgid.lower()
    rg_params = 'RGID=' + rgid + ' LB=' +rgid + ' RGPU=' + rgid + \
        ' PL=' + pl + ' SM=' + sm
    addrep_bam = sam.replace("sam", "addrep.bam")
    addrep = picard + '/' + 'AddOrReplaceReadGroups.jar'
    input_mark_dup = 'INPUT=' + mark_duplicate_bam
    output_addrep = 'OUTPUT=' + addrep_bam
    
    run_addrep = 'java ' + memory + ' ' + '-jar ' +  addrep + \
        ' ' + 'SO=coordinate ' + input_mark_dup + ' ' + output_addrep + \
        ' ' + 'VALIDATION_STRINGENCY=LENIENT ' + 'CREATE_INDEX=TRUE' + \
        ' ' + tmp_dir + ' ' + rg_params
    os.system(run_addrep)

    #5. REALIGNER TARGET CREATOR
    realignment_list = sam.replace("sam", "list")
    run_target_creator = 'java ' + memory + ' ' + '-jar ' + \
        gatk + ' -T RealignerTargetCreator -R ' + reference + \
        ' ' + '-o ' + realignment_list + ' ' + '-I ' + addrep_bam + \
        ' ' + '-fixMisencodedQuals -nt 2'
    os.system(run_target_creator)
    
    #6. INDEL REALIGNER
    realignment_bam = sam.replace("sam", "realign.bam")
    run_realigner = 'java ' + memory + ' ' + '-jar ' + \
        gatk + ' -T IndelRealigner -R ' + reference + \
        ' ' + '-targetIntervals ' + realignment_list + ' ' + '-I ' + addrep_bam + \
        ' ' + '-fixMisencodedQuals -o ' + realignment_bam
    os.system(run_realigner)

    #7. CLEAN-UP INTERMEDIATE FILES
    mark_dup_bai = mark_duplicate_bam.replace("bam", "bai")
    addrep_bai = addrep_bam.replace("bam", "bai")
    remove_intermediate = 'rm ' + sam + ' ' + fixmate_bam + \
        ' ' +  mark_duplicate_bam + ' ' + metrics + ' ' + addrep_bam + \
        ' ' + mark_dup_bai + ' ' + addrep_bai 
    print remove_intermediate
    os.system(remove_intermediate)

if __name__ == "__main__":
    main(sys.argv[1:]) 
