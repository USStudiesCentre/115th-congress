###########################################################################
## plotting
library(pscl)
load("../data/rc.rda")
load("../data/id1.rda")
load("../data/xbar.rda")

##rc <- dropRollCall(rc,dropList = list(lop=0,legisMin=5))

## minimum number of votes for plotting
plotMin <- 50
if(id1$m<plotMin){
  plotMin <- 1       ## for early in the Congress
}

legisNames <- rownames(rc$votes)

## drop legislators with lots of missed votes from the plotting
bad <- apply(rc$votes,1,function(x)sum(!is.na(x))<plotMin)
badNames <- legisNames[bad]

plotData <- merge(x=data.frame(x=xbar[,1],
                    lo=xbar[,2],
                    up=xbar[,3],
                    legisNames=rownames(xbar),
                    stringsAsFactors=FALSE),
                  y=data.frame(legisNames=rownames(rc$legis.data),
                      party=rc$legis.data$party,
                      firstnm=NA,
                      lastnm=rownames(rc$legis.data),
                      stringsAsFactors=FALSE),
                  all=TRUE,
                  stringsAsFactors=FALSE)
plotData <- plotData[!(plotData$legisNames %in% badNames),]
                             
plotData$col <- rep("green",dim(plotData)[1])
plotData$col[plotData$party=="R"] <- "red"
plotData$col[plotData$party=="D"] <- "blue"

indx <- order(plotData$x)          ## sort ideal point estimates
plotData <- plotData[indx,]

## accents etc
##theOne <- grep("\\\303\\\241",plotData$legisNames)

## plotData$legisNames <- gsub(plotData$legisNames,
##                             pattern="\\\303\\\241",
##                             replacement="\\\xE1")
## ## accents
## Encoding(plotData$legisNames) <- "latin1"
## Encoding(plotData$firstnm) <- "latin1"
## Encoding(plotData$lastnm) <- "latin1"
## plotData$firstnm[plotData$lastnm=="Grijalva"] <- "Raúl"
## plotData$lastnm[plotData$firstnm=="Nydia"] <- "Velázquez"
## plotData$firstnm <- gsub(plotData$firstnm,pattern="<U+00E9>",replacement="é",fixed = TRUE)



pdf(file="x2.pdf",                ## open PDF file
    width=297/25.4,
    height=420/25.4)

par(mfrow=c(1,2),                 ## plotting options
    mar=c(1.5,0.25,2,0.25),
    oma=c(0,0,2.25,0),
    mgp=c(2,.32,0),
    tcl=-.15)

plotlims <- range(plotData$lo,plotData$up, na.rm = TRUE)
axislims <- c(-3,3)
axisticks <- seq(from=axislims[1],to=axislims[2],by=1)
axislabs <- as.character(axisticks)
textloc <- 1.01*plotData$lo
textloc[textloc > -3] <- 1.01 * -3

n <- dim(plotData)[1]
half <- ceiling(n/2)
ylims <- c(.33,half+.67)
plot(x=plotlims,
     y=c(1,half),       ## empty plotting region
     type="n",
     cex=.5,  
     ylim=ylims,
     xaxs="i",
     yaxs="i",
     axes=FALSE,
     xlab="",ylab="")

abline(v=axisticks,
       lwd=3,
       col=gray(.95))

for(i in 1:half){  ## loop over first half
  lines(y=c(i,i),  ## line for confidence interval
        x=c(plotData$lo[i],plotData$up[i]),
        lwd=1.5)
  points(y=i,
         x=plotData$x[i],  ## overlay posterior mean
         col=plotData$col[i],
         pch=16,
         cex=.9)
  thiscex <- .450
  text(plotData$up[i],i,
       plotData$legisNames[i],
       cex=thiscex,adj=-0.1)
}
axis(1,at=axisticks,labels=axislabs,cex=.5,lwd=1.5)
axis(3,at=axisticks,labels=axislabs,cex=.5,lwd=1.5)

text(x=.96*par()$usr[1] + .04*par()$usr[2],
     y=.96*par()$usr[4] + .04*par()$usr[3],
     pos=4,
     paste("ROLL CALL DATA: CLERK.HOUSE.GOV",
           "ANALYSIS BY SIMON JACKMAN",
           format(Sys.time(), "%H:%M %a %b %d %Y %Z"),
           sep="\n"),
     cex=.75,
     col=gray(.67),
     xpd=NA)


plot(x=plotlims,
     y=c(1,half),
     cex=.5,
     type="n",
     axes=FALSE,
     xlab="",ylab="",
     ylim=ylims,
     xaxs="i",
     yaxs="i")

abline(v=seq(ceiling(plotlims[1]),
         floor(plotlims[2]),
         by=1),
       lwd=3,
       col=gray(.95))

for(i in (half+1):n){
  j <- i - half
  lines(y=c(j,j),
        x=c(plotData$lo[i],plotData$up[i]),
        lwd=1.5)
  points(y=j,
         x=plotData$x[i],
         col=plotData$col[i],
         pch=16,
         cex=.9)
  thiscex <- .450
  text(plotData$lo[i],j,
       plotData$legisNames[i],
       cex=thiscex,adj=1.1)
}
axis(1,at=axisticks,labels=axislabs,cex=.5,lwd=1.5)
axis(3,at=axisticks,labels=axislabs,cex=.5,lwd=1.5)

mtext(paste("115TH U.S. HOUSE OF REPRESENTATIVES, ESTIMATES OF MEMBERS' PREFERENCES (95% CREDIBLE INTERVALS)", 
            "\n",
            id1$m," NON-UNANIMOUS ROLLCALLS",
            sep=""),
      side=3,
      line=-.5,
      cex=1.1,
      outer=TRUE,
      xpd=NA)

