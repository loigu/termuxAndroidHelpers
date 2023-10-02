#!python
from pathlib import Path
from json import loads
import sys, os

head='<!DOCTYPE html><html lang="si" style="max-width: 360px; transition: all 0s ease-in-out 0s; --dock-left: 0px; transform: translate(0px, -1231.72px) scale(1);"><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8">\n'
head += '<style type="text/css">\n<!--\n'    
head += '.pali-text{ font-style: italic;}\n.sinhala-text{}\n.sutta-title{ font-weight: bold; }\nh1 { page-break-before: always; }\n' 
head += '-->\n</style>\n' 

json = loads(Path(sys.argv[1]).read_text())

print_pali=False
if len(sys.argv) > 2 and sys.argv[2] == 'pali':
  print_pali=True

body=''
title=''
t=''
for el in json['data'] :
  tag=el['tag'] 
  content=el['content']
  cls = el['class']
  if tag[0] == 'h':
    t=content
    if title:
      title+= ' - ' 
    title+=content
  if cls != "pali-text" or print_pali:
    body+='<' + tag + ' class="' + el['class'] + '">' + content + '</' + tag + '>\n' 

print(head + '<title>' + title + '</title>\n</head>\n') 
print('<body>\n' + body + '</body>\n</html>') 
sys.stderr.write(t)

