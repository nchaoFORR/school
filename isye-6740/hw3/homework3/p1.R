library(gplots)
library(tidyverse)

### Read in data
poli <- read_csv('n90pol.csv')
X <- as.matrix(poli[, 1:2])
Y <- poli$orientation

### 2-D Histogram Histogram
hist2d(X, nbins = c(15, 15), same.scale = TRUE)

### Kernel Density Estimation (using ggplot's implementation)
### NOTE: ggplot's geom_density2d uses the kde2d() function
###       from the MASS package, which by default uses a gaussian kernel.
poli %>% 
  ggplot() +
  geom_density2d(aes(amygdala, acc), h = 0.04)

### Plot conditional distribution of both amygdala and anterior cingulate
### cortex volumes, as a function of political orientation:
poli %>% 
  gather(region, volume, -orientation) %>% 
  ggplot() +
  geom_density(aes(volume), bw = 0.01) +
  facet_grid(orientation ~ region)
