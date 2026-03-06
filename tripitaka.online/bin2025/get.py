#!python3

import json
import os
import sys
import urllib.request

tr = str.maketrans('', '', '\n\r') # The third argument specifies characters to delete


def get_file(path, id, name):
    try:
        u = f'https://tripitaka.online/sutta/live/sutta/{id}'
        f = os.path.join(path, f"{name}.json")

        if not os.path.isfile(f) or force:
            urllib.request.urlretrieve(u, f)
            print(f"sutta {name}")
        else:
            print(f"sutta {name} - {f} already downloaded")
    except Exception as e:
        print (f"error with {name} - {path}/{id}: {e}", file=sys.stderr)

def iter_tree(tree, path, i):
    #label - name
    if 'children' in tree:
        # children -> is dir
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

force = os.getenv('force', '0') == '1'

if not os.path.isfile('menu.json') or force:
    urllib.request.urlretrieve('https://tripitaka.online/sutta/live/menu', 'menu.json')
else:
    print("using cached menu.json")

data = json.load( open('menu.json', 'r') )

i=1
for nik in data.get('data'):
    iter_tree(nik, './json', i)
    i=i+1

