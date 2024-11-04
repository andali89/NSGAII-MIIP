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

function [solution,trainfunc, iter_result]= NSGAIIMIIP(costFunc,trainset,setup)
% the main procedure of NSGAII-MIIP
% Input: costFunc - the objective function to evaluate a solution. The format of this function is 
%                   objs = costFunc(indis) where indis is the input solution and objs is the objective
%                   function values. 
%        trainset - the input training set (weka format)
%        setup    - a struct of the parameter setting of NSGAII-MIIP
%                   setup.popNum - the population size
%                   setup.cRate - crossover rate, range (0,1)
%                   setup.mRate - muation rate, range(0,1), should be a small value
%                   setup.stopNum - number of objective function values to stop the algorithm
%
% Output: solution - M*N matrix, where M is the number of nondominated solutions, N is the number
%                    of original features. Every element in a solution is 1 or 0, 1 denotes the feature
%                    is selected, 0 denotes it is not selected.
%         trainfunc- M*N_obj matrix, where M is the number of nondomianted solutions, N_obj is the number
%                    of objective functions.
%         iter_results - iterNum * 2 cell array, where iterNum is the number of iterations. Recording the 
%                        objective function values during the iterations. 
%                           The first column in the cell ararry records the iteration number and 
%                           number of function evaluations of each iteration.
%                           The second collumn in the cell array records the objective function values 
%                           of nondomianted solutoins during each iteration.
                        

numFeatures = trainset.numAttributes() - 1;
K = round(numFeatures^ 0.5);

% get the cluster result based on the kmeans++ algorithm

% K
[clustersInds, nMImatrix, entropy] = clusterFeature(trainset, K);

% clustersInds


%% get paparemters
popNum = setup.popNum;
cRate = setup.cRate;
mRate = setup.mRate;
stopNum = setup.stopNum;

% initialize population with popNum individuals 
pop.indis=oblInitialization(popNum, numFeatures);
% pop.indis = iniIndividuals(popNum, numFeatures, clustersInds, nMImatrix);
pop.objs =  costFunc(pop.indis);   
evalNums = popNum;
% nondominated sorting
[pop.indis, pop.objs, pop.frontCds] = nonDomiSort(pop.indis, pop.objs);
F1_obj = pop.objs(pop.frontCds(:, 1) == 1, :); 
iter_result = [[0, evalNums],{unique(F1_obj,'rows')}];
iter = 0;
while evalNums < stopNum
    iter = iter + 1;
    fprintf('Iteration %d\r\n', iter);
    % binary tournament selection and crossover    
    offPop.indis = binTour(pop.indis, pop.frontCds, cRate);
    
    % mutation 
    offPop.indis = mutation(offPop.indis, mRate);
    
    % evaluate the objective functions of the offspring population
    offPop.objs = costFunc(offPop.indis); 
    evalNums = evalNums + popNum;
    
%    [pop.indis, pop.objs, pop.frontCds] = ...
%        nonDomiSort([pop.indis; offPop.indis], [pop.objs; offPop.objs]);
%       [pop.indis, pop.objs, pop.frontCds] = ...
%         nonDomiSortTest([pop.indis; offPop.indis], [pop.objs; offPop.objs]);
%     pop.indis = pop.indis(1: popNum, :);
%     pop.objs = pop.objs(1: popNum, :);
%     pop.frontCds = pop.frontCds(1: popNum, :)

    % get the nondominated set from the offspring population
    [uniIndis, uniObjs, redunIndis, redunObjs, numDomied, setDomi, F] = ...
           getFirstFront([pop.indis; offPop.indis], [pop.objs; offPop.objs]);
    nonSetIndis = uniIndis(F{1}, :);
    
    % update the nondominated set by local search
    [lo.indis] = improvement(nonSetIndis, nMImatrix, clustersInds, entropy);
    lo.objs = costFunc(lo.indis);
    evalNums = evalNums + size(lo.objs, 1);
    
    % update the numDomied and setDomi information
    [uniIndis, uniObjs, redunIndis2, redunObjs2, numDomied, setDomi]= ... 
        upNonSortInfo(uniIndis, uniObjs, lo.indis, lo.objs, numDomied, setDomi); 

   
    
    % get the solutions for the next iteration based on the nondomianted
    % sorting and crowding distance approaches
    redunIndis = [redunIndis; redunIndis2];
    redunObjs = [redunObjs; redunObjs2];
    [pop.indis, pop.objs, pop.frontCds] = nonDomiSortIter(uniIndis, ...
        uniObjs, redunIndis, redunObjs, numDomied, setDomi, popNum);
    
    F1_obj = pop.objs(pop.frontCds(:, 1) == 1, :);    
    iter_result = [iter_result;[[iter, evalNums],{unique(F1_obj,'rows')}]];
    
end
fInd = pop.frontCds(:, 1) == 1;
solution = pop.indis(fInd, :);
trainfunc = pop.objs(fInd, :);


end

