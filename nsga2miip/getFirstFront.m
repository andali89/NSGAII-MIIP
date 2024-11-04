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

function [uniIndis, uniObjs, redunIndis, redunObjs, numDomied, setDomi, F] = ...
                                         getFirstFront(indis, objs)
%  get the information of the first non-dominated front
%
%  Input: indis - N*F matrix, the input solutions
%         objs - N*M matrix, the objective fucntion values
%  Output: uniIndis - uniN*F matrix, the unique solutions
%          uniObjs -  uniN*M matrix, the objective fucntion values of
%                     unique solutions
%          redunIndis - redunN*F matrix, the redundant solutions
%          redunObjs - redunN*M matrix, the objective fucntion values of
%                     redundant solutions
%          numDomied - uniN * 1 matrix, the number of solutions dominates 
%                     each solution, the first front is set as 0
%          setDomi - uniN * 1 cell, each element contains the indexes of 
%                    soluitons that are dominated by this solution



numPop = size(objs, 1);
% find the redundant solutions and eliminate them
[uniIndis, ia]= unique(indis, 'rows');
uniObjs = objs(ia, :);
numIndis = size(ia, 1);
redunInds = setdiff(1:numPop, ia);
redunIndis = indis(redunInds, :);
redunObjs = objs(redunInds, :);

% get the first nondominated front
numDomied = zeros(numIndis, 1);
setDomi = cell(numIndis, 1);


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



end

