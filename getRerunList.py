#!/usr/bin/python

#creator: Jeffrey A. Detras
#date: 09/19/2016
#usage: creates list of samples for rerunning on
#snp discovery pipeline

import os
from shutil import copyfile

#read input file and the log file
input_list=open('input.info','r').readlines()
log_list=open('log.txt','r').read().splitlines()

#copy original input.info to old
copyfile('input.info','input.info.old')

#overwrite input.info list for rerun list
rerun_list=open('input.info','w')

for i in input_list:
    for j in log_list:
        if j in i:
            rerun_list.write(i)
