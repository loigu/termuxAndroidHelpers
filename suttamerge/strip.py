import xml.etree.ElementTree as ET

myroot = mytree.getroot()
body =myroot.find('{*}body')
for st in body.findall('{*}style'):
    body.remove(st)

    join page divs

body.clear()
mytree.write('kratsi-cle.html')

