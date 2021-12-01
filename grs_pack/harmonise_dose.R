# This script checks the alignment of SNVs in an index file 
# compared to a reference file using the MR-Base function harmonise 
# then corrects the dosage file based on the new aligment and 
# produces an updated SNV index file

##### CURRENTLY NOT DROPPING PALINDROMIC SNVs - LINE 134 TO CHANGE #####

library(TwoSampleMR)
library(dplyr)

# Read in dosage index file
# file.choose()
load(file="/home/benb/projects/sib_bmi2/data/snp_info.Rda")

# Read in dosage file
load(file="/home/benb/projects/sib_bmi2/data/geno.Rda")

# Reference file
# Read in reference file from MR-Base or otherwise
# Read in MR-Base reference file for height
# ao <- available_outcomes()
# subset(ao, grepl("Height", trait))
# a <- extract_instruments(89)
# DO THIS ON THE STAND ALONE COMPUTER WITH WEB ACCESS
load(file="/home/benb/projects/sib_bmi2/data/a.Rda")

# Manual correction of file
#add_snp <- list(id.exposure=89, SNP="rs2089983", effect_allele.exposure="T", other_allele.exposure="NA", eaf.exposure=0.592, beta.exposure=-0.021, se.exposure=0.0031, pval.exposure=6.2e-12, samplesize.exposure=253181, ncase.exposure="NA", ncontrol.exposure="NA", units.exposure="SD (m)", exposure="Height || id:89", pval_origin.exposure="reported", data_source.exposure="mrbase", mr_keep.exposure=TRUE)

#a <- rbind(a, add_snp, stringsAsFactors=FALSE)

# Read in the summary stats from NG
#a <- read.delim2(file ="/home/benb/projects/ped/data/edu.txt", header=T)

# Output directory
output_file_harm_geno <- "/home/benb/projects/sib_bmi2/data/harm_geno.Rda"
output_file_harm_snp_info <- "/home/benb/projects/sib_bmi2/data/harm_snp_info.Rda"
output_file_harm_snp_info_txt <- "/home/benb/projects/sib_bmi2/data/harm_snp_info.txt"
output_file_harm_snp_weights <- "/home/benb/projects/sib_bmi2/data/harm_snp_weights.Rda"

# Align the MR-Base reference file to the positive beta
# if beta.exposure (-) then swap effect_allle.exposure and other_allele.exposure
# eaf.exposure is 1-x

# Swap effect and other allele if beta negative
index <- a$beta.exposure<0
a[index, c("effect_allele.exposure", "other_allele.exposure")] <- a[index, c("other_allele.exposure", "effect_allele.exposure")] 

# Correct eaf
a$eaf.exposure[index] <- (1- a$eaf.exposure[index]) 

# Correct beta
a$beta.exposure[index] <- abs(a$beta.exposure[index]) 

# Check
# test
# test2

# Format the index file so that it can be merged with MR-Base
head(a)
dim(a)
head(snp_info)
dim(snp_info)
dose_index <- data.frame(
  'id.outcome'= 99999,
  'SNP'=snp_info$SNP,
  'effect_allele.outcome'=snp_info$ALT,
  'other_allele.outcome'=snp_info$REF,
  'eaf.outcome'=snp_info$AF,
  'beta.outcome'= 1,
  'se.outcome'= 0.1,
  'pval.outcome'= 0.01,
  'samplesize.outcome'= 99999,
  'ncase.outcome'= 99999,
  'ncontrol.outcome'= 99999,
  'units.outcome'= NA,
  'outcome'= "dose",
  'pval_origin.outcome'= "reported",
  'data_source.exposure'= "dose_file")
head(dose_index)

# Harmonise data
dat <- harmonise_data(
  exposure_dat = a, 
  outcome_dat = dose_index,
  action = 1
)

head(dat)
dim(dat)

# Check some SNVs
#line <- grep('rs7899004', dat$SNP)
#dat[line,]
#head(snp_info)

# Can the changes be stored from the MR-Base harmonise fucntion? No
#   return(list(fix.tab, x))
# could not use the function
# Error in harmonise_cleanup_variables(res.tab) : 
# could not find function "harmonise_cleanup_variables"

# Store the changes from the harmonised file (dat)
head(dat)

# Replace the ID with SNP in dosage file
head(geno)
names(geno) <- snp_info$SNP[match(names(geno), snp_info$ID)]
colnames(geno)[1] <- "IID"
names(geno)
geno[1:5,1:5]

# Check a couple
#line <- grep('rs7542242', snp_info$rsID)
#snp_info[line,]

## MOST IMPORTANT ## 
# When beta.outcome -1 swap the dosage for that specific SNP
# Vector of column names to be changed extracted from the harmonised dat file
cols <- as.character(dat$SNP[dat$beta.outcome==-1]) 

# Function to correct dosage
swap <- function(x) {
  abs(x - 2)
  }

# Apply function to correct the cols
geno[cols] <- lapply(geno[cols], swap)
geno[1:5,1:5]

# Check a couple
#line <- grep('rs2284746', dat$SNP)
#dat[line,]

# Create an updated SNP_info file
# The new effect.alllele, other.allele and eaf is in the harmonised data file
head(snp_info)
head(dat)
harm_snp_info <- data.frame(
  'SNP'=as.character(dat$SNP),
  'effect_allele.dose'=as.character(dat$effect_allele.outcome),
  'other_allele.dose'=as.character(dat$other_allele.outcome),
  'eaf.dose'=dat$eaf.outcome, stringsAsFactors = F)

# Add CHROM, POS, R2 and old.id from snp_info
head(harm_snp_info)
str(harm_snp_info)
str(snp_info)
harm_snp_info <- merge(harm_snp_info, snp_info[, c("CHROM", "POS", "ID", "R2", "SNP")], by = "SNP")
colnames(geno)[1] <- "IID"
names(harm_snp_info)[names(harm_snp_info) == 'ID'] <- 'old.ID'
head(harm_snp_info)
dim(harm_snp_info)

# Check the file
#line <- grep('rs10136129', dat$SNP)
#dat[line,]

# Choose to remove SNPs for being palindromic with intermediate allele frequencies
#drops <- as.character(dat$SNP[dat$mr_keep == "FALSE"]) 

# Drop coloumns with bad SNVs
# geno <- geno[ , !names(geno) %in% drops]
# grep('rs12882130', names(geno))

# Drop rows with bad SNVs
# remove.list <- paste(drops, collapse = '|')
# harm_snp_info <- harm_snp_info %>% filter(!grepl(remove.list, SNP))
# dim(harm_snp_info)

# Save objects
save(geno, file = output_file_harm_geno)
save(harm_snp_info, file = output_file_harm_snp_info)
write.table(harm_snp_info, file = output_file_harm_snp_info_txt, sep = "\t", row.names = F, quote = F)
save(dat, file = output_file_harm_snp_weights)
