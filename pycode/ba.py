# -*- coding: UTF-
#basic infor
import re
import sys
fa=open(sys.argv[1],'r')
#log
fb=open(sys.argv[2],'r')
#keyword，读取keyword文件转化为可用的列表
str_list=[]
a=0
alllines=fb.readlines()
while a<len(alllines):
    str_list.append(alllines[a].strip('\n'))
    print str_list[a]
    a+=1
print str_list
myfile=open(sys.argv[3],'a+')
#report
alllines=fa.readlines()
lines=len(fa.readlines())
for i in str_list:
    for eachline in alllines:
            if i in eachline:
                print >> myfile,eachline
#专门处理mode,cmd
for eachline in alllines:
    if 'sched_enable_hmp' in eachline:
        
myfile.close()
fa.close()

