#!/bin/bash
# Use The Project Files To Generate An Epub Book

# Clean Any Previous Run
[ -f /output/book.epub ] && rm -f /output/book.epub

# Convert Cover Image For Epub
echo
echo -n " Converting Cover Image To Epub Image..."
convert images/cover.xcf.bz2 -flatten -resize x1000 /tmp/cover-epub.jpg
echo "DONE!"

# Generate Epub Document From Content
echo
echo -n " Generating Epub File..."
pandoc -f markdown+smart -t epub3 -o /output/book.epub --toc --toc-depth=1 -s --metadata-file=metadata/metadata.yml --epub-cover-image=/tmp/cover-epub.jpg content/*.md
echo "DONE!"

# Perform Mobi Conversion Test As Proof It Works
echo
echo -n " Testing Mobi Converstion..."
if ! kindlegen /output/book.epub > /tmp/kindlegen.log ; then echo "FAILED!" ; else echo "PASSED!" ; fi

# Clean Up
rm -f /tmp/cover-epub.jpg /output/book.mobi

echo
echo " Complete!"
echo