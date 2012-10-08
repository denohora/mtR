# subject =alldata[alldata$Rel.Type == "Magnitude" & alldata$TrialNum>0, ]$Subject
# probe =  alldata[alldata$Rel.Type == "Magnitude" & alldata$TrialNum>0, ]$Probe
# acc = alldata[alldata$Rel.Type == "Magnitude" & alldata$TrialNum>0, ]$Slide1.ACC
dprime <-function(subject,probe,acc) {
 
  # requires following variables (e.g., from a data frame)
  # subject (subject ID) vector, 
  # probe (probe or foil), 
  # acc (accuracy; 1=correct, 0=false)
  # output is sub.dprime matrix of subject ids and corresponding dprime score
  probe=tolower(as.character(probe))
  data = data.frame(acc,probe,subject)
  colnames(data) = c("acc", "probe", "subject")
  # get total probes and foils
  subprobe.total = aggregate(probe=='probe'~subject, data=data,sum )
  subfoil.total = aggregate(probe=='foil'~subject, data=data,sum )
  
  # get acuracy on probes and foils
  subprobe.acc = aggregate(acc~subject+probe, data=data,sum ) 
  
  pH = subprobe.acc[subprobe.acc$probe=='probe',]$acc/subprobe.total[,2] # prob(Hit)
  # replace 1s with p = (N-1)/N.
  pH[pH==1] = (subprobe.total[1,2]-1)/subprobe.total[1,2] # this assumes same number of probes for each subject
  
  pFA = 1-subprobe.acc[subprobe.acc$probe=='foil',]$acc/subfoil.total[,2] # prob(False Alarm)
  # replace 0s with p = 1/N
  pFA[pFA==0] = 1/subfoil.total[1,2] # this assumes same number of foils for each subject
  
  dprime.score <- qnorm(pH) - qnorm(pFA)
  
  sub.dprime= cbind(subprobe.total$subject,dprime.score)
  sub.dprime= data.frame(sub.dprime)
  colnames(sub.dprime)=c('subject','dprime')
  
  return(sub.dprime)
}
