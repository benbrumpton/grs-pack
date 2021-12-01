# This R script merges the VCF snp info
# with rsID from the hg19 text file and
# creates snp_info.Rda

#Input
infoIn <- "/home/benb/projects/sib_bmi2/data/bmi_info.txt"
hg19In <- "/home/benb/projects/sib_bmi2/data/locke_eur_effect_rsids_hg19.txt"

#Output
snp_info_file <- "/home/benb/projects/sib_bmi2/data/snp_info.Rda"
snp_info_file_txt <- "/home/benb/projects/sib_bmi2/data/snp_info.txt"

# Read in
vcf_info <- read.table(infoIn, stringsAsFactors=F)
hg19_info <- read.table(hg19In, stringsAsFactors=F)

# Add headers
colnames(vcf_info) <- c("ID", "CHROM", "POS", "ALT", "REF", "AF", "MAF", "R2")
colnames(hg19_info) <- c("chr", "pos", "SNP")

# Add id to both
hg19_info$id <- paste(substring(hg19_info$chr, 4), hg19_info$pos, sep = ":")
vcf_info$id <- gsub("\\_.*","",vcf_info$ID)

# Merge
snp_info <- merge(vcf_info, hg19_info, by = "id")

# Wirte out
save(snp_info, file = snp_info_file)
write.table(snp_info, file = snp_info_file_txt, sep = "\t", row.names = F, quote = F) 

