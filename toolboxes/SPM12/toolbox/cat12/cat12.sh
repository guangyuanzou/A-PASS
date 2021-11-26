#! /bin/bash

# $Id: cat12.sh 1741 2020-12-11 13:51:55Z gaser $
version='cat12.sh $Id: cat12.sh 1741 2020-12-11 13:51:55Z gaser $'

echo "##############################################################"
echo "   cat12.sh is deprecated. Please now use cat_batch_cat.sh.   "
echo "##############################################################"

cat12_dir=$(dirname "$0")
args=("$@")

${cat12_dir}/cat_batch_cat.sh ${args}

