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

function [predictedClass,rate,conf_matrix, possi_act, prob_allcls]=...
    trainclassify(bayes,trainset,testset)
    %disp('normal for ADPN etc. used')
     bayes.buildClassifier(trainset);
             %test naive bayes
     if nargout==2
        [predictedClass,rate]=classify(bayes,testset);
     elseif nargout==3
        [predictedClass,rate,conf_matrix]=classify(bayes,testset);
     elseif nargout==5
        [predictedClass,rate,conf_matrix, possi_act, prob_allcls]=...
             classify(bayes,testset);
     end
end