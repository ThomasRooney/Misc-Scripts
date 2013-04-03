#!/usr/bin/python

# Based off a recipe found on the net, using pyPdf

import sys
from pyPdf import PdfFileWriter, PdfFileReader
from pyPdf.generic import NameObject, NumberObject

def main(argv=None):
    if argv is None:
        argv = sys.argv

    if len(argv) != 4:
        print('Usage: pdf_auto_advance.py [duration (seconds)] [input-pdf]',
              '[output-pdf]')
        return

    pdfin = PdfFileReader(open(argv[2], "rb"))
    pdfout = PdfFileWriter()

    for page in pdfin.pages:
        page[NameObject('/Dur')] = NumberObject(argv[1])
        pdfout.addPage(page)

    outputStream = open(argv[3], "wb")
    pdfout.write(outputStream)

if __name__ == '__main__':
    sys.exit(main())

