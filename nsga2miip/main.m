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

%% An example to run the NSGAII-MIIP algorithm

clc;
%clear all;
close;
% Add weka path
javaaddpath('..\lib\Weka-3-7\weka.jar');

       
%% parameters for the classifier
classifier=weka.classifiers.bayes.NaiveBayes();
classifier.setUseKernelEstimator(0);  % 1 for density estimation, need more time  


%% read and normalize data
filename = 'LSVT';
seed=19;        
datapath=['..\data\',filename,'.arff'];
data=readArffData(datapath);
data=dataNorm(data); 
fprintf('attribute num is %d\nnum of instances is %d\n',data.numAttributes()-1,data.numInstances());
numAttri=data.numAttributes()-1;
% randomize and stratify data
data.randomize(java.util.Random(seed));
% set percentage of test set
percent_test = 3;
whole_num = 10;

%% parameters for NSGAII-MIIP
setup.stopNum = 10000;
setup.popNum = 100;
setup.cRate = 0.9;
setup.mRate = 1/numAttri;
 %


%% set run setting 
reptimes = 1; % repeat times
segnum = reptimes; 
randseed = 30; % run seed


Start=tic;
Startcpu=cputime;

for segfold=0:reptimes-1 
RandStream.setGlobalStream(RandStream('mt19937ar','seed',randseed + segfold));
disp(['Running fold ',num2str(segfold)]);

% divide data into training and test set
[trainset, testset] = divdata(data, percent_test, whole_num);


Startin=tic;
Startincpu=cputime;


%% run  feature selection method
% bind the wrapper-based evaluation function to costFunc
infold = 5; % 5 fold cross validation
costFunc = @(pop) runClassifier(pop, classifier, trainset, infold); 

% run the NSGAII-MIIP algorithm
[Solution, Trainfunc, iter_result]= NSGAIIMIIP(costFunc, trainset, setup);



Timein=toc(Startin);
Timeincpu=cputime-Startincpu;

%% get the prediction accuracy for each solution in the final solution set
numsolution=size(Solution,1);
Conf_matrix=cell(numsolution,1);
pAcc=zeros(numsolution,1);
Sensitivity=zeros(numsolution,1);
Specificity=zeros(numsolution,1);
f1=zeros(numsolution,1);
for i=1:numsolution   
    trainsetr=FeatureSelect(trainset,Solution(i,:));
    testsetr=FeatureSelect(testset,Solution(i,:));
    [~,pAcc(i),Conf_matrix{i,1}]=trainclassify(classifier,trainsetr,testsetr);
     Sensitivity(i)=Conf_matrix{i,1}(1,1)/sum(Conf_matrix{i,1}(1,:));
    Specificity(i)=Conf_matrix{i,1}(2,2)/sum(Conf_matrix{i,1}(2,:));
    preci = Conf_matrix{i,1}(1,1)/sum(Conf_matrix{i,1}(:, 1));
    if (preci + Sensitivity(i)) ==0 || isnan(preci)
        f1(i) = 0;
    else
        f1(i) = ( 2* preci * Sensitivity(i))/ (preci + Sensitivity(i));        
    end
  % train_meanQC(i) = mean(find(Solution(i, :) == 1));   
end
%Trainfunc = [Trainfunc, train_meanQC];
Performance=[Sensitivity,Specificity,pAcc, f1];

% run ideal point method
Perfectpoint=perfectpoint(Solution,Trainfunc,Performance,[1 1]);




%% output the final result

disp(['time in fold ',num2str(segfold),' is ',num2str(Timein)]);
%%
 eval(['ARe',num2str(segfold),'.Solution=Solution;']);
 eval(['ARe',num2str(segfold),'.Performance=Performance;']);
 eval(['ARe',num2str(segfold),'.Trainfunc=Trainfunc;']);
 eval(['ARe',num2str(segfold),'.Conf_matrix=Conf_matrix;']);
 eval(['ARe',num2str(segfold),'.Perfectpoint=Perfectpoint;']);
% eval(['ARe',num2str(segfold),'.Perfectpoint2=Perfectpoint2;']);
 eval(['ARe',num2str(segfold),'.Timecost=Timein;']);
 eval(['ARe',num2str(segfold),'.Timecostcpu=Timeincpu;']); 
 eval(['ARe',num2str(segfold),'.iter_result=iter_result;']);
 eval(['ARe',num2str(segfold),'.runseed=randseed;']);

 save (['TEMP',filename,'.',num2str(segfold),'.mat'],['ARe',num2str(segfold)]);

end

%% summarize
ASum.Performance=zeros(segnum,4);
ASum.Num=zeros(segnum,1);
for i=0:segnum - 1
    
    eval(['ASum.Performance(i+1,:)=mean(ARe',num2str(i),'.Perfectpoint.Performance,1);']);
    eval(['ASum.Num(i+1)=mean(sum(ARe',num2str(i),'.Perfectpoint.Solution,2));']);
    
      
end
ASum.MPerformance=mean(ASum.Performance);
ASum.SPerformance=std(ASum.Performance);
ASum.MNum=mean(ASum.Num);
ASum.SNum=std(ASum.Num);

%%
Timeall=toc(Start);
Timeallcpu=cputime-Startcpu;
disp(['time in  all ',num2str(segnum),' folds is ',num2str(Timeall)]);


save ([filename,'.mat']);
path = dir(['TEMP*.mat']);
for i = 1: length(path)
   delete(path(i).name); 
end

        