




## generates counts for the histogram 
## To Daniel: Any reason you're not letting plotly handle this for you? 
## (i.e. by using the 'hist' function? Seems like 99% of this code is unnecessary)
## Also -- you spend a lot of code matching up the drug data with the clin data;
## I suggest doing that once in the "global" file to create a 'drugs' matrix
## that's the same shape as the 'clin' file. Then you don't have to do it in
## every function (although it doesn't seem necessary here at all)
get_hist_data<-function(dr){
  ## subset the drugs array to just the drug of interest 
  ## no need to remove NAs. Tally removes NAs for you
  drug.df<-t(drugs[drugs$X1==dr,-1])
  colnames(drug.df) <- "drug"
  drug.df = as.data.frame(drug.df)
  
  ## seriously, everything past here could be skipped by just using "hist"
  drug.df[,1]<-round(drug.df[,1], digits=2)
  dfsum <- drug.df %>%
    group_by(drug.df[,colnames(drug.df)]) %>%
    tally() 
  colnames(dfsum)<-c(colnames(drug.df), "n")
  return(dfsum)
}







## apparently this function's sole purpose is to create a merged "clinical" 
## matrix with a single column, "inhibitor", containing the drug of interest.
## If that is the sole purpose, we should be doing this in the global.R function
create_d1<-function(dr){
  
  drug.df<-t(drugs[drugs$X1==dr,-1])
  colnames(drug.df) <- "inhibitor"
  ## not always necessary, but easier in this case
  drug.df = drug.df[complete.cases(drug.df),,drop=F]
  
  ## unnecessary. This'll happen when you merge
  #clinfilter<-clinical[clinical$labId %in% colnames(drug.df),]
  ## doing this in global.R now
  #rownames(clinfilter)<-clinfilter$labId
  
  
  trait<- merge(clinical, drug.df, by='row.names')
  ## drop the "Row.names" column added by merge
  rownames(trait) = trait[,"Row.names"]
  trait = trait[,-1]
  
  ## this is also taken care of by merge
  # df4<-df2[rownames(df2) %in% trait$labId,]
  # trait_inhibitor<-data.frame(trait, df4)
  
  ## and this part apparently isn't used at all
  # bottom<-trait[trait$drug <= quantile(trait$drug,prob=pct/100),]
  # top<-trait[trait$drug >= quantile(trait$drug,prob=1-pct/100),]
  # both<-rbind(top, bottom)
  # d1<-trait_inhibitor
  return(trait)
}


## again, a function designed just to match up the data. In this case, adding
## both drug and gene
create_Expression<-function(dr, gene){
  ## grab the clin data with the "inhibitor" column added to it
  trait = create_d1(dr)
  ## grab expression of the gene (TODO: add checks that the gene exists)
  expr<-v[gene,]

  ## combine
  df_full<-merge(trait, expr,by="row.names",all.x=TRUE)
  colnames(df_full)[which(names(df_full) == 'y')] <- "Expression"
  
  return(df_full)
}

