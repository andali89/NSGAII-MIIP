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

function offIndis = binTour(indis, frontCds, cRate)
% perform the binary tournament selection and crossover operation

% Input: indis - N*F matrix, individuals
%        frontCds - N*2 matrix, the front leval and crowding distance
%        cRate - 1*1 value, the crossover rate
% Output: offIndis - N*F matrix, the offspring individuals



[numPop, numFeatures] = size(indis); 
% randomly sort the index of individuals
inds = [randperm(numPop), randperm(numPop)];

% get the parent indexes
parInds = zeros(1, numPop);
for i = 1 : 2 : 2 * numPop
    c = inds([i,  i + 1]);    
    [~, ic] = sortrows(frontCds(c, :), [1 2], {'ascend' 'descend'});
    parInds((i + 1)/2 ) = c(ic(1));    
end

% perform the crossover operation for each individual
offIndis = indis(parInds, :);
for i = 1 : 2 : numPop
   j = i + 1;
   if rand() < cRate
       cInds = find(offIndis(i, :) ~= offIndis(j, :));
       numCInds = numel(cInds);
       if numCInds > 1
           cPoint = cInds(randi([2, numCInds]));
           offIndis(i, cPoint: end) = indis(parInds(j), cPoint: numFeatures);
           offIndis(j, cPoint: end) = indis(parInds(i), cPoint: numFeatures);
       end
   end
end

end

