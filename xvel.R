x.vel <- function (x,t) {
  # calculates velocity from each x point to the next along the x plane
  # outputs matrix - vel at each interval [1,] and mean time of each interval [2,]- 1 fewer col than original times series
  # might want to test whether length(x) = length(y) = length(t) before starting
  dx = x[2:length(x)] - x[1:length(x)-1]

  dt = t[2:length(t)]-t[1:length(t)-1]
  
  vel = dx/dt
  
  t2 = (t[2:length(t)]+t[1:length(t)-1])/2
  
  return(rbind(vel,t2))
}