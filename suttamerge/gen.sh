#!/bin/bash

export res=~/termuxAndroidHelpers/suttamerge/res/

pandoc --strip-empty-paragraphs --toc --toc-depth=4 --epub-metadata="metadata.yaml" --metadata-file=metadata.yaml  --epub-cover-image="$res/cover.jpg" --css="$res/book.css" -o tipitaka_cesky.epub \
	anguttara-nikaya-cesky[0-9]*.docx \
	digha-nikaya-cesky[0-9]*.docx \
	'majjhima nikaya česky 1 - 50 '[0-9]*.docx \
	'majjhima_nikaya česky 51 - 100 '[0-9]*.docx \
	'majjhima_nikaya česky 101 - 152 '[0-9]*.docx \
	samyutta-nikaya-cesky[0-9]*.docx \
	khuddakapatha.docx dhammapada.docx \
	udana.docx itivuttaka.docx \
	suttanipata-cesky[0-9]*.docx \
	petavatthu-cesky[0-9]*.docx 

