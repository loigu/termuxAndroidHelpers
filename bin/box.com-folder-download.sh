#!/bin/bash

# https://app.box.com/s/q3w7cqks1ur1o2c21moiuf8nbahag7xq
url="$1"
target="$2"

share="${url##*/}"
wget "$url" -O "$share"
id=$(html_prettyprint.py "$share" | grep postStreamData | sed -e 's/.*,"folder":\({[^}]*}\).*/\1/' | sed -e 's/.*"id":\([^,]*\).*/\1/')

wget "https://app.box.com/index.php?folder_id=${id}&q%5Bshared_item%5D%5Bshared_name%5D=${share}&rm=box_v2_zip_shared_folder" -O $id

get=$(cat "$id" |json_pp|grep download_url |cut -d '"' -f 4)
name="${get##*ZipFileName=}"
name=$(echo ${name%%\&*} | python3 -c "import sys; from urllib.parse import unquote; print(unquote(sys.stdin.read()));")

wget "$get" -O "$name"
