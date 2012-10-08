## MouseTracker import function for R
# imports mousetracker csv trial info into data frame

mt.import <- function(filename, prepVar = F){
  # bring in data from csv file
  import = read.csv(filename, skip=1, stringsAsFactors=FALSE)
  
  # cut off the end of the file
  first.meanrow = as.numeric(row.names(import[import[,1] == "MEAN SUBJECT-BY-SUBJECT DATA",]))
  
  trials.data = data.frame(import[1:first.meanrow-1,])
  trials.data=trials.data[,1:226]
  
  if(prepVar == T){
    for (column in c(2,11:23,25:ncol(trials.data))) trials.data[,column] = as.numeric(trials.data[,column])
    for (column in c(1,3:5)) trials.data[,column] = as.factor(trials.data[,column])
    trials.data$error = as.logical(as.numeric(trials.data$error))
  } # if prepVar
  
  return(trials.data)
} # function
