import numpy as np
import pandas as pd

%matplotlib inline
import matplotlib.pyplot as plt

# read in data
raw_data = pd.read_csv('homework2_data_code/food-consumption.csv')

# filter sweden, finland, and spain (they are only rows with nan's)
raw_data = raw_data.dropna()

# separate countries from numeric features

countries = raw_data.Country.values

numeric_features = raw_data.iloc[:, 1:]

### Implement PCA

num_components = 2

# get data mean
mu = np.mean(numeric_features, axis=0)

# get covariance matrix
cov_mat = np.cov(numeric_features, rowvar=False)

# get eigenvals and eigenvecs
eigenvals, eigenvecs = np.linalg.eig(cov_mat)

# sort them
idx = eigenvals.argsort()[::-1]  
eigenvals = eigenvals[idx]
eigenvecs = eigenvecs[:,idx]

# P = vectors.T.dot(C.T)

# center data
centered_mat = (numeric_features - mu).values

# project to principle components
pc = np.dot(eigenvecs[:, :num_components].T, centered_mat.T)


### plot

fig, ax = plt.subplots()
ax.scatter(pc[0, :], pc[1, :])

for i, country in enumerate(countries):
    ax.annotate(country, (pc[0, i], pc[1, i]))