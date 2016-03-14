import urllib.request
import sys


def fun(val=0):
    l = []  # Related
    r = 0  # Related Topics
    i = 0  #
    m = 0
    no = 0
    mean = ''
    mstr = ""
    # counter=0
    ur = "http://en.wikipedia.org/wiki/"
    if val == 0:
        val = sys.argv[1]
    ur = ur + str(val)
    f = urllib.request.urlopen(ur)
    for line in f:  # Read through Line
        # counter+=1
        if ("<p>" in str(line)) and ("<b>" in str(line)):  # Check If Definition exists
            if i == 0 and r == 0:
                mstr = mstr + str(line)
                if "refer to" in str(line):  # Definition doesn't Exists
                    i = i + 1
                elif "</p>" in str(line):
                    mstr = mstr + "\n"  # Definition
                    r = 1
        if r == 1:
            if ("#See_also" in str(line)) and ("class=\"mw-headline-anchor\"" in str(line)):
                i = i + 1
        if i == 1:
            if "<li>" in str(line):  # Related topics in List
                try:
                    l.append(str((str(line).split("/wiki/")[1]).split("\"")[0]))
                except:
                    pass
                no = no + 1
                mstr = mstr + str(no) + "." + str(line)
            # no More Related From Here
            if "<h2>" in str(line) and "href=\"#References\"" in str(line) and r == 1:
                if l:
                    mstr = mstr + "\nMay also Choose From Above as no."
                f = []
                i = 2
            # Case Calls when there is no definitions just Related Topics
            if "<table " in str(line) and r == 0:
                mstr = mstr + "\nChoose From Above as no."
                f = []
                i = 2
    # optimize here
    for c in mstr:
        if c is ">":
            m = m + 1
        if m == 1:
            if c is "<":
                m = 0
            mean = mean + c
    mean = mean.replace("<", '').replace(">", '')
    # print(counter)        
    if "Choose From Above as no." in mean:
        try:
            num = sys.argv[2]
        except:
            print(mean)            
        else:
            no = int(num) - 1
            fun(l[no])
    else:
        print(mean)

fun()
