#!python

from pathlib import Path
from json import loads
import sys, os

def dir_naming(path,json,i):
    if 'children' in json.keys():
        path += "%02d_%s/" % (i,json['label'])
        os.makedirs(path, exist_ok=True)
        i=1
        for dir in json['children']:
            dir_naming(path, dir,i)
            i+=1

def dir_renaming(path,json,i):
    if 'children' in json.keys():
        od=json['label'].strip()
        op=path + '/' + od
        np="%s/%02d_%s" % (path,i,od)
        os.rename(op,np)
        
        i=1
        for dir in json['children']:
            try:
                dir_renaming(np,dir,i)
                i+=1
            except:
                pass

def subdir(path, json,i):
  """ TODO: numbering of dirs """
  if 'children' in json.keys():
    path += "%02d_%s/" % (i,json['label'])
    os.makedirs(path, exist_ok=True)
    i=1
    for dir in json['children']:
      subdir(path, dir,i)
      i+=1
  elif 'data' in json.keys():         
    print(str(json['data']) + ' ' + path + json['label'].strip())
  else:                                                  
    print ('wtf, weird element in here:' + path + '\n\t' + json)
    
root = loads(Path(sys.argv[1]).read_text())
nikayas = root['data']   

i=1
for nik in nikayas:
  subdir('.',nik,i)
  i+=1
