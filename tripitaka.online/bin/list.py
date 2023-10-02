#!python

from pathlib import Path
from json import loads
import sys, os

def subdir(path, json):
  if 'children' in json.keys():
    path += json['label'].strip() + '/' 
    """ os.makedirs(path, exist_ok=True) """
    for dir in json['children']:
      subdir(path, dir)                                      
  elif 'data' in json.keys():         
    print(str(json['data']) + ' ' + path + json['label'].strip())
  else:                                                  
    print ('wtf, weird element in here:' + path + '\n\t' + json)
    
root = loads(Path(sys.argv[1]).read_text())
nikayas = root['data']   
  
for nik in nikayas:
  subdir('', nik)
