# Area Under the Curve function
# http://finzi.psych.upenn.edu/R/Rhelp02a/archive/46416.html
# added first step to order x and y by increasing x

auc <- function(x,y) {
  # order x and y
  ord.x = sort(x)
  ord.y = y[rank(x)]
  
  sum(diff(ord.x)*(ord.y[-1]+ord.y[-length(ord.y)]))/2 
}



