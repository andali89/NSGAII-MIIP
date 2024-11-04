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

function data=readArffData(x)
read=weka.core.converters.ArffLoader;
read.setFile(java.io.File (x));
data=read.getDataSet();
data.setClassIndex(data.numAttributes()-1);
%data=data2
end