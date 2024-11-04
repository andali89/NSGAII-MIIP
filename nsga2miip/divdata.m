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

function [train_set, test_set] = divdata(data_in, percent_test, whole_num)
    data = weka.core.Instances(data_in);
    data.stratify(whole_num);
    for i = 1 : percent_test
       if i == 1
           test_set = data.testCV(whole_num, i-1);
       else
           test_set.addAll(data.testCV(whole_num, i-1));
       end
    end
    for i = percent_test + 1 : whole_num
       if i == percent_test + 1
          train_set = data.testCV(whole_num, i-1);
       else
          train_set.addAll(data.testCV(whole_num, i-1));
       end
    end
    rnd  = java.util.Random(1);
    train_set.randomize(rnd);
    %train_set.stratify(5);
end