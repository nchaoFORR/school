import numpy as np
import pandas as pd
from sklearn.metrics import jaccard_score


# grab my k-means and euclidean distance functions from Q1
def euclidean(vec1, vec2):
    return np.linalg.norm(vec1-vec2)

### K-means function
def my_kmeans(image_data, K, max_iter = 300):
    
    print('Max Iterations: {}'.format(max_iter))
    
    ### initialize initial assignment
    labels_prev = np.random.randint(0, K, image_data.shape[0])
    centroids = np.array([np.mean(image_data[np.equal(labels_prev, i)], axis=0) for i in range(K)])
    
    
    ### initialize large difference
    difference = 0
    
    ### initialize iteration
    iteration = 1
    
    ### Repeat algorithm until convergence (when jaccard similarity = 1)
    while difference < 1 or iteration == max_iter:
        
        print('Iteration {}'.format(iteration))
        
        # assign each point to the cluster with the nearest centroid
        distances = np.zeros((image_data.shape[0], K))
        for i in range(image_data.shape[0]):
            for j in range(K):
                distances[i, j] = euclidean(centroids[j], image_data[i, :])
                
        # assign each pixel to closer centroid
        labels_new = np.array([np.argmin(centroid) for centroid in distances])
        
        # Calculate new cluster centers
        centroids = np.array([np.mean(image_data[np.equal(labels_new, i)], axis=0) for i in range(K)])
        
        # calculate difference between old cluster centers and new cluster centers
        if K == 2:
            difference = jaccard_score(labels_prev, labels_new)
        else:
            difference = jaccard_score(labels_prev, labels_new, average='macro')
        
        print('Current Jaccard Similarity: {}'.format(difference))
        
        # pass on labels (if we terminate, these will be equal in the end)
        labels_prev = labels_new
        
        # increment iteration
        iteration += 1
        
        if iteration > 5:
            clusters = np.array([image_data[np.where(labels_new == k)] for k in range(K)])
            empty_clusters = np.array([np.linalg.norm(cluster) == 0 for cluster in clusters])
            if np.sum(empty_clusters > 0):
                print('Found empty clusters. Reducing K to {}'.format(K))
                K-=1
                # reinitialize
                labels_prev = np.random.randint(0, K, image_data.shape[0])
                centroids = np.array([np.mean(image_data[np.equal(labels_prev, i)], axis=0) for i in range(K)])
        print(centroids)
    
    
    ### return final labels and centroids
    return labels_new, centroids


### Read in the dataset
raw_nodes = pd.read_csv('homework2_data_code/nodes_fixed.txt', delimiter='\t', header=None)
raw_nodes.columns = ['node', 'name', 'label', 'source']

raw_edges = pd.read_csv('homework2_data_code/edges.txt', delimiter='\t', header=None)
raw_edges.columns = ['node_1', 'node_2']

### Create adjacency and degree matrix, then Laplacian

# adjancency matrix
A = np.zeros((raw_nodes.shape[0], raw_nodes.shape[0]))
for i in range(raw_edges.shape[0]):
    A[raw_edges.node_1.values[i]-1, raw_edges.node_2.values[i]-1] = 1

# degree matrix
# D = np.diag(np.array([np.sum(a) for a in A]))
D = np.zeros((raw_nodes.shape[0], raw_nodes.shape[0]))
for i, j in zip(raw_edges.node_1.values, raw_edges.node_2.values):
    D[i-1, i-1] += 1
    D[j-1, j-1] += 1

# Laplacian
L = D - A

### Calculate eigenvalues and eigenvectors of the laplacian
eigenvals, eigenvecs = np.linalg.eig(L)

# grab m smallest eigenvectors corresponding to non-zero eigenvalues
nonzero_eigenvecs = np.squeeze(eigenvecs[:, np.where(eigenvals > 0)])
nonzero_eigenvals = eigenvals[np.where(eigenvals > 0)]

m = 25

m_smallest_eigenvecs = nonzero_eigenvecs[:, nonzero_eigenvals.argsort()[:m]]


# run k-means with k = 2 on non-zero eigenvalues
labels, centroids = my_kmeans(m_smallest_eigenvecs, K = 2)

### calculate false positive rate
print(np.bincount(labels))
# first determine which cluster is left-leaning and which is right-leaning
nodes_assigned = raw_nodes
nodes_assigned['cluster'] = labels

print(nodes_assigned[nodes_assigned['label'] == 0])
print(nodes_assigned[nodes_assigned['label'] == 1])


# looks like cluster zero is liberals and cluster 1 is conservative
nodes_assigned['correct'] = np.where(nodes_assigned['label'] == nodes_assigned['cluster'], 1, 0)

# get false classification rate
np.mean(nodes_assigned.correct.values)