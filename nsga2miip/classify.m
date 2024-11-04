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

function [predictedclass,rate,conf_matrix,possi_act, prob_allcls]=classify(classifier,testData,tol)
        num_c=testData.numClasses();
        class_set=zeros(num_c,1);
        testnum=testData.numInstances();
        classProbs=zeros(testnum,testData.numClasses());
        actual = testData.attributeToDoubleArray(testData.classIndex());
    
        for t=0:testnum -1  
            classProbs(t+1,:) = classifier.distributionForInstance(testData.instance(t))';
        end
        if nargin <=2
         [~,predictedclass] = max(classProbs,[],2);
         predictedclass=predictedclass-1;
        else
            predictedclass =ones(testnum,1);
             predictedclass(classProbs(:,1) >= tol,1) = 0;                       
        end
        
       
        rate = sum(actual == predictedclass)/testnum; 
        
        if nargout >=3
            act_pre=[actual,predictedclass];
            conf_matrix=zeros(num_c,num_c);
            for i=1:num_c
                ins_now=act_pre(act_pre(:,1)==i-1,:);
                for j=1:num_c
                conf_matrix(i,j)=sum(ins_now(:,2)==j-1);    
                end
            end
            if nargout >=4
                possi_act = [classProbs(:,1),actual]; 
            end
            if nargout >=5
                prob_allcls = classProbs;
            end
        end
        

      
                     
end