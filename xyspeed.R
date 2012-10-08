xy.speed <- function (x,y,t) {
  # calculates speed from each x,y point to the next
  # outputs matrix - speed at each interval [1,] and mean time of each interval [2,]- 1 fewer col than original times series
  # might want to test whether length(x) = length(y) = length(t) before starting
  dx = abs(x[2:length(x)]-x[1:length(x)-1])
  dy = abs(y[2:length(y)]-y[1:length(y)-1])
  dt = t[2:length(t)]-t[1:length(t)-1]
  
  speed = sqrt(((dx/dt)^2)+((dy/dt)^2))
  t2 = (t[2:length(t)]+t[1:length(t)-1])/2

  return(rbind(speed,t2))
}

# testing
# needs alltraj from import-moall.R
# t = alltraj[alltraj[,1]==1 & alltraj[,2]==4914,4]
# x = alltraj[alltraj[,1]==1 & alltraj[,2]==4914,5]
# y = alltraj[alltraj[,1]==1 & alltraj[,2]==4914,6]
# length(t) == length(x) 
# length(t) == length(y)
# 
# test2 = xy.speed(x,y,t)
# 
# plot(test2[2,],test2[1,], type = "l")