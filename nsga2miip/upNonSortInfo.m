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

function [uniIndis, uniObjs, redunIndis, redunObjs, numDomied, setDomi]= ...
upNonSortInfo(indis, objs, loIndis, loObjs, numDomied, setDomi)    

%  Input: Indis - N*F matrix, the unique solutions
%         Objs -  N*M matrix, the objective fucntion values of
%                     unique solutions
%         loIndis - localN*F matrix, the solutions generated in the local
%                    search
%         loObjs - localN*M matrix, the objective fucntion values of
%                    solutions generated in the local search
%         numDomied - N * 1 matrix, the number of solutions dominates 
%                     each solution, the first front is set as 0
%         setDomi - N * 1 cell, each element contains the indexes of 
%                    soluitons that are dominated by this solution
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

numIndis =  size(indis, 1);


indis = [indis; loIndis];
objs = [objs; loObjs];
numPop = size(indis, 1);

% find the redundant solutions and eliminate them
[uniIndis, ia]= unique(indis, 'rows', 'stable');
uniObjs = objs(ia, :);
numUni = size(ia, 1);
numAppend = numUni - numIndis;

redunInds = setdiff(1:numPop, ia);

redunIndis = indis(redunInds, :);
redunObjs = objs(redunInds, :);

numDomied = [numDomied; zeros(numAppend, 1)];
setDomi = [setDomi; cell(numAppend, 1)];
% update the numDomied, setDomi
for i = numIndis + 1 : numUni
    p =  uniObjs(i, :);
    for j = 1 : i - 1
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

    
    
    
    
    
    
end