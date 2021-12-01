# This R script reads the dosage.txt file
# transposes it and 
# joins it with the sample ID
# source('/home/benb/projects/sib_bmi/scripts/combine_dose_sampleID.r')

setwd("/home/benb/projects/sib_bmi2/data/") # (1)set directory

dosageIn <- 'bmi.txt'
sampleIn <- 'sample_id.txt'

genoOut <- '/home/benb/projects/sib_bmi2/data/geno.Rda'

# Read files
a <- read.table(dosageIn , stringsAsFactors=F)
b <- read.table(sampleIn , stringsAsFactors=F)

# Store SNV names
snv_names <- a$V1

# Transpose all but SNV names
a2 <- as.data.frame(t(a[,-1]))

# Add SNV names
names(a2) <- snv_names

# Join b and a
geno <- cbind(b, a2)

# Renmes coloum name geno to ID
names(geno)[names(geno) == 'V1'] <- 'ID'

# Save geno file
save(geno, file = genoOut)

# Compare to old file
#load(file="/home/benb/projects/ped/data/.Rda")
# Checked

# Read in BMI
#bmi <- read.table('/home/benb/archive/benb/BMI_NT3BLM/BMI_NT3BLM_pheno.txt', header = T, stringsAsFactors=F)
# Merge with geno
#answer <- merge(bmi, geno, by.x = 'IID', by.y = 'ID')
#dim(answer)
#head(answer)
#summary(lm(answer$BMI_NT3BLM ~ answer$'16:53803574_T/A'))
# This checked out. The SNP count allele freq was similar to ALT, the ALT was the effect allele and associated with BMI

