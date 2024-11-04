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

function [data_mat] = convWekaToMat(data)
%CONVWEKATOMAT Summary of this function goes here
%   Detailed explanation goes here
M = data.numInstances();
N = data.numAttributes();
data_mat = zeros(M, N);

for i = 1 : N
    data_mat(:, i) = data.attributeToDoubleArray(i -1);    
end
end

