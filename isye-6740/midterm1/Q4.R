library(magick)

################################# Part 1; Eigenfaces

### image viewer function
view_image <- function(pixel_matrix) {
  par(mar=rep(0, 4))
  image(pixel_matrix, useRaster=TRUE, axes=FALSE, col = grey(seq(0, 1, length = 256)))
}

### function to preprocess image (taking an image filepath)
###  - reads image, performs downsampling, and returns the vectorized image
image_preprocess <- function(fp) {
  # read image and convert to matrix
  image_mat <-
    image_read(fp) %>% 
    image_flip() %>%
    image_data(channels = 'gray') %>% 
    as.vector() %>% 
    as.numeric() %>% 
    matrix(320, 243)
  
  # downsample
  row_idx <- seq(1, nrow(image_mat))[seq(1, nrow(image_mat))%%4 == 0]
  col_idx <- seq(1, ncol(image_mat))[seq(1, ncol(image_mat))%%4 == 0]
  downsample_mat <- image_mat[row_idx, col_idx]
  
  # return vectorized image
  return(as.vector(downsample_mat))

}

### get vector of all of subjects' respective filepaths (excluding test images)
subject01_fp <- paste0('yalefaces/', dir('yalefaces/')[grepl('01', dir('yalefaces/')) & !grepl('test', dir('yalefaces/'))])
subject14_fp <- paste0('yalefaces/', dir('yalefaces/')[grepl('14', dir('yalefaces/')) & !grepl('test', dir('yalefaces/'))])

### Create face matrices for both subjects
subject01_mat <- matrix(0, 4800, 10)
for(i in 1:length(subject01_fp)) {
  subject01_mat[, i] <- image_preprocess(subject01_fp[i])
}

subject14_mat <- matrix(0, 4800, 10)
for(i in 1:length(subject14_fp)) {
  subject14_mat[, i] <- image_preprocess(subject14_fp[i])
}

### Multiply both by their transpose to make square matrices
subject01_sqmat <- subject01_mat%*%t(subject01_mat)
subject14_sqmat <- subject14_mat%*%t(subject14_mat)

### Perform eigen-decomposition on the swaure face matrices
eigen_01 <- eigen(subject01_sqmat)
eigen_14 <- eigen(subject14_sqmat)

### Grab top 6 eigenfaces for each subject and plot them
matrix(eigen_01$vectors[, 1], 80, 60) %>% view_image()
matrix(eigen_14$vectors[, 1], 80, 60) %>% view_image()

matrix(eigen_01$vectors[, 2], 80, 60) %>% view_image()
matrix(eigen_14$vectors[, 2], 80, 60) %>% view_image()

matrix(eigen_01$vectors[, 3], 80, 60) %>% view_image()
matrix(eigen_14$vectors[, 3], 80, 60) %>% view_image()

matrix(eigen_01$vectors[, 4], 80, 60) %>% view_image()
matrix(eigen_14$vectors[, 4], 80, 60) %>% view_image()

matrix(eigen_01$vectors[, 5], 80, 60) %>% view_image()
matrix(eigen_14$vectors[, 5], 80, 60) %>% view_image()

matrix(eigen_01$vectors[, 6], 80, 60) %>% view_image()
matrix(eigen_14$vectors[, 6], 80, 60) %>% view_image()


####################################### Part 2; Facial Recognition

### Projection function (cosine similarity)
cosine_similarity <- function(vec1, vec2) {
  l2_norm <- function(vec) {
    sqrt(sum(vec**2))
  }
  (vec1 %*% vec2) / (l2_norm(vec1)*l2_norm(vec2))
}

### Grab top eigenfaces for each subject
subject01_topeigen <- eigen_01$vectors[, 1]
subject14_topeigen <- eigen_14$vectors[, 1]

### Get vectors for test images
subject01_test <- image_preprocess('yalefaces/subject01-test.gif')
subject14_test <- image_preprocess('yalefaces/subject14-test.gif')

### Get the four similarity scores
cosine_similarity(subject01_test, subject01_topeigen)
cosine_similarity(subject01_test, subject14_topeigen)
cosine_similarity(subject14_test, subject01_topeigen)
cosine_similarity(subject14_test, subject14_topeigen)

