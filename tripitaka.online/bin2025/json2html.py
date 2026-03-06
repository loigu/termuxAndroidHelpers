#!python3

import json
import sys
import collections.abc

def print_tag(d, f):
   if "tag" in d:
        tag=d.get("tag")
        cls=d.get("class")
        i=d.get("id")
        content=d.get("content")
        if pli == 'n' and 'pali' in cls:
            return
        print(f"<{tag} id='{i}' class='{cls}'>{content}", file=f, end="")
        if "data" in d:
            iter(d.get("data"), f)

        print(f"</{tag}>", file=f)


def iter(d, f):
    for t in d:
        print_tag(t,f)

def get_title(d):
    '''
    < h1 id = ' 3 ' class = ' sutta - title ' > saṁyutta nikāya < / h1 > 
    < h1 id = ' 4 ' class = ' sutta - title ' > khandhaka vaggō < / h1 >
     < h2 id = ' 5 ' class = ' sutta - title ' > 4.1.5 . vēdanā suttaṁ < / h2 > 
     < h3 id = ' 6 ' class = ' sutta - title ' > 4.1.5 . vin̆dīm gæna vadāḷa desuma < / h3 >
    '''
    name=""
    section=""
    for t in d:
        tag=t.get("tag")
        c=t.get("class")
        if tag == 'h3':
            name=t.get('content')
        elif c == 'sutta-title':
            if section == "":
                section = t.get("content")
            else:
                section += ' - ' + t.get("content")
        else:
            break
    return f"{name} ({section})"

def print_header(f, title):
    print(f"<!DOCTYPE html>\n\
<html lang='si'>\n\
<head>\n\
    <meta charset='UTF-8'>\n\
    <title>{title}</title>\n\
    <style>\n\
        .sutta-title    {{font-weight: bold;}}\n\
       <!-- .sinhala-text   {{font-weight: bold;}} -->\n\
        .pali-text    {{font-style: italic;}}\n\
        .gatha-pali-text {{font-style: italic;}}\n\
    </style>\n\
</head>\n\
<body>", file=f)

def print_footer(f):
    print('</body></html>', file=f)

j=open(sys.argv[1], 'r')
out=open(sys.argv[2], 'w')
if len(sys.argv) > 3:
    pli=sys.argv[3]
else:
    pli='y'

data=json.load(j).get("data")
print_header(out, get_title(data))
iter(data, out)
print_footer(out)

out.close()

