#!/bin/env bash

ofile=${1%.*}.txt

echo "interpreting $1 into plaintext file $ofile..."

# UNIX format
dos2unix -q $1

# remove all comments
sed '/^\s*%/d' $1 > $ofile

# remove spaces
perl -p -i -e 's/( |\t)+/ /g' $ofile
perl -p -i -e 's/^ //g' $ofile
perl -p -i -e 's/ $//g' $ofile

# join lines in each paragraph and get rid of multiple empty lines
perl -00pl -i -e 's/\s*\n\s*/ /g' $ofile

# remove all citations
perl -p -i -e 's/(in|e.g.,)?\~\\(cite){[^}]*}//g' $ofile

# handle references
perl -p -i -e 's/\~\\(ref){[^}]*}/9/g' $ofile

# remove titles and labels
perl -p -i -e 's/\\(section|subsection|subsubsection|label){[^}]*}//g' $ofile

# remove escape before "%"
perl -p -i -e 's/\\%/%/g' $ofile

# unformat it, bf, sc, tt
perl -p -i -e 's/\\text(it|bf|sc|tt){([^}]+)}/$2/g' $ofile
perl -p -i -e 's/\\emph{([^}]+)}/$1/g' $ofile
perl -p -i -e 's/{\\(em|emph|sc|tt) ([^}]+)}/$2/g' $ofile

# remove enumerate env
perl -p -i -e 's/^\\begin{(enumerate|itemize|description)}.*//g' $ofile
perl -p -i -e 's/^\\end{(enumerate|itemize|description)}//g' $ofile
perl -p -i -e 's/^\\item //g' $ofile

# replace math symbols
perl -p -i -e 's/\$n\$/n/g' $ofile
perl -p -i -e 's/\$[^\$]+\$/X/g' $ofile

# final adjustment
perl -p -i -e 's/, , /, /g' $ofile
perl -p -i -e 's/ \(\)//g' $ofile
perl -00 -p -i -e '' $ofile
