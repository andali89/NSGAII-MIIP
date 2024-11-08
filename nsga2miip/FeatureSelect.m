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

function [DataS]=FeatureSelect(Data,Array)
    remove=weka.filters.unsupervised.attribute.Remove;
    remove.setInvertSelection(1)
    l=Data.classIndex();
    ArrayLength=size(Array,2);
    %index=[];
    index=zeros(1,sum(Array));
    ii=1;
    for i=1:ArrayLength
        if Array(:,i)==1
           % index=[index,i-1];
            index(ii)=i-1;
            ii=ii+1;
        end
    end
    index=[index,l];
    remove.setAttributeIndicesArray(index);
    remove.setInputFormat(Data);
    DataS=weka.filters.Filter.useFilter(Data,remove);
    %testsetr=weka.filters.Filter.useFilter(testset,remove);
    
end