library(tidyverse)

vec1 <- c(-1, 2)
vec2 <- c(-1, 1)
vec3 <- c(-1, 0)
vec4 <- c(-1, -1)
vec5 <- c(-1, -2)
vec6 <- c(0, 0)
vec7 <- c(1, 0)
vec8 <- c(2, 0)


weight <- function(a, b) exp(-sqrt(sum((a - b)**2)))

weight(vec7, vec8)

data = list(vec1, vec2, vec3, vec4, vec5, vec6, vec7, vec8)

A <- matrix(c(0, weight(vec1, vec2), weight(vec1, vec3), 0, 0, 0, 0, 0,
              weight(vec1, vec2), 0, weight(vec2, vec3), 0, 0, weight(vec2, vec6), 0, 0,
              weight(vec1, vec3), weight(vec3, vec2), 0, weight(vec3, vec4), weight(vec3, vec5), weight(vec3, vec6), 0, 0,
              0, 0, weight(vec4, vec3), 0, weight(vec4, vec5), weight(vec4, vec6), 0, 0,
              0, 0, weight(vec5, vec3), weight(vec5, vec4), 0, 0, 0, 0,
              0, weight(vec6, vec2), weight(vec6, vec3), weight(vec6, vec4), 0, 0, weight(vec6, vec7), weight(vec6, vec8),
              0, 0, 0, 0, 0, weight(vec7, vec6), 0, weight(vec7, vec8),
              0, 0, 0, 0, 0, weight(vec8, vec6), weight(vec8, vec7), 0),
            8, 8, byrow = TRUE)

D <- diag(rowSums(A))



