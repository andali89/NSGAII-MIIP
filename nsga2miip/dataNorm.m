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

function datao=dataNorm(data,scale,translation)
    if nargin<2       
       scale=2;
       translation=-1;
    end
    normer=weka.filters.unsupervised.attribute.Normalize();
    normer.setOptions({'-S',num2str(scale),'-T',num2str(translation)});
    normer.setInputFormat(data);
    datao=weka.filters.Filter.useFilter(data,normer);
end

