# Mousetracker Wide to Long function

mt.widetolong <- function(data, id.vars = c("subject", "trial", "condition"), ...){
  # additional parameters (...) will be sent to melt()
  # testing vals
  # data = mfdata # testing
  
  # find X_1 in data frame
  x1.col = which (colnames(data)=="X_1")
  y1.col = x1.col + 101
  
  # get col indices of id.vars
  id.ix = which(colnames(data) %in% id.vars)
  
  # reshape twice, once for x and once for y
  require(reshape2)
  traj.hold = melt(data[c(id.ix, x1.col:(y1.col+100))],id=(1: length(id.ix)))
  
  traj.hold1 = traj.hold[traj.hold$variable %in% unique(traj.hold$variable)[1:101],]
  traj.hold1$t = as.numeric(traj.hold1$variable)
  # test to check t is ok
  # aggregate(t~variable, data = traj.hold1,mean)
  
  traj.hold2 = traj.hold[traj.hold$variable %in% unique(traj.hold$variable)[102:202],]
  traj.hold2$t = as.numeric(traj.hold2$variable)-101
  # test to check t is ok
  # aggregate(t~variable, data = traj.hold2,mean)
  
  # test whether the order of factors is the same in mean.traj.hold1 and hold2
#   sum(traj.hold1[,1]!=traj.hold2[,1])
#   sum(traj.hold1[,2]!=traj.hold2[,2])
#   sum(traj.hold1[,3]!=traj.hold2[,3])
#   sum(traj.hold1[,6]!=traj.hold2[,6])
#   
  # make new mean.traj data frame
  traj = cbind(traj.hold1[,c(1:(length(id.ix+1)) , ncol(traj.hold1), (ncol(traj.hold1)-1) )], traj.hold2[, (ncol(traj.hold1)-1) ])
  colnames(traj)[ (ncol(traj.hold1)-1) : ncol(traj.hold1) ] = c("x", "y")
  
  return(traj)
}

