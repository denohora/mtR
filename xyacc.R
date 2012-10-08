xy.acc <- function (x,y,t) {
  # calculates acc from each x,y point to the next
  # outputs matrix - acc at each interval [1,] and mean time of each interval [2,]- 2 fewer cols than original times series
  # might want to test whether length(x) = length(y) = length(t) before starting
  dx = abs(x[2:length(x)]-x[1:length(x)-1])
  dy = abs(y[2:length(y)]-y[1:length(y)-1])
  dt = t[2:length(t)]-t[1:length(t)-1]
  
  speed = sqrt(((dx/dt)^2)+((dy/dt)^2))
  t2 = (t[2:length(t)]+t[1:length(t)-1])/2

  dspeed = (speed[2:length(speed)]-speed[1:length(speed)-1])
  dt2 = t2[2:length(t2)]-t2[1:length(t2)-1]

  acc = dspeed/dt2
  t3 = (t2[2:length(t2)]+t2[1:length(t2)-1])/2

  return(rbind(acc,t3))
}

# testing
# needs alltraj from import-moall.R
# t = alltraj[alltraj[,1]==1 & alltraj[,2]==4914,4]
# x = alltraj[alltraj[,1]==1 & alltraj[,2]==4914,5]
# y = alltraj[alltraj[,1]==1 & alltraj[,2]==4914,6]
# length(t) == length(x) 
# length(t) == length(y)
# 
# test3 = xy.acc(x,y,t)
# 
# plot(test3[2,],test3[1,], type = "l")
