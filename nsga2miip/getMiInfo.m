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

function [MImatrix,rankInd] = getMiInfo(data)
%GETMIINFO Summary of this function goes here
%   Detailed explanation goes here
%GETSUINFO Summary of this function goes here
%   Detailed explanation goes here
    m_trainInstances = weka.core.Instances(data);
%     m_classIndex = m_trainInstances.classIndex();
%     m_numInstances = m_trainInstances.numInstances();
%     disTransform = weka.filters.supervised.attribute.Discretize();    
%     disTransform.setUseBetterEncoding(1);
  
    missHandle = weka.filters.unsupervised.attribute.ReplaceMissingValues();
    missHandle.setInputFormat(m_trainInstances);
    m_trainInstances = weka.filters.Filter.useFilter(m_trainInstances, missHandle);
    
%   disTransform = weka.filters.unsupervised.attribute.PKIDiscretize();
    disTransform = weka.filters.unsupervised.attribute.Discretize();
    disTransform.setBins(m_trainInstances.numClasses());
    disTransform.setInputFormat(m_trainInstances);
    m_trainInstances = weka.filters.Filter.useFilter(m_trainInstances, disTransform);
    
    % containing class label
    m_numAttri = m_trainInstances.numAttributes();
    
    MImatrix = ones(m_numAttri, m_numAttri);
    eval = weka.attributeSelection.InfoGainAttributeEval();
    
    for i = m_numAttri -1 : -1 : 0
        m_trainInstances.setClassIndex(i);
        eval.buildEvaluator(m_trainInstances);
    
        for j = 0 : i 
            rate = eval.evaluateAttribute(j); 
            MImatrix(i+1, j+1) = rate;
            MImatrix(j+1, i+1) = rate;
        end
    end
    
   [~, rankInd] = sort(MImatrix(1 : m_numAttri -1, end), 'descend');
    rankInd = rankInd';
end

