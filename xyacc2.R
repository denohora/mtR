xy.acc <- function (t,x,y) {
  # calculates velocity from each x,y point to the next towards the end of the trajectory
  # outputs matrix - vel at each interval [1,] and mean time of each interval [2,]- 1 fewer col than original times series
  # might want to test whether length(x) = length(y) = length(t) before starting
  
  # calculate displacement of every point from end of traj - last point will be 0
  sx = x[length(x)] - x[1:length(x)]
  sy = y[length(y)] - y[1:length(y)]
  
  sxy = sqrt( sx^2 + sy^2 )
  
  # get differences in displacement  
  ds = (sxy[2:length(sxy)] - sxy[1:length(sxy)-1] )
  
  dt = t[2:length(t)]-t[1:length(t)-1]
  
  vel = ds/dt
  
  t2 = (t[2:length(t)]+t[1:length(t)-1])/2
  
  dvel = (vel[2:length(vel)]-vel[1:length(vel)-1])
  dt2 = t2[2:length(t2)]-t2[1:length(t2)-1]
  
  acc = dvel/dt2
  t3 = (t2[2:length(t2)]+t2[1:length(t2)-1])/2
  
  return(cbind(t3,acc))
}