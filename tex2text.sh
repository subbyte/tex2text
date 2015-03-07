#!/bin/env bash
################################################################
#           tex2text: Interpreting Tex into Plaintext
#
#   author:     Xiaokui Shu
#   version:    1.0.1
#   license:    Apache 2.0
#   email:      subx@cs.vt.edu
################################################################

if [ -z "$*" ]; then echo "Usage: tex2text.sh target.tex"; exit; fi

ofile=${1%.*}.txt

echo "interpreting $1 into plaintext file $ofile..."

#### functions ####
removespace () {
    perl -p -i -e 's/[ \t]+/ /g' $ofile
    perl -p -i -e 's/^ //g' $ofile
    perl -p -i -e 's/ $//g' $ofile
}

#### Sec 1 ####
# init and change format
cp $1 $ofile
dos2unix -q $ofile

# replace "~" with space
perl -p -i -e 's/~/ /g' $ofile

# remove all comments
sed -i '/^\s*%/d' $ofile
perl -p -i -e 's/([^\\])%(.*)$/\1/g' $ofile

removespace

# join lines in each paragraph and get rid of multiple empty lines
perl -00pl -i -e 's/\s*\n\s*/ /g' $ofile


#### Sec 2 ####
# remove escape before "%"
perl -p -i -e 's/\\%/%/g' $ofile

# handle quotes
perl -p -i -e "s/\`\`([^']+)''/\"\1\"/g" $ofile

# remove all citations
perl -p -i -e 's/(e\.g\.,|, e\.g\.,|in)?( |~)?\\cite{[^}]+}//g' $ofile

# replace reference with "9"
perl -p -i -e 's/\\(ref){[^}]+}/9/g' $ofile

# replace \verb with "X"
perl -p -i -e 's/\\verb(.)([^\\1]+)\1/X/g' $ofile

# open abstract
perl -p -i -e 's/\\begin{(abstract)}//g' $ofile
perl -p -i -e 's/\\end{(abstract)}//g' $ofile

# open titles and remove labels
perl -p -i -e 's/\\(section|subsection|subsubsection){([^}]+)}/\2/g' $ofile
perl -p -i -e 's/\\label{[^}]+}//g' $ofile

# remove "\noindent"
perl -p -i -e 's/\\noindent/ /g' $ofile

# remove fontsizes
perl -p -i -e 's/\\(tiny|scriptsize|footnotesize|small)/ /g' $ofile

# remove "\vspace", "\hspace"
perl -p -i -e 's/\\[vh]space{[^}]+}/ /g' $ofile

# remove enumerate env
perl -p -i -e 's/\\begin{(enumerate|itemize|description|inparaenum)}(\[[^\]]+\])?//g' $ofile
perl -p -i -e 's/\\end{(enumerate|itemize|description|inparaenum)}//g' $ofile
perl -p -i -e 's/\\item //g' $ofile
perl -p -i -e 's/ (i|ii|iii|iv|v|vi|vii|viii|iv|x)\) / /g' $ofile

# open ifFull
perl -p -i -e 's/\\ifFull//g' $ofile
perl -p -i -e 's/\\fi//g' $ofile

# open definition, theorem, lamma, example, proof
perl -p -i -e 's/\\begin{(definition|theorem|lemma|example|proof)}//g' $ofile
perl -p -i -e 's/\\end{(definition|theorem|lemma|example|proof)}//g' $ofile

# put equation into $...$ for further deleting
perl -p -i -e 's/\\begin{equation}/\$/g' $ofile
perl -p -i -e 's/\\end{equation}/\$/g' $ofile

# replace math symbols
perl -p -i -e 's/\$n\$/n/g' $ofile
perl -p -i -e 's/\$[^\$]+\$/X/g' $ofile
perl -p -i -e 's/X$//g' $ofile

# unformat it, bf, sc, tt
perl -p -i -e 's/\\text(it|bf|sc|tt){([^}]+)}/\2/g' $ofile
perl -p -i -e 's/\\emph{([^}]+)}/\1/g' $ofile
perl -p -i -e 's/{\\(em|emph|bf|sc|tt) ([^}]+)}/\2/g' $ofile

# dots
perl -p -i -e 's/\\dots/\.\.\./g' $ofile


#### Sec 3: steps that require inner {} to be cleaned first ####
# put footnote at the end of a line.
perl -p -i -e 's/^(.*)\\footnote{([^}]+)}(.*)$/\1\3 \2/g' $ofile

# extract captions from figures and tables
perl -p -i -e 's/^\\begin{([^}]+)}(.*)\\caption{([^}]+)}(.*)\\end{\1}/\3/g' $ofile

# remove empty begin-end/parentheses pairs
perl -p -i -e 's/\\begin{([^}]+)}( +)\\end{\1}/ /g' $ofile
perl -p -i -e 's/ \(\)//g' $ofile


#### Sec 4: final adjustment ####
removespace
perl -p -i -e 's/ \./\./g' $ofile
perl -p -i -e 's/, , /, /g' $ofile
perl -00 -p -i -e '' $ofile
