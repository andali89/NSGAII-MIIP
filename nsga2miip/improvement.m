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

function [newIndis] = improvement(indis, nMImatrix, clustersInds, entropy)
% Perform the local search based on the normalized mutual information (NMI)
% of each cluster. For each solution (individual), a cluster is selected, 
% and a feature in this cluster is changed to another one that most probabily 
% increases the effectivness of this cluster. The selection is based on the  
% relevance and redudancy inforamtion calculated by the NMI matrix
% (nMImatrix).

% Input:  indis - N*F matrix, the input N solutions/individuals 
%         clustersInds - cell that contain the index of features in each
%                        cluster
%         nMI matrix - matrix where each element is the normalized mutual
%                     information value of two features (the last column
%                     denotes the mutual information of between the class
%                     label and each feature)
%         entropy - 1*(F+1) vector, containing the entropy of each feature
%                   and the class label
% Output: newIndis - N*F matrix, the new N solutions/individuals from local
%                    search

numClusters = numel(clustersInds);
newIndis = repmat(indis, 3, 1);
iNew = 1;
for option = 1 :3
     % option 1 forward (add), option 2 backward (elinimate), option 3 interchange
    if option == 1
        update = @(indi, nMImatrix,onesInds, zerosInds, entropy)...
            forward(indi, nMImatrix,onesInds, zerosInds, entropy);
    elseif option == 2
        update = @(indi, nMImatrix,onesInds, zerosInds, entropy)...
            backward(indi, nMImatrix,onesInds, zerosInds, entropy);
    else
        update = @(indi, nMImatrix,onesInds, zerosInds, entropy)...
            interchange(indi, nMImatrix,onesInds, zerosInds, entropy);
    end    
    
for sol = 1 : size(indis, 1)
    indi = indis(sol, :);     
    orders = randperm(numClusters);   
    for i = orders
        clInds = clustersInds{i};
        indiCl = indi(clInds);
        onesInds = clInds(indiCl == 1);
        zerosInds = clInds(indiCl == 0);
        % update this individual
        [indiNew, state] = update(indi, nMImatrix,...
            onesInds, zerosInds, entropy);
        if state
            indi = indiNew;
            break;
        end        
    end
    newIndis(iNew, :) = indi;
    iNew = iNew + 1;
end
end


end

% add operation
function [indiNew, state] = forward(indi, nMImatrix, onesInds, zerosInds, entropy)
    state = 0;
    indiNew = indi;    
    numZeros = numel(zerosInds);
    if numZeros == 0       
        return;
    end
    benchInds = onesInds;
    weights = zeros(1, numZeros);
    for i = 1 : numZeros
        weights(i) =  calWeight(nMImatrix, benchInds, zerosInds(i), entropy);
    end
    [~, I] = max(weights);
    indiNew = indi;
    indiNew(zerosInds(I)) = 1;
    state = 1;
end

% eliminate operation
function [indiNew, state] = backward(indi, nMImatrix, onesInds, zerosInds, entropy)
state = 0;
indiNew = indi;
numOnes = numel(onesInds);
if numOnes == 1
    indiNew(onesInds) = 0;
    state = 1;
    return;
elseif numOnes == 0
    return;
end

weightsOne = zeros(1, numOnes);
benchInds = cell(1, numOnes);

for i = 1 : numOnes
    benchInds{i} = onesInds;
    benchInds{i}(i) = [];    
    weightsOne(i) = calWeight(nMImatrix, benchInds{i}, onesInds(i), entropy);
end

[~, I] = min(weightsOne);
indiNew(onesInds(I)) = 0;
state = 1;

end

% interchange operation
function [indiNew, state] = interchange(indi, nMImatrix, onesInds, zerosInds, entropy)

state = 0;
indiNew = indi;
numOnes = numel(onesInds);
numZeros = numel(zerosInds);
if numOnes == 0 || numZeros == 0
  return;
end

% calculate the weight value for each feature in onesInds

weightsOne = zeros(1, numOnes);
benchInds = cell(1, numOnes);

for i = 1 : numOnes
    benchInds{i} = onesInds;
    benchInds{i}(i) = [];    
    weightsOne(i) = calWeight(nMImatrix, benchInds{i}, onesInds(i), entropy);
end

[~, sortInd]= sort(weightsOne, 'ascend');


weightsZero = zeros(1, numZeros);
for selInd = sortInd
    weightCurrent = weightsOne(selInd);
    benchInd = benchInds{selInd};
    % calculate the weight value for each feature in zerosInds with repect
    % to the considered featrue selInd.    
    for i = 1 : numZeros
        weightsZero(i) =  calWeight(nMImatrix, benchInd, zerosInds(i), entropy);
    end
    [M, I] = max(weightsZero);
    
    if M >= weightCurrent
        % update
        cInd = onesInds(selInd);
        nInd = zerosInds(I);
        indiNew = indi;
        indiNew(cInd) = indi(nInd);
        indiNew(nInd) = indi(cInd);
        % successful
        state = 1;
        break;
    end
    
end


end

function weight = calWeight(nMImatrix, benchInd, ind, entropy)
    % relevance
    rele = nMImatrix(ind, end);
    
    % redudancy
    redun = 1;
    if numel(benchInd) >= 1
        redun = 0;
        for i = benchInd'
             redun = redun + ...
                 nMImatrix(i, end) * nMImatrix(i, ind) / entropy(i);
        end
    end
    
    weight = (rele ^ 2) / redun;

end