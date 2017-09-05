################################
## read house data from Jeff
##
## simon jackman
## feb 2017
################################
theURL <- "http://128.97.229.160/static/data/ord/house_115.ord"

library(pscl)
rc <- readKH(file=url(theURL))
rc0 <- dropRollCall(rc,dropList = list(lop=0,legisMin=5))

save("rc","rc0",
     file="../data/rc.rda")

## start values
x0 <- as.numeric(rc0$legis.data$party=="R") - as.numeric(rc0$legis.data$party=="D")

M <- 250E3
id1 <- ideal(rc,
             dropList = list(lop=0,legisMin=5),
             d = 1,
             maxiter = M,
             thin=M/5E3,
             burnin = 5E4,
             startvals=list(xstart=matrix(x0,ncol=1)),
             normalize = TRUE,
             verbose=TRUE)

save("id1",
     file="../data/id1.rda")

s <- summary(id1)
xbar <- cbind(s$xm,s$xHDR[,,1])
save("xbar",
     file="../data/xbar.rda")
