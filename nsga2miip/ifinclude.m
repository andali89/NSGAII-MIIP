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

function f_set=ifinclude(A,B) 
    L_A=size(A,1);
    f_set=[];
    for i=1:L_A
        if isequal(A(i,:),B)
           f_set=[f_set;i]; 
        end
    end
    disp('function ifinclude used');

end