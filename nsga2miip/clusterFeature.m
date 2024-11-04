%
% Copyright (c) 2024, An-Da Li 
% Coded by An-Da Li
% Email: andali1989@163.com
%
% This is an implementation of a feature selection algorithm called NSGAII-MIIP. 
% This algorithm is designed for selecting key process features in complex 
% manufacturing processes.
%
%

function [clustersInds, nMImatrix, entropy] = clusterFeature(data, K)
% cluster the features into K clusters with Kmeans++
% Input: trainset - weka intances
%        K - the number of clusters
% Output: clustersInds - cell that contain the index of features in each
%                        cluster
%         nMI matrix - matrix where each element is the normalized mutual
%                     information value of two features (the last column
%                     denotes the mutual information of between the class
%                     label and each feature)
%
% The continuous features are discretized first according to the number of
% classes in the class label.


m_trainInstances = weka.core.Instances(data);
% handle missing data
missHandle = weka.filters.unsupervised.attribute.ReplaceMissingValues();
missHandle.setInputFormat(m_trainInstances);
m_trainInstances = weka.filters.Filter.useFilter(m_trainInstances, missHandle);

% discretize the features
disTransform = weka.filters.unsupervised.attribute.Discretize();
disTransform.getBins()
% disTransform.setBins(m_trainInstances.numClasses());
disTransform.setInputFormat(m_trainInstances);
m_trainInstances = weka.filters.Filter.useFilter(m_trainInstances, disTransform);

% containing class label
num_f = m_trainInstances.numAttributes();
data_mat = convWekaToMat(m_trainInstances);

%calculate the MI matrix 

[MImatrix, entropy] = getEntropyMatrix(data_mat);
dis = MImatrix;
for i = 1 : num_f
    for j = 1 : i
        dis(i, j) = 1 - dis(i, j) / min(entropy(i),entropy(j));
        dis(j, i) = dis(i, j);
    end
end
nMImatrix = MImatrix;

dis = dis(1: num_f -1, 1: num_f -1); 

[~, cluster_sign, ~] = kmedoids(data_mat,K,'col',dis);

clustersInds = cell(1, K);
for i = 1 : K
    clustersInds{i} = find(cluster_sign == i);    
end

clustersInds(cellfun(@isempty,clustersInds))=[];
end




function [MImatrix, entropy] = getEntropyMatrix(data_mat)

 % containing class label
    m_numAttri = size(data_mat, 2);
    
    MImatrix = ones(m_numAttri, m_numAttri);
    entropy = zeros(1, m_numAttri);
    
    
    %cont = weka.core.ContingencyTables()    
 
    
    for i = m_numAttri : -1 : 1       
        X = data_mat(:, i);
        for j = 1 : i
            Y = data_mat(:, j);
            rate = calMuInfo(X,Y); 
            MImatrix(i, j) = rate;
            MImatrix(j, i) = rate;
        end
    end
    
   
    for i = 1 : m_numAttri
        entropy(i) = calEntropy(data_mat(:, i));
    end
   
    
end


function mu_info = calMuInfo(X, Y)
% calculate the mutual information of X and Y

% Entropy H(X)
H_X = calEntropy(X);

% Conditional entropy H(X|Y)
H_XY = calCondEntropy(X, Y);


% I(X,Y) = H(X) - H(X|Y)
mu_info = H_X - H_XY;



end


function [con_entropy] = calCondEntropy(X,Y)
% Calculate the conditional entropy H(X|Y)
% X and Y are discrete variables

y_values = unique(Y);
num_y_values = length(y_values);
num_inst = length(Y);
con_entropy = 0;
for i = 1 : num_y_values
    
    ind = (Y == y_values(i));
    num = sum(ind);
    % probability of class Y = y_i
    p_y = num / num_inst;
    
    % select the X given Y = y_i
    x_sel = X(ind);
    
    % calculate the entropy of X
    entropy = calEntropy(x_sel);
    
    con_entropy = con_entropy + p_y * entropy;

end

end



function [entropy] = calEntropy(vector)
% calculate the entropy of the inpout vector.
% the vector contain the values of  a discrete variable

values = unique(vector);
num_all = length(vector);

num_values = length(values);
log2 = log(2);
nums = zeros(1, num_values);
p = zeros(1, num_values);
entropy = 0;

for i = 1: num_values
    
   nums(i) = sum(vector == values(i));
   p(i) = nums(i) / num_all;  
   
   entropy = entropy - p(i) * log(p(i)) /log2;
end


end
