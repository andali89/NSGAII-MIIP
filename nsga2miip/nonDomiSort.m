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

function [stIndis, stObjs, stFrontCds] = nonDomiSort(indis, objs)

numPop = size(objs, 1);
numObjs = size(objs, 2);
% find the redundant solutions and eliminate them
[uniIndis, ia]= unique(indis, 'rows');
uniObjs = objs(ia, :);
numIndis = size(ia, 1);
redunInds = setdiff(1:numPop, ia);

%test
% uniIndis = indis;
% uniObjs = objs;
% redunInds = [];
% numIndis = size(indis, 1)

% get the first nondominated front
numDomied = zeros(numIndis, 1);
setDomi = cell(numIndis, 1);
frontCds = zeros(numIndis, 2);

for i = 1 : numIndis
    p = uniObjs(i, :);    
    for j = (i + 1) : numIndis
      q =  uniObjs(j, :);
      if dominate(p, q)
          numDomied(j) = numDomied(j) + 1;
          setDomi{i} = [setDomi{i}, j];
      elseif dominate(q, p)
          numDomied(i) = numDomied(i) + 1;
          setDomi{j} = [setDomi{j}, i];
      end      
    end   
end
F{1} = find(numDomied' == 0);
numDomied(F{1})  = -1;
frontCds(F{1}, 1) = 1;

% obtain the front levels for the rest of solutions
i = 1;
while numel(F{i}) > 0
    Q = [];
    s = [];
    for p = F{i}      
       numDomied(setDomi{p}, 1) = numDomied(setDomi{p}, 1) -1;              
    end
    Q = [Q, find(numDomied' == 0)];    
    numDomied(Q)  = -1;
    i = i + 1;
    F{i} = Q;
    frontCds(F{i}, 1) = i;
end
F(i) = [];
numFronts = numel(F);  
% calculate the crowding distance of the solutions in each front
for f = 1 : numFronts    
   f_objs = uniObjs(F{f}, :);
   f_inds = F{f};
   % number of elements in the front
   num_f_inds = numel(f_inds);
   for i = 1 : numObjs
        % sort the ith objective in ascending order
        [sorted_f_obj, ind] = sort(f_objs(:, i));
        sorted_f_ins = f_inds(ind);
        min_obj = sorted_f_obj(1);
        max_obj = sorted_f_obj(end); 
        norm_max_min = max_obj - min_obj;
        for j = 1 : num_f_inds
            if j == 1|| j == num_f_inds
                frontCds(sorted_f_ins(j), 2) = inf;
            else
                frontCds(sorted_f_ins(j), 2) = ...
                frontCds(sorted_f_ins(j), 2) + ...
                abs(sorted_f_obj(j - 1) - sorted_f_obj(j + 1)) / norm_max_min;
            end
        end
   end
end


% get the front information for redundant solutions
numRed = numel(redunInds);
redunObjs = objs(redunInds, :);
redunIndis = indis(redunInds, :);
redunFrontCds = zeros(numRed, 2);
for i = 1 : numRed
    temp_objs = redunObjs(i, :);
    for j = 1 : numIndis
        if isequal(temp_objs, uniObjs(j, :))
            redunFrontCds(i, :) = frontCds(j, :) + [numFronts,0];
        end
    end
end

% combine the unique and redudant solutions
stIndis = [uniIndis; redunIndis];
stObjs  = [uniObjs; redunObjs];
stFrontCds = [frontCds; redunFrontCds];

% sort the solutions accordin to the front levels and crowding distances
[stFrontCds, inds] = sortrows(stFrontCds,[1 2],{'ascend' 'descend'});
stIndis = stIndis(inds, :); 
stObjs = stObjs(inds, :);


end

