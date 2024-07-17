#!/bin/sh
git-latexdiff  pre-presentation-fixup --exclude-safecmd=AMPERSAND --main main.tex -o thesis-diff.pdf --biber --latexmk --latexopt -shell-escape
