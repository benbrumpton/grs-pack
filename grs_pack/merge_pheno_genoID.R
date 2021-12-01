#Create a file with both the PID and Sentrix ID
#source('/home/benb/projects/sib_bmi/scripts_cvd/merge_pheno_genoID.R')

# What is the PID?
# PID_105927

# Location of the master file
key <- read.csv2("/mnt/work/bridge/master-key/allin-master-key-20160702.csv", header=T, as.is=T) # Read in key

# Location of the phenotype bridges
 kfiles <- list.files("/mnt/work/bridge/bridges-from-hunt","csv$",recursive=T,full.name=T)

# Check and update bridge file number below
# print(kfiles[11])

 bridge <- read.delim(kfiles[34], header = TRUE, sep = "\t") # Read in the bridge

# Merge the masters key with the bridge
 names(bridge)[names(bridge)=="PID.105118"] <- "gid.current" # Rename key
 tmp <- merge(key, bridge, by="gid.current", sort=F)

# Add Genotype ID and Cov
cov = read.table(gzfile("/mnt/work/genotypes/DATASET_20161002/SAMPLE_QC/Masterkey_DATASET.20161002.txt.gz"), header=T)
tmp2 <- merge(tmp, cov, by="SentrixID")

# Add constructed pheno
#rsync -av -P /home/benb/cargo/benb_in/pheno.txt /home/benb/projects/vt/files/pheno.txt
#custom_pheno <- read.table("/home/benb/projects/ped/data/CVD_phenotypeConstructBen_20180918.txt", header=T)

# Add pheno from HUNT file
library(foreign)
pheno <- read.spss("/mnt/work/phenotypes/phenotypes-from-data-owners/allin-neuro-sleep-2015_14046/kilde/hunt/2016-01-05-main-export/2016-01-05_105927_Data_CRPfixed.sav", to.data.frame=TRUE)

# Check pheno PID and bridge PID are the same
print(names(pheno[1]))

names(pheno)[names(pheno)=="PID_105927"] <- "PID.105927" # PID
pheno$Sex <- NULL
pheno$BirthYear <- NULL
tmp3 <- merge(tmp2, pheno, by='PID.105927')

# Check pheno PID and bridge PID are the same
# print(names(pheno[1]))
# names(custom_pheno)[names(custom_pheno)=="PID.105828"] <- "PID.105828" # Rename pheno
# tmp3 <- merge(tmp2, custom_pheno, by='PID.105828')

#pheno$PID.105927 <- NULL # Not included in final

pheno_names <- names(pheno[,-1])
#pheno_names <- c("SSS_ICD") # Add the phenotypes or cov from this file

final <- tmp3[,c("FID", "IID", pheno_names, "BatchDetailed",
"Sex", "BirthYear", "PC1", "PC2", "PC3", "PC4", "PC5", "PC6", "PC7", "PC8", "PC9", "PC10",
"PC11", "PC12", "PC13", "PC14", "PC15", "PC16", "PC17", "PC18", "PC19", "PC20", "Ancestry4",
"UNRELATED", "batch")]

final2 <- unique(final)

# Save this as a text file to use in anlaysis
write.table(final2, "/home/benb/projects/sib/data/pheno_genotypeID.txt",row.names=F,quote=F, col.names=T, sep = "\t") 
