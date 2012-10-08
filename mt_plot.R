## MouseTracker R Function to plot MT trajectories from mt data frame

# plots x,y trajectory from data frame from mousetracker csv trial info (see mt_import.R)

mt.plot <- function(data, trim = 0, NewPlot = T, ...){
  
  # testing vals
  # data = mfdata # testing
  # trim = 0.2 # testing
  
  # find X_1 in data frame
  x1.col = which (colnames(data)=="X_1")
  y1.col = x1.col + 101
  # calculate mean vals of traj coordinates
  x.mean = sapply(data[,x1.col:(x1.col+100)], mean, trim = trim)
  y.mean = sapply(data[,y1.col:(y1.col+100)], mean, trim = trim)
  # plot mean vals
  if(NewPlot == T) plot(x.mean,y.mean, ...)
  else lines(x.mean,y.mean, ...)
}