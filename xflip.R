xflip <- function (x, thresh) {
#  Based on Rick Dale's matlab function    
#  function [out] = xflip(x,thresh)  matlab function
#  thresh = threshold of time steps required to call a sequence
#  a change of direction...
  
dx = x[1:length(x)-1]-x[2:length(x)] #  get changes in values
dx = dx[dx!=0] # get rid of 0's in case there was abs(dx)=0 (divided by 0)
dx = dx/(abs(dx)) # get signs (-1 (decreasing), 0 (no change), 1 (increasing)
# %dx = dx(isnan(dx)==0); % get rid of NaNs in case there was abs(dx)=0 (divided by 0)
dx2 = dx[2:length(dx)]-dx[1:length(dx)-1] # subtract changes from point to point

ixes = dx2!=0 # logical array

if(thresh==0) {
  x.flips = sum(dx2!=0)  # get where the -1 turned to 1, 1 turned to -1, etc.
} else { 
  if (sum(dx2!=0)==1)  {
    x.flips = 1 # if there's only one then it changed direction 1ce
  } else {    
      ixes = ixes[2:length(ixes)]-ixes[1:length(ixes)-1] # if potentially more... then let's check how long they moved
      x.flips = sum(ixes>=thresh) # in each direction before switching...
  }
 }

return(x.flips)
}


# # test x and thresh
# x = as.numeric(interp.traj[3,9:109])
# thresh = 1
# 
# xflip(x,0)
# xflip(rawtraj[,2],0 ) # raw trajectory and interped traj have same x flips
# xflip(trialtraj[,2],0 )
# apply(interp.traj[1:10,9:109],1, xflip, thresh=0) # use with apply!!
