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

function [stIndis, stObjs, stFrontCds] = nonDomiSortIter(uniIndis, ...
       uniObjs, redunIndis, redunObjs, numDomied, setDomi, popNum)
%  Input: uniIndis - uniN*F matrix, the unique solutions
%         uniObjs -  uniN*M matrix, the objective fucntion values of
%                     unique solutions
%         redunIndis - redunN*F matrix, the redundant solutions
%         redunObjs - redunN*M matrix, the objective fucntion values of
%                     redundant solutions
%         numDomied - uniN * 1 matrix, the number of solutions dominates 
%                     each solution, the first front is set as 0
%         setDomi - uniN * 1 cell, each element contains the indexes of 
%                    soluitons that are dominated by this solution
%         popNum - the number of solutions kept
%
% Output : stIndis - popNum*F matrix, the sorted solutions
%          stObjs - popNum*M matrix, the objective fucntion values
%          stFrontCDs - the front level and crowding distance information


% get the first nondominated front

numIndis = size(uniIndis, 1);
frontCds = zeros(numIndis, 2);
frontCds(:, 1) = inf;

F{1} = find(numDomied' == 0);
numDomied(F{1})  = -1;
frontCds(F{1}, 1) = 1;

% record the number of solutions assigned the front levels
numFs = numel(F{1});
% obtain the front levels for the rest solutions
i = 1;
minSol = min(popNum, numIndis);
while numFs < minSol
    Q = [];   
    for p = F{i}
        numDomied(setDomi{p}, 1) = numDomied(setDomi{p}, 1) -1;
    end
    Q = [Q, find(numDomied' == 0)];
    numDomied(Q)  = -1;
    i = i + 1;
    F{i} = Q;
    frontCds(F{i}, 1) = i;
    numFs = numFs + numel(F{i});    
end
numFronts = numel(F);  

% calculate the crowding distance of the solutions in each front
numObjs = size(uniObjs, 2);
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
        
        frontCds(sorted_f_ins(1), 2) = inf;
        frontCds(sorted_f_ins(end), 2) = inf;
        if num_f_inds > 2
            for j = 2 : num_f_inds - 1                
                frontCds(sorted_f_ins(j), 2) = ...
                    frontCds(sorted_f_ins(j), 2) + ...
                    abs(sorted_f_obj(j - 1) - sorted_f_obj(j + 1)) / norm_max_min;                
            end
        end
   end
end

% update the front level and crowding distance information for redundant
% solutions
if numFs < popNum
    numRed = size(redunIndis, 1);    
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
    uniIndis = [uniIndis; redunIndis];
    uniObjs  = [uniObjs; redunObjs];
    frontCds = [frontCds; redunFrontCds];
end

% sort the solutions according to the front levels and crowding distances
[stFrontCds, inds] = sortrows(frontCds,[1 2],{'ascend' 'descend'});
 stFrontCds = stFrontCds(1 : popNum, :);
 stIndis = uniIndis(inds(1 : popNum), :); 
 stObjs = uniObjs(inds(1 : popNum), :);



end

