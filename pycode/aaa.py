def abcd(t):
    if t=='aa':
        fa=open('basic_information_dump.txt','r')
        alllines=fa.readlines()
        abc=[]
        i=0 
        for eachline in alllines:
            if 'sched_enable_hmp' in eachline:
                abc=eachline.split(' ')
                #print abc[-1]
                str1=abc[-1].split(',')
                #print str1[-1]
                str2=str1[-1].split(':')
                #print str2
                str3=str2[0].split('_')
                str4="%-25s:%-10s" %('resolution',str3[-2])
                str5="%-25s:%-10s" %('mode',str3[-1])
                print str4
                print str5
    else:
        print t

