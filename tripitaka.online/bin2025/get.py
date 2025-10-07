#!python3

import json
import os
import sys
import urllib.request

tr = str.maketrans('', '', '\n\r') # The third argument specifies characters to delete

def get_file(path, id, name):
    try:
        urllib.request.urlretrieve('https://tripitaka.online/sutta/live/sutta/' + id, os.path.join(path, name) + '.json')
        print(f"sutta {name}")
    except Exception as e:
        print (f"error with {path}/{id}: {e}", file=sys.stderr)

def iter_tree(tree, path, i):
    #label - name
    # children -> is dir
    if 'children' in tree:
        path=os.path.join(path, f"{i:03} " + tree.get("label").strip().translate(tr))
        os.makedirs(path, exist_ok=True)
        print(f"dir {path}")
        j=1
        for ch in tree.get("children"):
            iter_tree(ch, path, j)
            j=j+1
    elif 'data' in tree:
        #data - is file
        get_file(path, tree.get("data"), f"{i:03} " + tree.get("label").strip().translate(tr))
    else:
        print(path + " " + tree.get("label") + " no children no data!", file=sys.stderr)

i=1
data = json.load( open('menu.json', 'r') )
for nik in data.get('data'):
    iter_tree(nik, './json', i)
    i=i+1

