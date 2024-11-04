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

function pop =oblInitialization(popNum,dim)
% a initialization algorithm based on opposition-based learning

% pop = zeros(popNum, dim);
% 
% indis_first = rand(2, dim);
% indis_first(indis_first > 0.5) = 1;
% indis_first(indis_first <= 0.5)  = 0;
% pop(1 : 2, :) = indis_first;
% 
% for i = 3 : popNum
%    a = pop(i - 1, :);
%    b = pop(randi(i - 2), :);
%    ind = rand(1, dim) < 0.5;
%    
%    % uniform cossover,a learning from b
%    a(ind) = b(ind);
%    
%    % opposition-based learning 
%    c = ~a;
%    pop(i, :) = c;    
% end
popNum = popNum / 2;
pop_real = rand(popNum , dim);
popA = zeros(popNum, dim);
popB = popA;
popA(pop_real > 0.5) = 1;
popB(pop_real <= 0.5) = 1;

pop = [popA; popB];

end