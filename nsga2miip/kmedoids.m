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

function [set_center, cluster_sign, info] = kmedoids(data,K,type,distype)
% cluster with kmedoids
%   Detailed explanation goes here
% data - input data to calculate distance
% K - number of clusters
% type - 'row' cluster instances, 'col' cluster features 
% distype - 'Euclidean' the Euclidean distance
%           or the distance is obtained directly from distype
if strcmp(type, 'row') 
    data = data';    
end

if nargin == 4 && strcmp(distype, 'Euclidean')
    dis = Euclideandis(data);
else
    % the distance is given in distype
    dis = distype;    
end
num_f =  size(dis, 2);
set_center = zeros(1, K);
set_center(1) = randi(num_f);
% the distance matrix from each point to each medoid
dis2 = zeros(num_f, K);
for i = 1 : K - 1
    dis2(:, i) = dis(:, set_center(i)).^2;
    dis2_min = min(dis2(:, 1 : i), [], 2);
    prob = [0; dis2_min / sum(dis2_min)];
    cum_prob = cumsum(prob);
    
    % select the next (i+1) centroid
    p = rand();
    ind = find(cum_prob < p, 1,'last');    
    set_center(i + 1) = ind;    
end

% iterations of kmeans
% the distance matrix which store the distance of each feature to each medoid
center_dis = dis(:, set_center);
[~, cluster_sign] = min(center_dis, [], 2);
t_set_center = set_center;
while(1)    
    % for each cluster calulate the new medoid
    for i = 1 : K
        findind = find(cluster_sign ==i);
        if ~isempty(findind)          
            t_set_center(i) = getCenter(findind,  dis); 
        end
    end
    % if the medoid do not change, end the Kmeans iterations
    if isequal(t_set_center, set_center)
       break; 
    end
    set_center = t_set_center;
    center_dis = dis(:, set_center);
    [~, cluster_sign] = min(center_dis, [], 2);
end

info.dis = dis;
end

function centerInd = getCenter(ind, dis)
% get the instance with the minimum distance to other instances as the medoid
dis = dis(ind, ind);

% the sum of distances other instances in the same cluster
disToOthers = sum(dis, 2);

[~, minInd] = min(disToOthers);
centerInd = ind(minInd);

end


function center_dis = getMiDis(t_centers, data, entropy)
K = size(t_centers, 2);
num_f =  size(data, 2);

center_dis = zeros(num_f, K); 
% calculate the distance between each center and feature in the data.
for i = 1 : K
   X = t_centers(:, i);
   entropy_X = calEntropy(X);
   for j = 1 : num_f
       Y = data(:, j);       
       mi = calMuInfo(X, Y);
       center_dis(j, i) = 1 - mi / min(entropy(j),entropy_X);
   end    
end


end

function dis = Euclideandis(data_mat)
    m_numAttri = size(data_mat, 2);
    dis = zeros(m_numAttri, m_numAttri);
    
    for i = 1 : m_numAttri
       for j = 1 : i 
            dis(i, j) = norm(data_mat(:, i) - data_mat(:, j));
            dis(j ,i) = dis(i, j);
       end
    end

end



