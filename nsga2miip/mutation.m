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

function offIndis = mutation(indis, mRate)

% Perform the balanced mutation operation
% Input: indis - N*F matrix, the input individuals
%        mRate - the mutation rate for the elements of 1 in the individuals
% Output: offIndis - N*F matrix, the offspring individuals


offIndis = indis;
[numPop, numFeatures] = size(indis); 
mRates = zeros(1, numFeatures);
for i = 1 : numPop   
      % perform the mutation operation
      numOnes = sum(indis(i, :));
      numZeros = numFeatures - numOnes;
      mRateZeroOne =  mRate * numOnes /  numZeros;
      oneIndex = indis(i, :) == 1;
      zeroIndex = ~oneIndex;
      mRates(oneIndex) = mRate;
      mRates(zeroIndex) = mRateZeroOne;
      mIndex = rand(1, numFeatures) < mRates;
      offIndis(i, mIndex) = 1 - indis(i, mIndex);    

end

end


