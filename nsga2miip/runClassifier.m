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
function [obj]=runClassifier(population, classifier,Datain,infold)
   % Get the K-fold cross validation result to evaluate the performance of the
   % poplulation 
   %
   % Input: classifier - a machine learning classifier
   %         Datain - the training set
   %         population - the M by N binary encoded population denoting feature
   %                       subsets
   %         infold - the number of folds
   % Output: obj - M by [the number of objectives]
   
    Data=weka.core.Instances(Datain);
    popsize=size(population,1);
    numInstan=zeros(infold,1);
    %fullFeature = Data.numAttributes()-1;%%
    sma=Data.numClasses();
    sensi_speciy=zeros(infold,sma);
    Avg_sensi=zeros(popsize,sma);
    FeatureNum=zeros(popsize,1);
    %maxQC = zeros(popsize,1); %%
    %meanQC = zeros(popsize,1);
    cAcc=zeros(infold,1);
    Avg_Acc=zeros(popsize,1);
    Data.stratify(infold);
 
    for p=1:popsize   
        if sum(population(p,:))~=0
            DataS=FeatureSelect(Data,population(p,:));
            for k=1:infold
                TrainDataS=DataS.trainCV(infold,k-1);
                TestDataS=DataS.testCV(infold,k-1);
                numInstan(k)=TestDataS.numInstances();
                [~,cAcc(k),matrix]=trainclassify(classifier,TrainDataS,TestDataS);             
                           
                for i=1:sma
                   sensi_speciy(k,i)= matrix(i,i)/sum(matrix(i,:));
                end
                
            end
            Avg_sensi(p,:)=sum(sensi_speciy.*repmat((numInstan),1,sma))/sum(numInstan);
            Avg_Acc(p)=sum(cAcc.*numInstan)/sum(numInstan);
            FeatureNum(p)=sum(population(p,:));
           
        else
            Avg_Acc(p)=0;
            Avg_sensi(p,:)=zeros(1,sma);
            
            FeatureNum(p) = 1000;
           
        end
    end
   %obj=[1-Avg_Acc,FeatureNum];
    %Avg_sensi
  % obj=[1-Avg_sensi,FeatureNum];
   
   %type II
  % obj=[1-Avg_sensi(:,1),1-Avg_Acc,FeatureNum];
  
  %gmean
  %obj=[1-((Avg_sensi(:,1).*Avg_sensi(:,2)).^0.5),FeatureNum, meanQC];
  obj=amendobj([1- get_gm(Avg_sensi, sma),FeatureNum]);
  %obj=[1-((Avg_sensi(:,1).*Avg_sensi(:,2)).^0.5),InterQC];
  %obj=[1-((Avg_sensi(:,1).*Avg_sensi(:,2)).^0.5),meanQC];
  
end
function gm_value = get_gm(Avg_sensi, num_c)
gm_value = prod(Avg_sensi, 2).^(1 / num_c);
end
function obj = amendobj(obj)
idx = obj(:, 1) == 1;
obj(idx, :) = inf;
end 