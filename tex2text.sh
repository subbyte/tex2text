#!/bin/env bash
################################################################
#           tex2text: Interpreting Tex into Plaintext
#
#   author:     Xiaokui Shu
#   version:    1.1.0
#   license:    Apache 2.0
#   email:      subx@cs.vt.edu
################################################################

if [ -z "$*" ]; then echo "Usage: tex2text.sh target.tex"; exit; fi

ofile=${1%.*}.txt

echo "interpreting $1 into plaintext file $ofile..."


#### functions ####
removespace () {
    perl -i -ple 's/\s+/ /g' $ofile
    perl -i -pe 's/^ //g' $ofile
    perl -i -pe 's/ $//g' $ofile
}


#### Sec 1 ####
# init and change format
cp $1 $ofile
dos2unix -q $ofile

# replace "~" with space
perl -i -pe 's/~/ /g' $ofile

# remove all comments
# remove whole-line comment
sed -i '/^\s*%/d' $ofile
# remove inline comment, (skip "\%", which is a percetage sign)
perl -i -pe 's/([^\\])%(.*)$/\1/g' $ofile
# remove ifFull-fi sections
sed -i '/\\ifFull/,/\\fi/d' $ofile

removespace

# join lines in each paragraph and get rid of multiple empty lines
perl -i -00ple 's/\s*\n\s*/ /g' $ofile


#### Sec 2 ####
# remove escape before "%"
perl -i -pe 's/\\%/%/g' $ofile

# handle quotes
perl -i -pe "s/\`\`([^']+)''/\"\1\"/g" $ofile

# remove all citations
perl -i -pe 's/(e\.g\.,|, e\.g\.,|in)?( |~)?\\cite\{[^\}]+\}//g' $ofile

# replace reference with "9"
perl -i -pe 's/\\ref\{[^\}]+\}/9/g' $ofile

# replace \verb with "X"
perl -i -pe 's/\\verb(.)([^\\1]+)\1/X/g' $ofile

# open abstract
perl -i -pe 's/\\(begin|end)\{(abstract)\}//g' $ofile

# open titles and remove labels
perl -i -pe 's/\\(section|subsection|subsubsection)\{([^\}]+)\}/\2/g' $ofile
perl -i -pe 's/\\label\{[^\}]+\}/ /g' $ofile

# remove "\noindent"
perl -i -pe 's/\\noindent/ /g' $ofile

# remove fontsizes
perl -i -pe 's/\\(tiny|scriptsize|footnotesize|small)/ /g' $ofile

# remove "\vspace", "\hspace"
perl -i -pe 's/\\[vh]space\{[^\}]+\}/ /g' $ofile

# remove enumerate env
perl -i -pe 's/\\begin\{(enumerate|itemize|description|inparaenum|svgraybox)\}(\[[^\]]+\])?//g' $ofile
perl -i -pe 's/\\end\{(enumerate|itemize|description|inparaenum|svgraybox)\}//g' $ofile
perl -i -pe 's/\\item //g' $ofile
perl -i -pe 's/ (i|ii|iii|iv|v|vi|vii|viii|iv|x)\) / /g' $ofile

# open definition, theorem, lamma, example, proof
perl -i -pe 's/\\begin\{(definition|theorem|lemma|example|proof)\}//g' $ofile
perl -i -pe 's/\\end\{(definition|theorem|lemma|example|proof)\}//g' $ofile

# remove escaped $
perl -i -pe 's/\\\$//g' $ofile

# put equation into $...$ for further deleting
perl -i -pe 's/\\begin\{equation\}/\$/g' $ofile
perl -i -pe 's/\\end\{equation\}/\$/g' $ofile

# replace math symbols
perl -i -pe 's/\$n\$/n/g' $ofile
perl -i -pe 's/\$[^\$]+\$/X/g' $ofile

# unformat it, bf, sc, tt
perl -i -pe 's/\\text(it|bf|sc|tt)\{([^\}]+)\}/\2/g' $ofile
perl -i -pe 's/\\emph\{([^\}]+)\}/\1/g' $ofile
perl -i -pe 's/\{\\(em|emph|bf|sc|tt) ([^\}]+)\}/\2/g' $ofile

# dots
perl -i -pe 's/\\dots/\.\.\./g' $ofile


#### Sec 3: steps that require inner {} to be cleaned first ####
# put all footnotes at the end of a line.
while grep -q "\\\\footnote" $ofile
do
    perl -i -pe 's/^(.*)\\footnote\{([^\}]+)\}(.*)$/\1\3 \2/g' $ofile
done

# extract captions from figures and tables
perl -i -pe 's/^\\begin\{([^\}]+)\}(.*)\\caption\{([^\}]+)\}(.*)\\end\{\1\}/\3/g' $ofile

# remove empty begin-end/parentheses pairs
perl -i -pe 's/\\begin\{([^\}]+)\}( +)\\end\{\1\}/ /g' $ofile
perl -i -pe 's/ \(\)//g' $ofile


#### Sec 4: final adjustment ####
removespace

perl -i -pe 's/ \./\./g' $ofile
perl -i -pe 's/, , /, /g' $ofile
perl -i -00ple '' $ofile