create_volcano<-function(){
  df.v<-data.frame(clinical$labId, clinical$FLT3_ITD)
  colnames(df.v)<-c("labId","FLT3_ITD")
  df.v$labId<-as.character(df.v$labId)
  df.v<-df.v[complete.cases(df.v),]
  
  drugs2<-drugs[colnames(drugs) %in% df.v$labId]
  rownames(drugs2)<-drugs$X1
  dfv2<-df.v[df.v$labId %in% colnames(drugs),]
  dfv3<-dfv2[order(dfv2$labId),]
  dfv4<-t(dfv3)
  drugs_final<-rbind(drugs2, dfv4[2,])
  tdrugsfinal<-as.data.frame(t(drugs_final))
  
  logNew = function(x) ifelse(x!=0, log2(x), NA)
  logdrugs<-as.data.frame(apply(drugs2, 2, logNew))
  
  logdrugsfinal<-rbind(logdrugs, dfv4[2,])
  tlogdrugs<-as.data.frame(t(logdrugsfinal))
  colnames(tlogdrugs)[321]<-"FLT3_ITD"
  
  grp1<-which(tlogdrugs$FLT3_ITD == "Negative")
  grp2<-which(tlogdrugs$FLT3_ITD == "Positive")
  negative<-logdrugs[grp1]
  positive<-logdrugs[grp2]
  pv = rep(0,320)
  for (i in 1:320){
    if (all(is.na(positive[i,]) | all(is.na(negative[i,])))){
      pv[i]<-0
    }else{
      results<-wilcox.test(as.numeric(positive[i,]),as.numeric(negative[i,]))
      pv[i]<-results$p.value
    }
  }   
  positive$mean<-rowMeans(positive, na.rm=T)
  negative$mean<-rowMeans(negative, na.rm=T)
  foldchange<-negative$mean-positive$mean
  results = cbind(foldchange, pv)
  results = as.data.frame(results)
  rownames(results)<-rownames(positive)
  return(results)
}
create_WES<-function(gene = "ENSG00000141510", dr="Venetoclax"){
  library('biomaRt')
  mart <- useDataset("hsapiens_gene_ensembl", useMart("ensembl"))
  G_list <- getBM(filters= "ensembl_gene_id", attributes= c("entrezgene","hgnc_symbol","ensembl_gene_id"),values=gene,mart= mart)
  
  
  library(dplyr)
  df<-drugs_clin %>% dplyr::select(dr)
  drug_WES<-allWES[allWES$Hugo_Symbol %in% G_list$hgnc_symbol,]
  drug_WES<-drug_WES[drug_WES$AML_Original_LabID %in% rownames(df)[complete.cases(df)],]
  drug_WES<-merge(drug_WES, drugs_clin, by.x="AML_Original_LabID", by.y="row.names")
  return(drug_WES)}


myLimma = function(eset,aformula,n=100000,p.value=0.05,lfc=0){
  design = model.matrix(aformula, eset)
  fit1 = eBayes(lmFit(eset, design))
  topTable(fit1,coef=2,n=n,p.value=p.value,lfc=lfc)
}

volcanoPlot = function(dat,labelCount=c(5,5),p=.05,pval=.05,lfc=0,goi=c()) {
  require(ggrepel)
  signifLevels = c("Not Signif","Nominal Signif","Signif")
  signifColors = c("grey","yellow3","red3")
  dat$Significance = rep(signifLevels[1],times=dim(dat)[1])
  dat$Significance[dat$P.Value < pval & abs(dat$logFC) > lfc] = "Nominal Signif"
  dat$Significance[dat$adj.P.Val < p & abs(dat$logFC) > lfc] = "Signif"
  dat$Significance = factor(dat$Significance,levels=signifLevels)
  dat = dat %>%
    mutate(labelOrder = abs(logFC)^2 + (log10(P.Value)*2)^2) %>%
    arrange(desc(labelOrder))
  dat$toLabel = F
  dat[ dat$symbol %in% unlist((dat %>% filter(logFC>0) %>% dplyr::select(symbol)))[1:labelCount[1]], "toLabel" ] = T
  dat[ dat$symbol %in% unlist((dat %>% filter(logFC<0) %>% dplyr::select(symbol)))[1:labelCount[2]], "toLabel" ] = T
  dat[ dat$symbol %in% goi, "toLabel" ] = T
  squish = function(x) { (1-x)^2 * 0.1}
  ggplot(dat, aes(x = logFC, y = -log10(P.Value))) +
    geom_point(aes(color = Significance, alpha = squish(P.Value) )) +
    scale_color_manual(values = signifColors ) +
    theme_bw() +
    scale_alpha_continuous(guide = FALSE) +
    scale_size_continuous(guide = FALSE) +
    scale_fill_manual(values=signifColors,breaks=signifLevels) +
    geom_text_repel(
      data = subset(dat, toLabel),
      aes(label = symbol),
      box.padding = 0.25,
      point.padding = 0.3
    )
}
