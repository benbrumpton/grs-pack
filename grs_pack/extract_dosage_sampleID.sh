#!/bin/bash
# This script extracts the dosages and sample ID to a text file
# bash extract_dosage_sampleID.sh

# Arguments
data=${1?Error: no file directory given} #(1) Set file directory 
project=${2?Error: no project name} #(2) Set project name

# file names
vcf="${project}".vcf
vcf2="${project}"_fixed.vcf
out_file="${project}".txt
out_info="${project}"_info.txt

# Step 1: Fix the file format(strange"), add missing headers
cat $data/$vcf | bcftools annotate -h /home/benb/projects/common/header_lines.txt > $data/$vcf2
#| sed 's/�~@~\/\"/g' | bcftools annotate -h /home/benb/projects/common/header_lines.txt > $data/$vcf2
#rm $data/$vcf

# Export header for sample file
bcftools query -l $data/$vcf2 > $data/sample_id.txt

# Export the dosage to txt file
bcftools query -f "%ID[\t%DS]\n" $data/$vcf2 > $data/$out_file

# Export snp info
bcftools query -f "%ID\t%CHROM\t%POS\t%ALT\t%REF\t%AF\t%MAF\t%R2\n" $data/$vcf2 > $data/$out_info

# Cleanup
#mv $data/$vcf2 > $data/$vcf
rm $data/"$project"_CHR*

