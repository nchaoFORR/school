### Create data
data <- matrix(c(4, -2, 4,
                 5, -3, 5,
                 2, 0, 2,
                 3, -1, 3),
               4, 3, byrow = TRUE)

### min-max normalize the data
for(i in 1:ncol(data)) data[, i] <- (data[, i] - min(data[, i])) / (max(data[, i] - min(data[, i])))


### Calculate covariance matrix
covariance <- cov(data)

### Calculate eigen-decomposition
eigen_decomp <- eigen(covariance)

### Grab eigenvector that corresponds to the largest eigenvector to get the first principal direction
eignvec_1 <- eigen_decomp$vectors[, 1]

### Calculate percent of variance by eigenvalue / sum(eigenvalues)
variance_explained <- eigen_decomp$values[1] / sum(eigen_decomp$values)
