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

function domire = dominate(x, y)
% Determine if solution x domiante solution y.
% For the multiple objectives, smaller is better.
domire = all(x <= y) && any(x < y);
end