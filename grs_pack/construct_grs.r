# This scripts constructs both a weighted and unweighted GRS
rm(list = ls())

# Read in dosage file
load(file="/home/benb/projects/sib_bmi2/data/harm_geno.Rda")

# Need the harmonised dat file from MR-Base
load(file="/home/benb/projects/sib_bmi2/data/harm_snp_weights.Rda")

# Output directory
output_file_harm_geno_grs <- "/home/benb/projects/sib_bmi2/data/harm_geno_grs.Rda"

# Vector of betas for each SNV in order of dosage file
order <- names(geno[, -1])
weights <- unlist(dat[match(order, dat$SNP),][c("beta.exposure")])

# Create a dosage file to weight
dose <- geno[, -1]

# Weight each allele and sum all rows
dose.w <- data.frame(mapply(`*`, dose, weights))
dose.w$grs <- rowSums(dose.w)

# Sum all columns but not IID to create an unweighted GRS
geno$cnt.bmi.69 <- rowSums(geno[, -1])

# Column bind the grs to geno
geno <- data.frame(cbind(geno, dose.w$grs))
names(geno)[names(geno) == 'dose.w.grs'] <- 'grs.bmi.69'

save(geno, file = output_file_harm_geno_grs)
