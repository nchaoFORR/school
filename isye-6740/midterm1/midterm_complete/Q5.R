library(tidyverse)
library(igraph)

### image viewer function
view_image <- function(pixel_matrix) {
  par(mar=rep(0, 4))
  image(pixel_matrix, useRaster=TRUE, axes=FALSE, col = grey(seq(0, 1, length = 256)))
}

### image matrix function (turns image vectoer to a matrix that can be plotted in view_image())
image_matrix <- function(image_vector) {
  image_mat <- round(t(matrix(image_vector, 64, 64)*256))
  image_mat[, ncol(image_mat):1, drop=FALSE]
}

### Read in data
data_raw <- R.matlab::readMat('P5/isomap.mat')$images

### Look at an example image
image_matrix(data_raw[, 2]) %>% view_image()

### Euclidean distance function
euclidean <- function(vec1, vec2) {
  sqrt(sum((vec1 - vec2)**2))
}

### Create adjacency table with all pair-wise combination
adjacency_table <-
  expand.grid(a = 1:698, b = 1:698) 

### Create vector of all pairwise similarities
distances <- vector('numeric', nrow(adjacency_table))

### Fill in distance column
pairwise_a <- adjacency_table$a
pairwise_b <- adjacency_table$b
for(i in 1:nrow(adjacency_table)) {
  print(i)
  distances[i] <- euclidean(data_raw[, pairwise_a[i]], data_raw[, pairwise_b[i]])
}

### Add similarity column to the adjacency table
adjacency_table$distance <- distances

k <- 100

### Create final adjacency table keeping only k (100) nearest images for each image
adjacency_table_knearest <-
  adjacency_table %>% 
  # First, fill in 99999 for all image similarities with itself (very high euclidean -> very low similarity).
  # No real euclidean distance will exceed that so this essentially invalidates similarities between images with themselves
  mutate(distance = ifelse(a == b, 99999, distance)) %>% 
  # keep k nearest neighbors for each image (k lowest euclidean distances)
  group_by(a) %>% 
  arrange(distance) %>% 
  slice(1:k) %>% 
  ungroup()

### Create Adjacency Matrix
A <- matrix(0, 698, 698)
node_1_vec <- adjacency_table_knearest$a
node_2_vec <- adjacency_table_knearest$b
k_nearest <- adjacency_table_knearest$distance
for(i in 1:nrow(adjacency_table_knearest)) {
  A[node_1_vec[i], node_2_vec[i]] <- k_nearest[i]
}

### Visualize the graph via intensity map of Adjacency Matrix (invert weights in adjacency matrix as they
### are currently the Euclidean distances. Lower distance means more similar)
A_inv <- matrix(0, nrow(A), ncol(A))
max_dist <- max(A)
for(i in 1:nrow(A)) {
  for(j in 1:ncol(A)) {
    if(A[i, j] != 0) A_inv[i, j] <- max_dist - A[i, j]
  }
}

heatmap(A_inv, Rowv = NA, Colv = NA)
heatmap(A_inv)

### Generate igraph object and calculate shortest paths
image_graph <- graph_from_adjacency_matrix(A_inv)
D <- distances(image_graph, weights = NA)

### Create centering matrix C
one_vec <- rep(1, nrow(A))
I <- diag(one_vec)
H <- I - ((1/nrow(A)) * (one_vec%*%t(one_vec)))
C <- (-1/2*nrow(A)) * (H %*% (D**2) %*% H)

### Perform eigen decomposition of C
eigen_C <- eigen(C)

#### Grab leading 2 eigen-vectors which is the 2-dimensional embedding of the graph
isomap_embedding <- eigen_C$vectors[, 1:2]

### Plot
plot(isomap_embedding[, 1], isomap_embedding[, 2])

### Grab 3 points that are close to each other and visualize them