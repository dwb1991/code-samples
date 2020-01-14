#######----- Create Global Variables -----########
## @author Chris Bolen, Daniel Bower
## This file is for reading in and processing all the data used by the Shiny app

## The path to the Beat AML directory.
## THIS IS SYSTEM-SPECIFIC. CHANGE THIS ON YOUR COMPUTER
#beatDir = "/gne/obdroot/aml_collection/beat"
beatDir = "/Volumes/OBD/aml_collection/beat"

## path to the directory containing NGS data
ngsDir = file.path(beatDir, "ngs","analysis_ready","outdata")

## path to directory containing the clinical & drug data
clinDir = file.path(beatDir, "clinical","outdata")


######## pull in RNASeq data ########
voomEset<-read_rds(file.path(ngsDir,
   "BEATaml_RNAseq_eset_voomNorm_fullData_20181101.RDS"))
## grab the expression matrix
v <- exprs(voomEset)  ## maybe use a more descriptive variable name here?




####### pull in the drug data #######
drugs<-read_csv(file.path(clinDir, 
    "BEAT_IC50table_allDrugs_20181210.csv"))

tdrugs<-t(drugs)
colnames(tdrugs)<-tdrugs[1,]
tdrugs = tdrugs[-1,]
tdrugs<-as.data.frame(tdrugs)
tdrugs[] <- lapply(tdrugs, function(x) as.numeric(as.character(x)))
tdrugs$labId <- rownames(tdrugs)

drugs_clin<-merge(clinical, tdrugs, by='labId', all=TRUE)
rownames(drugs_clin)<-drugs_clin$labId



####### pull in the clinical data ########

clinical<-read.csv(file.path(clinDir,
    "ClinicalSummary_Harmonized_Wave123_20181101.csv"))

## use the labId as the rownames to match up with other data
rownames(clinical) = clinical$labId


## Clean up the clinical data
## Note -- I used some of my old code for cleaning this data. 
##add age group
clinical$age = as.numeric(as.character(clinical$ageAtSpecimenAcquisition))
clinical$ageGrp = c("<65","65+")[1+(clinical$age>=65)]

##add relapse/refractory/first line definitions
isFL = clinical$isDenovo
isRelapse = clinical$isRelapse
isRef = grepl("Refractory",clinical$responseToInductionTx)

sampleGroup = c(NA, "Relapse","FL")[1+isRelapse+2*isFL]
sampleGroup[isRef & isFL] = "FL_Refractory"
clinical$sampleGroup = sampleGroup


##fix the FLT3 data
flt3Dat = sapply(clinical[,c("FLT3_D835", "FLT3_ITD")], function(x){
  x = as.character(x)
  x[grep("negative",x,ignore.case=T)] = "Negative"
  x[x=="N"]                           = "Negative"
  x[x=="Slight positive (<1% MAF)"]   = "Negative"
  x[grep("positive",x,ignore.case=T)] = "Positive"
  factor(x, c("Negative","Positive"))
})
for(n in colnames(flt3Dat)){clinical[,n]=flt3Dat[,n]}






######### load in WES data ##########
wesFn = file.path(beatDir, "ngs/rawdata/wes_20181004",
                  "BeatAML_Somatic_vars_2018_09_19.xlsx")
allWES = read.xlsx(wesFn, 2)

## get the sample map for the sequencing ids
mapFn = file.path(beatDir, "ngs/rawdata/wes_20181004",
                  "BeatAML_seqcap_2018_09_19_public_dashboard.xlsx")
wesMap = read.xlsx(mapFn,2)
wesMap = wesMap[,c("AML_Original_LabID","AML_SeqID")]

## add the labID to the WES file
allWES = merge(allWES, wesMap, 
               by.x="Tumor_Sample_Barcode", by.y="AML_SeqID",all.x=T)

