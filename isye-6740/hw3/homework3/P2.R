library(mvtnorm)
library(tictoc)

### Read in data
mnist <- t(R.matlab::readMat('data.mat')$data)
labels <- as.vector(R.matlab::readMat('label.mat')$trueLabel)

### Image viewer function
view_image <- function(image_vec) {
  par(mar=rep(0, 4))
  image_mat <- t(apply(matrix(image_vec, 28, 28), 2, rev))
  image(image_mat, useRaster=TRUE, axes=FALSE, col = grey(seq(0, 1, length = 256)))
}


### Visualize a 2 and a 6
view_image(mnist[which(labels == 2)[1], ])
view_image(mnist[which(labels == 6)[1],])



### My GMM E-M algorithm implementation:

### Create a multivariate normal density function (using low-rank approximation of covariance for speed)
d_mvnorm <- function(x, mu, sig, rank = 100) {
  sig_eig <- eigen(sig)
  x_bar <- t(sig_eig$vectors[, 1:rank]) %*% x
  mu_bar <- t(sig_eig$vectors[, 1:rank]) %*% mu
  
  d <- length(x)
  
  1 /  ( sqrt( (2*pi)**rank ) * prod(sig_eig$values) ) * exp( -0.5 * sum((x_bar - mu_bar)**2 / sig_eig$values[1:rank] ) ) 
  
}

K <- 2
X <- mnist

tic()
apply(X[1:100, ], 1, function(x) {d_mvnorm(x, mu = mu_vecs[1, ], sig = sigs[[1]])})
toc()

tic()
dmvnorm(X[1:100, ], mu_vecs[1, ], sigs[[1]])
toc()

### Log-liklihood function
ll <- function(X, mu_vecs, sigs, mix) {
        likes_k1 <- mix[1]*dmvnorm(X, mu_vecs[1, ], sigs[[1]])
        likes_k2 <- mix[2]*dmvnorm(X, mu_vecs[2, ], sigs[[2]])
        sum(log(likes_k1 + likes_k2))
    }

# initizialize mean vectors as gaussians with mean 0
mu_vecs <- rmvnorm(K, mean = rep(0, ncol(X)), sigma = diag(1, ncol(X)))
# initialize covariance matrices as identity matrices
sigs <- lapply(1:K, function(k) diag(1, ncol(X)))
# initialize mixing proportions
mix <- rep(1/K, K)

### evaluate the log-likelihood
cur_ll <- ll(X, mu_vecs, sigs, mix)

