library(magick)

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
