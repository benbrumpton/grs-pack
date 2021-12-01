#!/usr/bin/env bash
# Bash script to get chr pos from rsID for h19

RS_LIST=${1?Error: no rs list given}
OUT=${2:-'hg_list.txt'}
HG_SNPS=${3:-'/mnt/work/reference-files/ucsc/snp147_chrpos.txt'}

#join
join -1 1 -2 3 <(sort $RS_LIST) $HG_SNPS | awk -v OFS='\t' '{print $2, $3, $1}' > $OUT

# print details
echo "The number of input SNPs is"
wc -l $RS_LIST

echo "The number of matching SNPs is"
wc -l $OUT

# finished
echo "done"
