library(openxlsx)

## Load 10,174 Best INFerred Genes (BING)
# https://clue.io/connectopedia/l1000_gene_space
# https://clue.io/command?q=/gene-space
BING <- read.xlsx("~/computations/crispr_cmap/gene-space_2018-08-01.xlsx", sheet = 1)
BING <- BING[BING$Type == "best inferred" | BING$Type == "landmark",]
BING <- BING$Symbol

## Subset BING genes from Cromer et al. diffentially expressed genes (DEGs) 
# See article's Supplemental Information; doi: 10.1016/j.ymthe.2018.06.002)
# Columns has been renamed in Excel as follow: "Mock" = "Elect"; "mRNA" = "mRNAalone"; "mRNA+AAV" = "mRNAandAAV";
# "RNP" = "RNPalone"; "RNP+AAV" = "RNPandAAV"; "AAV" = "AAValone"
DEGs <- read.xlsx("~/computations/crispr_cmap/CRISPR_Cas9_DifferentiallyExpressedTranscriptsKnownAndUnknownCromer2018_renamed.xlsx")
DEGs <- DEGs[!is.na(DEGs$Gene),]
DEGs <- DEGs[!duplicated(DEGs$Gene),]
DEGs <- DEGs[DEGs$Gene %in% BING,]

## Subset Up and Down regulated genes for each treatment 
treatment <- c("Elect.", "mRNAalone.", "mRNAandAAV.", "RNPalone.","RNPandAAV.","AAValone.")
MLogP = 7
N = 150
for (i in 1:length(treatment)){
        df <- DEGs[,colnames(DEGs) %in% c("Gene", grep(treatment[i], colnames(DEGs), value = TRUE))]
        up <- df[which(df[,2] > 0 & df[,3] >= MLogP),]
        up <- na.omit(up[order(up[,2], decreasing = TRUE),][1:N,"Gene"])
        dn <- df[which(df[,2] < 0 & df[,3] >= MLogP),]
        dn <- na.omit(dn[order(dn[,2], decreasing = FALSE),][1:N,"Gene"])
        write(up,file = paste0("~/computations/crispr_cmap/cmap_input/",gsub("\\Q.\\E","",treatment[i]),"-Up.txt"))
        write(dn,file = paste0("~/computations/crispr_cmap/cmap_input/",gsub("\\Q.\\E","",treatment[i]),"-Dn.txt"))  
}
