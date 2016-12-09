# -*- coding: UTF-
#basic infor
import re
import sys
fa=open("basic_information_dump.txt",'r')
myfile=open("1.txt",'a+')
#定义一个文件列表，需要提取的key_word

#fb=open(argv[0],'r')
print (sys.argv[2])

str=[
    'Date Time',
    'Build',
    'Linux version',
    'Serial number',
    'Hardware',
    'charging',
    'cmdline'
    ]
#print str
alllines=fa.readlines()
lines=len(fa.readlines())
for i in str:
    for eachline in alllines:
            if i in eachline:
                print eachline
            print >> myfile,eachline
myfile.close()
fa.close()


