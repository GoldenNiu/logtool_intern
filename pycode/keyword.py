# -*- coding: UTF-
def readkeyword(keyfile):
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
    return str_list
