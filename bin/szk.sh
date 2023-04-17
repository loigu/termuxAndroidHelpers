#!/bin/bash

for f in "$@";do
	rsync-resume.sh  fsd:new/shunryu_suzuki/shunryusuzuki.com-mp3/shrunk/"$f" ./
done
