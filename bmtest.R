# Rick Dales' bmtest (bimodality) 
require(e1071)  
# threshold is .555 (greater is probably bimodal)
bmtest <- function (x) {
  # m3 = skew 
  # m4 = kurt 
  # n = data size 
  m3 = skewness(x)
  m4 = kurtosis(x)
  n = length(x)
  b=(m3^2+1) / (m4 + 3 * ( (n-1)^2 / ((n-2)*(n-3)) ))
  return(b)
}