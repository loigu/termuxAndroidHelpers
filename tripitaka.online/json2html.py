#!python3

import json
import sys
import os
import collections.abc

''' TODO: pandoc epub strips class from paragraps '''
header_tags=('h1', 'h2', 'h3', 'h4', 'h5')
def print_tag(d, f):
    if "tag" in d:
        tag=d.get("tag")
        cls=d.get("class")
        i=d.get("id")
        content=d.get("content")
        if not pli and 'pali' in cls:
            return

        if tag in header_tags:
            tag=sub_h
            cls += " sutta-title"
            print(f"warning: header tag in sutta body {fn}", file=sys.stderr)

        print(f"<{tag} id='{i}' class='{cls}'>{content}", file=f, end="")
        if "data" in d:
            iter(d.get("data"), f)

        print(f"</{tag}>", file=f)

def print_start(name, desc, f):
    print(f"<{h} id='2 {name}' class='sutta-title'>{name}</{h}>", file=f)
    print(f"<p id='3 {name}' class='sutta-title'>{desc}<br/></p>", file=f)

def iter(d, f):
    header=True

    htags=("h1", "h2", "h3", "h4")
    p1 = None
    p2 = None
    desc = ""
    for t in d:
        if header:
            ''' parse & print header first'''
            tag=t.get("tag")
            c=t.get("class")
            content=t.get("content")
            
            if 'sutta-title' in c or tag in htags:
                ''' still in book / vagga ... '''
                p2 = p1
                p1 = content
                desc += content + "<br/>"
            else:
                ''' finished headers '''
                if p2 == None:
                    print (f"error with {fn}: only one title found", file=sys.stderr)
                else:
                    p1 = f"{p1} - {p2}"
                print_start(p1, f"{desc}", f)
                header = False
                print_tag(t, f)

        else:
            '''content of the sutta'''
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
    '''
    .sinhala-text   {{font-weight: bold;}}\n\
    '''

    print(f"<!DOCTYPE html>\n\
<html lang='si'>\n\
<head>\n\
    <meta charset='UTF-8'>\n\
    <title>{title}</title>\n\
    <style>\n\
        .sutta-title    {{font-weight: bold;}}\n\
        .pali-text    {{font-style: italic;}}\n\
        .gatha-pali-text {{font-style: italic;}}\n\
    </style>\n\
</head>\n\
<body>", file=f)

def print_footer(f):
    print('</body></html>', file=f)

fn=sys.argv[1]
j=open(fn, 'r')

if sys.argv[2] == '-':
    out=sys.stdout
else:
    out=open(sys.argv[2], 'w')

pli = os.getenv('pli', '0') == '1'
standalone = os.getenv('standalone', '1') == '1'
if standalone:
    h = 'h1'
else:
    h = os.getenv('header_tag', 'h1')
sub_h = "h" + str(int(h[1]) + 1)

data=json.load(j).get("data")

if standalone:
    print_header(out, get_title(data))
iter(data, out)
if standalone:
    print_footer(out)

out.close()

