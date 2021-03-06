#This is the code for ForestGap model computation of spatial indicators
#It will compute, variance; skewness; Moran's I; and Power spectrum indicators. 

###########################

#Pre- loadings:
library(devtools) 
install_github('fdschneider/caspr')
library(spatialwarnings)
library(ggplot2)
setwd("C:/Users/USUARIO/Dropbox/Curro/IFCAM project/Tests with Sabiha")
load("result_forestgap_processed.rda")

source("Sabiha_null_model_helpers.R")
source("Sabiha_indicators_ALL.R")
source("Sabiha_Functions_separatedly.R")
source("plot_Figure2i.R")
source("Sabiha_reducedmatrix_ews.R")

#Select transects of interest (skip if already found)
merge_two_branches <- function(up, low) { 
  data.frame(branch = c(rep("upper", nrow(up$DatBif)), 
                        rep("lower", nrow(low$DatBif))), 
             rbind(up$DatBif, low$DatBif))
} 
merged_results <- merge_two_branches(upper_branch, lower_branch)

#######FIG 1.i
# Do a graph "à la flo" (hard to read for now, needs more tweaking)
ggplot() + 
  geom_raster(aes(x = delta, y = d), fill = "grey70",
              data = subset(lower_branch$DatBif, mean_cover_. < .05)) + 
  geom_contour(aes(x = delta, y = d, z = mean_cover_.), 
               data = subset(upper_branch$DatBif), 
               color = "black", linesize = .1) 


#######ONLY DO IF EXPLORING THE MODEL
# Let's extract a 1D bifurcation diagram over delta (d in x-axis). 
unydel<-unique(merged_results$delta)
a1=list()
for (i in 1:length(unydel)){
  data_subset <- subset(merged_results, delta==unydel[i])
  a1[[i]]<-ggplot(data_subset) + 
    geom_point(aes(d, mean_cover_., color = branch)) +
    ggtitle(paste("delta =",unydel[i]))
  print(a1[[i]])
  
}

####################################3duplicate through d (delta in x-axis)
#Do it over d (delta in x-axis)
unyd<-unique(merged_results$d)
a2=list()
for (i in 1:length(unyd)){
  data_subset <- subset(merged_results, d==unyd[i])
  a2[[i]]<-ggplot(data_subset) + 
    geom_point(aes(delta, mean_cover_., color = branch)) +
    ggtitle(paste("d =",unyd[i]))
  print(a2[[i]])
  
}
###########################################################################
###########################################################################


#Subset the transects of interest:
unydel<- unique(upper_branch$DatBif$delta)# re-run if you skipped the code above
unyd<- unique(upper_branch$DatBif$delta)# re-run if you skipped the code above

deltaSEL<-unydel          #This means we want all delta values (delta will be x-axis)
dSEL<-c(unyd[2],unyd[9])  #We want d values contained in the second (hysteresis) and 
#ninth (continuous transition) unique values of d 
#(see bifurcation diagrams 1D plotted previously). 
#To see actual values type unyd[2] or unyd[9]

dSEL<-c(0.01,0.1)

closest=function(x,y) y[which.min(abs(y-x))]
idx<-as.vector(sapply(dSEL,function (x,upper_branch) which(with(upper_branch$DatBif,d==closest(x,d))), upper_branch=upper_branch))
Transits_dat<- upper_branch$DatBif[idx,]

landscapes<-'['(upper_branch[[2]],idx)
#Re-ordering landscapes to be only a list and not a list of a list
l=list()
n=1;
allo_temp<-c(1:(length(landscapes)*10))
Res_dat=data.frame(code=allo_temp,d=allo_temp, delta=allo_temp,replicate=allo_temp,cover=allo_temp)
for (i in 1:length(landscapes)){
  for (k in 1:10){
    l[[n]]<-landscapes[[i]][[k]]
    Res_dat$code[n]<-i
    Res_dat$d[n]<-Transits_dat$d[i]
    Res_dat$delta[n]<-Transits_dat$delta[i]
    Res_dat$replicate[n]<-k
    Res_dat$cover[n]<-Transits_dat$mean_cover_.[i]
    n=n+1
  }
}
Res_dat$code<-as.factor(Res_dat$code)
Res_dat<-indicators_ALL(l, Res_dat,subsize = 5, nreplicates = 5)

###Reshapping the data
#create a dataframe template without replicates
MATRIX<-subset(Res_dat, select = c(1,2,3,5))
MATRIX<-MATRIX[!duplicated(MATRIX),]
#Extract as matrix the indicators
fg<-data.matrix(Res_dat[,c(6:13)])
#Compute mean of replicates by combination of parameters
meanfg<-t(sapply(MATRIX$code,function(x,y,z) apply(y[z==x,],2,mean),y=fg,z=Res_dat$code))
#Compute CI of replicates by combination of parameters
fun=function(x) {if(sum(is.na(x))<8 && length(unique(x))>1){mean(x)-t.test(x)$conf.int[1]}else{NA}}
CIfg<-t(sapply(MATRIX$code,function(x,y,z) apply(y[z==x,],2,fun),y=fg,z=Res_dat$code))
#Adding variables to MATRIX
MATRIX$var_mean<-meanfg[,1]
MATRIX$var_CI<-CIfg[,1]
MATRIX$nullvar_mean<-meanfg[,2]
MATRIX$nullvar_CI<-CIfg[,2]

MATRIX$Moran_mean<-meanfg[,3]
MATRIX$Moran_CI<-CIfg[,3]
MATRIX$nullMoran_mean<-meanfg[,4]
MATRIX$nullMoran_CI<-CIfg[,4]

MATRIX$Skew_mean<-meanfg[,5]
MATRIX$Skew_CI<-CIfg[,5]
MATRIX$nullSkew_mean<-meanfg[,6]
MATRIX$nullSkew_CI<-CIfg[,6]

MATRIX$SDR_mean<-meanfg[,7]
MATRIX$SDR_CI<-CIfg[,7]
MATRIX$nullSDR_mean<-meanfg[,8]
MATRIX$nullSDR_CI<-CIfg[,8]

#Define the 2 transits from MATRIX
SEL=unique(MATRIX[,2])
DBplot1<-subset(MATRIX,MATRIX[,2]==SEL[1]) #database of transit 1
DBplot2<-subset(MATRIX,MATRIX[,2]==SEL[2]) #database of transit 2


plot_Figure2i(DBplot1,DBplot2)


