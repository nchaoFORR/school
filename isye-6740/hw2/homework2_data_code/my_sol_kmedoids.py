#% Your goal of this assignment is implementing your own K-medoids.
#% Please refer to the instructions carefully, and we encourage you to
#% consult with other resources about this algorithm on the web.
#%
#% Input:
#%     pixels: data set. Each row contains one data point. For image
#%     dataset, it contains 3 columns, each column corresponding to Red,
#%     Green, and Blue component.
#%
#%     K: the number of desired clusters. Too high value of K may result in
#%     empty cluster error. Then, you need to reduce it.
#%
#% Output:
#%     class: the class assignment of each data point in pixels. The
#%     assignment should be 1, 2, 3, etc. For K = 5, for example, each cell
#%     of class should be either 1, 2, 3, 4, or 5. The output should be a
#%     column vector with size(pixels, 1) elements.
#%
#%     centroid: the location of K centroids in your result. With images,
#%     each centroid corresponds to the representative color of each
#%     cluster. The output should be a matrix with K rows and
#%     3 columns. The range of values should be [0, 255].
#%     
#%
#% You may run the following line, then you can see what should be done.
#% For submission, you need to code your own implementation without using
#% the kmeans matlab function directly. That is, you need to comment it out.

from sklearn.metrics import jaccard_score
import numpy as np

### First create a euclidean distance function
def euclidean(vec1, vec2):
    return np.linalg.norm(vec1-vec2)

def my_kmedoids(image_data, K, max_iter = 300):
    print('Running K-Medoids. Max Iterations: {}'.format(max_iter))
    
    ### initialize initial assignment
    labels_prev = np.random.randint(0, K, image_data.shape[0])
    geom_means = np.array([np.mean(image_data[np.equal(labels_prev, i)], axis=0) for i in range(K)])
    
    # find datapoints nearest to each centroid
    centroids = np.zeros((K, 3))
    for k in range(K):
        datapoints = image_data[np.where(labels_prev == k)]
        distances = np.array([euclidean(datapoint, geom_means[k]) for datapoint in image_data])
        centroids[k] = image_data[np.argmin(distances)]
    
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
        # I will select the datapoint that is nearest to the geometric mean
        geom_means = np.array([np.mean(image_data[np.equal(labels_new, i)], axis=0) for i in range(K)])
        
        centroids = np.zeros((K, 3))
        for k in range(K):
            datapoints = image_data[np.where(labels_new == k)]
            distances = np.array([euclidean(datapoint, geom_means[k]) for datapoint in image_data])
            centroids[k] = image_data[np.argmin(distances)]
        
        # calculate difference between old cluster centers and new cluster centers
        if K == 2:
            difference = jaccard_score(labels_prev, labels_new)
        else:
            difference = jaccard_score(labels_prev, labels_new, average='macro')
        
        # print('Current Jaccard Similarity between current labels and previous: {}'.format(difference))
        
        # pass on labels (if we terminate, these will be equal in the end)
        labels_prev = labels_new
        
        # increment iteration
        iteration += 1
        
        ### Check for empty clusters
        if iteration > 5:
            clusters = np.array([image_data[np.where(labels_new == k)] for k in range(K)])
            empty_clusters = np.array([np.linalg.norm(cluster) == 0 for cluster in clusters])
            if np.sum(empty_clusters > 0):
                K-=1
                print('Found empty clusters. Reducing K to {}'.format(K))
                # reinitialize
                labels_prev = np.random.randint(0, K, image_data.shape[0])
                centroids = np.array([np.mean(image_data[np.equal(labels_prev, i)], axis=0) for i in range(K)])
    
    ### return final labels and centroids
    return labels_new, centroids