#--------------------------------------------------------------------------
# Script for using Get observations closest to centre from dissimilarity matrix
# Alasdair Douglas
# 13/1/15
#--------------------------------------------------------------------------

source("dissMedoids_Function.R")

# Note: results of which observations are near each other will vary hugely with the scaling.
#Also, scaling blends data between all observations. A sample of the population will have different
#scaled values to the whole population. 
#Always try to scale the whole population together (but don't include test sets), then subset.

# For useful information on dissimilarity matrix objects:
#http://en.wikibooks.org/wiki/Data_Mining_Algorithms_In_R/Clustering/Dissimilarity_Matrix_Calculation

# using iris data set, separate the numerical columns and scale them.
x       <- iris[,names(iris) %in% c("Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width")]
x.scale <- scale(x, center = TRUE, scale = TRUE)
IDs     <- row.names(iris)
x.Labels<- iris$Species

dissMedoids(IDs, x.scaleSamp, x.Labels, 3, useLab = TRUE)





# Testing -----------------------------------------------------------------
data    <- data.frame(iris)
x       <- data[,names(data) %in% c("Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width")]
x.scale <- scale(x, center = TRUE, scale = TRUE)

#test 1, option 1. Is the result the same with or without the other observations?
#yes
x.samp <- data[1:150,]
IDs     <- as.integer(row.names(x.samp))
x.Labels<- x.samp$Species
x.scaleSamp <- x.scale[IDs, ]

dissMedoids(IDs, x.scaleSamp, x.Labels, 2, useLab = TRUE)


x.samp <- data[51:150,]
IDs     <- as.integer(row.names(x.samp))
x.Labels<- x.samp$Species
x.scaleSamp <- x.scale[IDs, ]

dissMedoids(IDs, x.scaleSamp, x.Labels, 2, useLab = TRUE)

