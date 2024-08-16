#!/bin/sh
git-latexdiff  pre-presentation-fixup --add-to-config=PICTUREENV=dependency --main main.tex -o thesis-diff.pdf --biber --latexmk --latexopt -shell-escape
