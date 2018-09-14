#######################################################
#                                                     #
#                       Carac Quanti                  #
#                                                     #
#######################################################
require("dplyr")
require("data.table")

var_quanti<-function(myDb,target, varX=NULL,keep.all=F,threshold=0){
  myDb=data.table(myDb)
    # Define numerical values
  if (length(varX)==0) varX=
      colnames(myDb[,sapply(myDb,function(x) {is.numeric(x) & !is.factor(x)}),with=F])
  varX=setdiff(varX,target)
  
  
  myDb <- na.omit(myDb[,c(varX,target),with=F])
  # Just to get rid off that annoying message
  for( col in 1:ncol(myDb)){
    if(class(myDb[[col]]) == 'integer'){
      myDb[, eval(colnames(myDb)[col]) := as.double(get(colnames(myDb)[col]))]
    }
  }
  
  
  # Quantitative analysis
  myDb2<-melt(myDb,id=c(target),measure.vars=varX)
  myDb2[,c("group.average","group.n"):=list(mean(value),.N),by=c(target,"variable")]
  myDb2[,c("overall.average","overall.n","overall.std"):=list(mean(value),.N,sd(value)),by=variable]
  myDb2[,value:=NULL]
  myDb2=unique(myDb2)
  # Probability of having different means
  myDb2[,c("vTest"):=list(
    (group.average-overall.average)/(sqrt(((overall.n-group.n)/
                                            ((overall.n-1)*(group.n))))*overall.std))]
  myDb2[,c("Prob","vStars"):=list(1-pnorm(abs(vTest)),
                                  cut(vTest,breaks=c(-Inf,-5,-2.31,-1.64,-1.28,1.28,1.64,2.31,5,Inf),
                                      labels = c("****|","***|","**|","*|","|","|*","|**","|***","|****"))
  )]
  
  # Filter on prob
  if (threshold!=0){
    myDb2=myDb2[abs(Prob)<threshold]
  }
  #sort
  myDb2=myDb2[order(get(target),vTest)]
  
  #Keep numbers ?
  if (keep.all==F){
    myDb2[,c("overall.n","overall.std"):=NULL]
  }
  
  #prompt
  myDb2[]
}


#######################################################
#                                                     #
#                       Carac quali                   #
#                                                     #
#######################################################


var_quali<-function(myDb, target, varX=NULL,keep.all=F,threshold=0){
  myDb=data.table(myDb)
  # I need all factors to be considered as characters
  for( col in 1:ncol(myDb)){
    if(class(myDb[[col]]) == 'factor'){
      myDb[, eval(colnames(myDb)[col]) := as.character(get(colnames(myDb)[col]))]
    }
  }
  
  # Define char values
  if (length(varX)==0) varX=
    colnames(myDb[,sapply(myDb,function(x) {is.character(x)}),with=F])
  varX=setdiff(varX,target)
  
  
  myDb <- na.omit(myDb[,c(varX,target),with=F])
  # Quantitative analysis
  myDb2<-melt(myDb,id=c(target),measure.vars=varX)
  
  # Basic numbers
  ##  Count number of policies per modality
  myDb2[,nkj:=as.double(.N),by=c(target,"variable","value")]
  ##  Count number of policies per target value
  myDb2[,nk_:=as.double(.N),by=c(target,"variable")]
  ##  Count number of policies per variable modality
  myDb2[,n_j:=as.double(.N),by=c("variable","value")]
  ##  Count total number of policies
  myDb2[,n:=as.double(.N),by=c("variable")]

  # Percentages and vTest
  myDb2[,c("PctIntra","PctTot","PctMod","vTest"):=list(
    nkj/nk_,
    n_j/n,
    nkj/n_j,
    (nkj - n_j/n*nk_)/sqrt((n_j/n*nk_ * (n - nk_)/(n - 1))*(1-n_j/n))
  )]
  
  
  # Indicators
  myDb2=unique(myDb2)
  # Probability of having different means
  myDb2[,c("Prob","vStars"):=list(1-pnorm(abs(vTest)),
                                  cut(vTest,breaks=c(-Inf,-5,-2.31,-1.64,-1.28,1.28,1.64,2.31,5,Inf),
                                      labels = c("****|","***|","**|","*|","|","|*","|**","|***","|****"))
  )]
  
  # Filter on prob
  if (threshold!=0){
    myDb2=myDb2[abs(Prob)<threshold]
  }
  
  # Ranking before sorting
  myRank=rank(myDb2[,max(abs(vTest)),by=variable]$V1)
  myDb2[,variable:=factor(variable,levels=levels(myDb2$variable)[myRank])]
  
  #sort
  myDb2=myDb2[order(get(target),variable,vTest)]
  
  #Keep numbers ?
  if (keep.all==F){
    myDb2[,c("nkj","nk_","n_j","n"):=NULL]
  }
  #prompt
  myDb2[]
}
