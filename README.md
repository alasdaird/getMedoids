# getMedoids
Get the central observations of a data set in R
# Alasdair Douglas
# 13/1/15

The function "dissMedoids_Function.R" takes as input:
-Vector of IDs for each observation
-Matrix or Dataframe of numerical data observations (already scaled)
-Vector of supplied labels for each observation
-Logical option useLab (default=FALSE)
  -if TRUE the central observations are found for each group/class of labelled observations
  -if FALSE the groups/classes supplied are ignored and the pam algorithm is used to find 
  clusters and then the central observations are found for those pam clusters

For efficiency, the pam algorithm is used to find a medoid in a cluster. The other members 
of the cluster are then tested for their distance from the medoid. 

A data frame is returned that has the IDs, the scaled data observations, supplied labels, 
pam clustering labels (if useLab=FALSE), and the distance between each observation and the 
medoid for the cluster. Medoids have a distance value of 0.

This function requires the following R packages from CRAN:
cluster
dplyr


Note:
The results of which observations are near each other will vary hugely with the scaling.
Also, scaling blends data between all observations. A sample of the population will have different
scaled values to the whole population. 
Always try to scale the whole population together (but don't include test sets), then subset.
