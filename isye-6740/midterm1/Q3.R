data <- matrix(c(4, -2, 4,
                 5, -3, 5,
                 2, 0, 2,
                 3, -1, 3),
               4, 3, byrow = TRUE)

svd_out <- svd(data)
pca_out <- prcomp(data)

