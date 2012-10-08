maxdev <- function (x,y) {
# This is Rick Dale's max dev function translated from matlab
# [maxdeviation] = areaunder3(x, y)
# 
# # find general equation of the straight line
 xchange = x[1]-x[length(x)]
 ychange = y[1]-y[length(y)]
 slope = ychange/xchange
 intercept = y[1] - slope*x[1]

# % find point on the straight line that has the same x as the real point
 points = cbind(x, y)
 points.straightline = cbind(x, slope*x + intercept)
 d = sqrt((points[,1] - points.straightline[,1])^2 + (points[,2] - points.straightline[,2])^2)
 
# % get the corresponding signs for the deviation +/- the x point on the straight
 y.diff = points[, 2] - points.straightline[, 2]
 signs = sign(y.diff)
 
# % find the absolute deviations
# %abs_devs = d;
  abs.devs = d*cos(atan(slope))
# 
# % re-attach sign to maximum deviation
  indx = match(max(abs.devs), abs.devs)
  max.dev = max(abs.devs) * signs[indx]

# return max.dev 
  return(max.dev)
}

# # test x and y
# x = as.numeric(interp.traj[1,9:109])
# y = as.numeric(interp.traj[1,110:210])
# 
# maxdev(x,y)
# maxdev(rawtraj[,2],rawtraj[,3] ) # raw trajectory and interped traj have oposite max ds because
# maxdev(trialtraj[,2],trialtraj[,3] )