dev.off()

######################################
## ideal points against Trump vote
rc0 <- dropRollCall(rc,dropList = list(lop=0,legisMin=5))
prefs <- data.frame(y=id1$xbar,
                    legisNames=rownames(id1$xbar),
                    party=rc0$legis.data$party,
                    id=paste(rc0$legis.data$state,
                             rc0$legis.data$cd,
                             sep="-"),
                    stringsAsFactors=FALSE)

load("../data/dat16.RData")
dat16$id <- paste(dat16$stpost,dat16$district,sep="-")
plotData <- merge(prefs,dat16,
                  by="id",
                  stringsAsFactors=FALSE)

## accents etc
## theOne <- grep("\\\303\\\241",plotData$legisNames)
## plotData$legisNames <- gsub(plotData$legisNames,
##                             pattern="\\\303\\\241",
##                             replacement="\\\xE1")
## Encoding(plotData$legisNames) <- "latin1"

rownames(plotData) <- plotData$legisNames

if("D1" %in% names(plotData)){
  plotData$y <- plotData$D1
  plotData$D1 <- NULL
}

if("dpvote" %in% names(plotData)){
  plotData$x <- 100 - plotData$dpvote   ## Trump 2-party pres vote in district
  plotData$obama <- NULL
}

##plotData <- plotData[!(plotData$legisNames %in% badNames),]

## clobber missing Obama vote share
plotData <- plotData[!is.na(plotData$x),]

n <- dim(plotData)[1]
col <- rep("black",n)
col[plotData$party=="R"] <- "red"
col[plotData$party=="D"] <- "blue"

watermark <- function(){
  xlims <- grid::convertX(grid::unit(0:1, "npc"), "native", valueOnly=TRUE)
  ylims <- grid::convertY(grid::unit(0:1, "npc"), "native", valueOnly=TRUE)
  panel.text(x=xlims[1],
             y=.06*ylims[1] + .94*ylims[2],
             pos=4,
             cex=.45,
             paste("IDEAL POINT ESTIMATES AS OF ",
                   format(Sys.time(), "%H:%M %a %b %d %Y %Z"),"\n",
                   "BASED ON ANALYSIS OF ",id1$m,
                   " NON-UNANIMOUS ROLLCALLS.\n",
                   "ROLL CALL DATA FROM CLERK OF THE HOUSE\n",
                   ##paste(badOnes,collapse=" & "),
                   ##" NOT SHOWN.\n",
                   "CURVES ARE LOCAL LINEAR REGRESSIONS (LOESS, SPAN=2/3, OUTLIER ROBUST)\n",
                   sep=""))
  invisible(NULL)
}

idResid <- function(group.number,subscripts,xjittered){
  lo <- loess(y~x,
              span=2/3,
              family="symmetric",
              degree=1,
              data=plotData[subscripts,],
              y=TRUE,x=TRUE)
  r <- resid(lo)
  rabs <- abs(r)
  print(sort(r,decreasing=TRUE,na.last=TRUE)[1:10])
  num <- 3
  if(group.number==2){
    num <- 2
  }
  theOnes.indx <- order(rabs,decreasing=TRUE,na.last=TRUE)[1:num]

  ##if(group.number==2)
  ##  extra <- grep("CAO",names(r))
  ##else
  ##  extra <- c(which.max(lo$y),
  ##             grep("EDWARDS \\(D TX-17\\)",names(r)),
  ##             grep("GRIFFITH \\(D AL-5\\)",names(r)))
  if(group.number==1){
    extra <- grep("Matheson \\(D UT-4\\)",names(r))
  }
  if(exists("extra"))
    theOnes.indx <- c(theOnes.indx,extra)

  theOnes <- names(rabs)[theOnes.indx]
  print(theOnes)
  n <- length(theOnes)
  pos <- rep(3,n)
  if(group.number==1){
    pos[1] <- 2
    pos[2] <- 1
    pos[3] <- 2
    pos[4] <- 2
  }
  else{
    pos[1] <- 3
  }
  for(i in 1:n){
    panel.text(xjittered[theOnes.indx[i]],
               plotData$y[subscripts][theOnes.indx[i]],
               pos=pos[i],
               cex=.6,
               theOnes[i],
               xpd=NA)
    panel.points(xjittered[theOnes.indx[i]],
                 plotData$y[subscripts][theOnes.indx[i]],
                 pch=16,
                 col="black",
                 cex=.5)
  }
}

library(lattice)
foo <- xyplot(y ~ x,
       data=plotData,
       xlab="Trump 2016 Vote in District (%)",
       ylab="Estimated Ideal Point",
       main="115th U.S. House of Representatives",
       group=party,
       panel=panel.superpose,
       panel.group=function(x,y,group.number,subscripts,...){
         xjittered <- jitter(x,amount=.5)
         if(group.number==1){
           panel.grid(v=0,
                      h=-1,col=gray(.92))
           panel.abline(v=seq(10,90,by=10),col=gray(.92))
           panel.xyplot(xjittered,y,col.symbol="blue")
           watermark()
         }
         else{
           panel.xyplot(xjittered,y,col.symbol="red")
         }
         panel.loess(x,y,col.line="black",lwd=3)
         idResid(group.number,subscripts,xjittered)
       },
       scales=list(alternating=3,x=list(at=seq(10,90,by=10))),
       key=list(columns=1,
         x=.15,
         y=.88,
         corner=c(.5,1),
         points=list(pch=c(1,1)),
         text=list(rev(c("Democrats","Republicans")),
           col="black"),
         type="p",
         col=rev(c("blue","red"))
         )
       )

pdf(file="TrumpVote.pdf")
print(foo)
dev.off()

