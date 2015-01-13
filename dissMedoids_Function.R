#--------------------------------------------------------------------------
# Get observations closest to centre from dissimilarity matrix
# Alasdair Douglas
# 13/1/15
#--------------------------------------------------------------------------

# Note: results of which observations are near each other will vary hugely with the scaling.
#Also, scaling blends data between all observations. A sample of the population will have different
#scaled values to the whole population. 
#Always try to scale the whole population together (but don't include test sets), then subset.

# given scaled data, return the closest observations to the Medoids 
# option 1: useLab=TRUE: distance to the medoid of each cluster group (given)
# option 2: useLab=FALSE: distance to the natural medoids found (ignores cluster labels given)
dissMedoids <- function(IDs, x.scaled, clusLabs, medPerClus, useLab=FALSE){
  # requires the cluster and dplyr packages
  require(cluster)
  require(dplyr)
  
  # checks
  if(length(IDs) != nrow(x.scaled)){
    print("row labels not same length as data")
  }
  if(length(clusLabs) != nrow(x.scaled)){
    print("cluster labels not same length as data, assuming all one cluster")
    clusLabs <- as.integer(seq.int(1, nrow(x.scaled), by = 1))
  }
  
  # function for retrieving the distance between a medoid and another row
  dist2Med <- function(j){
    return(x.dissMat[medoid, j])
  }
  
  if(useLab == TRUE){
    # option 1: find medoid within each pre-labelled group
    
    # build data frame from input arguments, with new column for distance to medoid
    x <- data.frame(ID=IDs, x.scaled, clusLabs=clusLabs, 
                    dist2Med = rep(NA, times = nrow(x.scaled)))
  
    for(a in 1:length(unique(clusLabs))){
      
      # get observations in the labelled group
      clusRows <- x$clusLabs == unique(clusLabs)[a]
      
      # Generate dissimilarity matrix for the labelled group (ignores other observations)
      # Note: dissimilarity calc is unnafected by the population. It is a simple distance calculation
      #between each observation
      # Result is the lower triangle of the dissimilarity matrix stored as a vector
      #Note: using Euclidean distance metric by default. This will automatically 
      #change to 'Gower's' metric if a variable is categorical
      x.diss <- daisy(x.scaled[clusRows,], stand="FALSE")
      # convert distance lower triangle vector to matrix for simpler indexing
      x.dissMat <- as.matrix(x.diss)
      
      # find natural medoids based on dissimilarity using pam algorithm
      x.pam <- pam(x = x.diss, k = 1, 
                   diss = TRUE, stand = FALSE, 
                   keep.diss = FALSE, keep.data=FALSE)
      
      medoid       <- x.pam$medoids
      dists        <- dist2Med(1:sum(clusRows))
      
      # set results 
      x[clusRows, names(x)=="dist2Med"] <- dists
    }
    
    # get top (medPerClus) observations closest to the medoid, for each labelled group
    x.top <- x %>% 
      group_by(clusLabs) %>% 
      arrange(dist2Med) %>% 
      do(head(.,n = medPerClus))
    
  }else{
    # option 2: find natural medoids for the same number of groups (ignores supplied labels)
    
    # Generate dissimilarity matrix
    # result is the lower triangle of the dissimilarity matrix stored as a vector
    #Note: using Euclidean distance metric by default. This will automatically 
    #change to 'Gower's' metric if a variable is categorical
    x.diss <- daisy(x.scaled, stand="FALSE")
    # convert distance lower triangle vector to matrix for simpler indexing
    x.dissMat <- as.matrix(x.diss)
    
    # find natural medoids based on dissimilarity using pam algorithm
    x.pam <- pam(x = x.diss, k = length(unique(clusLabs)), 
                 diss = TRUE, stand = FALSE, 
                 keep.diss = FALSE, keep.data=FALSE)
    
    
    # build data frame from input arguments, with new column for distance to medoid
    x <- data.frame(ID=IDs, x.scaled, clusLabs=clusLabs, 
                    pamClus = x.pam$clustering, 
                    dist2Med = rep(NA, times = nrow(x.scaled))) 
    
    # for each cluster, get the distance to the cluster medoid for each row
    for(i in 1:length(x.pam$medoids)){
      medoid       <- x.pam$medoids[i]
      clusRows     <- which(x.pam$clustering == i)
      dists        <- dist2Med(clusRows)
      x[clusRows, names(x)=="dist2Med"] <- dists 
    }
    
    # get top (medPerClus) observations closest to the medoid, for each pam cluster
    x.top <- x %>% 
      group_by(pamClus) %>% 
      arrange(dist2Med) %>% 
      do(head(.,n = medPerClus))
  }
  
  return(x.top)
}




