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
    h=""
    for t in d:
        tag=t.get("tag")
        if tag == "h1":
            if h == "":
                h = t.get("content")
            else:
                h += '-' + t.get("content")
        else:
            break
    return h

def print_header(f, title):
    print(f"<!DOCTYPE html>\n\
<html lang='si'>\n\
<head>\n\
    <meta charset='UTF-8'>\n\
    <title>{title}</title>\n\
    <style>\n\
        .sinhala-text   {{font-weight: bold;}}\n\
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

