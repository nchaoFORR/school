### Create datapoints
vec1 <- c(-1, 2)
vec2 <- c(-1, 1)
vec3 <- c(-1, 0)
vec4 <- c(-1, -1)
vec5 <- c(-1, -2)
vec6 <- c(0, 0)
vec7 <- c(1, 0)
vec8 <- c(2, 0)

### Create edge weight function
weight <- function(a, b) exp(-sqrt(sum((a - b)**2)))


### Create adjancency matrix using edge-weight function
A <- matrix(c(0, weight(vec1, vec2), weight(vec1, vec3), 0, 0, 0, 0, 0,
              weight(vec2, vec1), 0, weight(vec2, vec3), 0, 0, 0, 0, 0,
              weight(vec3, vec1), weight(vec3, vec2), 0, weight(vec3, vec4), weight(vec3, vec5), weight(vec3, vec6), 0, 0,
              0, 0, weight(vec4, vec3), 0, weight(vec4, vec5), 0, 0, 0,
              0, 0, weight(vec5, vec3), weight(vec5, vec4), 0, 0, 0, 0,
              0, 0, weight(vec6, vec3), 0, 0, 0, weight(vec6, vec7), weight(vec6, vec8),
              0, 0, 0, 0, 0, weight(vec7, vec6), 0, weight(vec7, vec8),
              0, 0, 0, 0, 0, weight(vec8, vec6), weight(vec8, vec7), 0),
            8, 8, byrow = TRUE)

### Create Degree Matrix
D <- diag(rowSums(A))


### Calculate Laplacian
L <- D - A


### Calculate eigen decomposition
eig_decomp <- eigen(L)

### Look for eigen-gap
plot(1:8, rev(eig_decomp$values))

### Try ttwo smallest non-zero eigenvals
k_eig <- eig_decomp$vectors[, 6:7]

### Run k-means with k = 4
kmeans(k_eig, centers = 4)

