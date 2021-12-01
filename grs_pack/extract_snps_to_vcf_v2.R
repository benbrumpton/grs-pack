#source('/home/benb/projects/sib_bmi/scripts/extract_snp_to_vcf.R')
options(stringsAsFactors=F)

library("optparse")

option_list <- list(
  make_option("--outdir", type="character",default="",
    help="Output directory"),
  make_option("--prefix", type="character", default="",
    help="Name of the project and output files"),
  make_option("--snplist", type="character", default="",
    help="SNP list, tab sepearated in the order CHROM POS RSID")
)

parser <- OptionParser(usage="%prog [options]", option_list=option_list)

args <- parse_args(parser, positional_arguments = 0)
opt <- args$options
print(opt)

# The work
#setwd("/home/benb/projects/sib/data/") # (1)set directory
setwd(opt$outdir)

VCF1_22 <- list.files("/home/benb/work/genotypes/DATASET_20161002/imp/HRC/original/VCF","CHR.+.HRC_WGS.vcf.gz$",full.name=T)

VCFX <- "/home/benb/work/genotypes/DATASET_20161002/imp/HRC/original/VCF/CHR_X.HRC.vcf.gz"
VCFs <- c(VCF1_22,VCFX)

#project <- "sib_bmi_v1" # (2) set project name
project <- opt$prefix

# hg19 coordinates
#snps <- read.table("/home/benb/projects/sib_bmi/data/h19_snps_bmi79.txt",sep="\t",header=T,comment.char="", as.is=T) # from UCSC genome browser / table browser; http://genome.ucsc.edu/cgi-bin/hgTables # (3) set directory # paste list into notepad and move to terminal
snps <- read.table(opt$snplist,sep="\t",header=F,comment.char="", as.is=T)
snps <- snps[which(!grepl("_",snps$V1)),]

regions <- data.frame(
        '#CHROM'=as.integer(gsub("chr","",snps$V1)),
        'POS'=snps$V2,
        'ID'=snps$V3,
        check.names=F)    
		
regions <- regions[order(regions$'#CHROM',regions$POS),]
file.regions <- "extractRegions.txt"
write.table(regions,file.regions,sep="\t",col.names=F,row.names=F,quote=F)

VCF.out <- gsub("(.+)\\.gz$",paste0(project,"_\\1"),basename(VCFs))

# Run tabix for each chromosome
cmdLines <- paste("tabix -h --regions",file.regions,VCFs," > ",VCF.out)
for(i in 1:length(cmdLines)){
	print(i)
	system(cmdLines[i])
} # end of loop

# Merge extracted data
VCF.merged <- paste0(project,".vcf")
system(paste("( cat",VCF.out[1],";",paste(paste("grep -v '^#'",VCF.out[2:length(VCF.out)]),collapse="; "),") > ",VCF.merged))

# Format this file. PID and rs number 
# Check the number of SNPs
# cut -f 1-5 sib_bmi_v1.vcf | sed '1,13d' | wc -l

#system(cut -f 1-5 height.vcf | sed '1,13d' | wc -l)

# Which are duplicates?
#cut -f 1-5 height.vcf | sed '1,12d' | awk '{print $2}'| uniq -d
#cut -f 1-5 height.vcf | sed '1,12d' | awk '{print $1":"$2}'| uniq -d > duplicate-chrom-pos.txt
#cut -f 1-5 height.vcf | sed '1,12d' | grep -f duplicate-chrom-pos.txt
#cut -f 1-5 height.vcf | sed '1,12d' | grep -f duplicate-chrom-pos.txt > duplicate-chrom-pos-alt.txt

# cut -f 1-5,8 height.vcf | sed '1,12d' | grep -f duplicate-chrom-pos.txt | sed 's/;/ /' | sed 's/=/ /' | sort -k2,2 -k7,7 | sort -uk2,2 | awk '{print $3}' > markernames-to-remove.txt
# vcftools --vcf height.vcf --exclude markernames-to-remove.txt --recode --recode-INFO-all --out height-filtered

# bcftools view -i 'R2>=0.8' height_fixed.vcf

#Create file with SNP INFO
# cut -f 1-9 sib_bmi_v1.vcf > sib_bmi_INFO.txt

# Clean up
# rm sib_bmi_v1_C*
