#!/bin/bash
if [ $# -lt 1 ]; then
  echo "Input: <list of pdf files>. Output is merged.pdf"
  exit 0
fi

gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=merged.pdf \
$@
