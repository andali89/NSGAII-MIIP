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

function output=perfectpoint(solutions,trainfuncs,performance,w)
% Ideal point method
%
% Input: solutions - M*N matrix, where M is the number of nondominated solutions, N is the number
%                    of original features. Every element in a solution is 1 or 0, 1 denotes the feature
%                    is selected, 0 denotes it is not selected.
%        trainfuncs - M*N_obj matrix, where M is the number of nondomianted solutions, N_obj is the number
%                    of objective functions.
%        performance - M*N_per performance metric results of each nondomianted soltion. Does not affect the 
%                      selection of ideal point method. Just used to obtain the performance metric results 
%                     of the ideal point.
% Output: output - a struct to strore the information of found ideal point
%                  output.Solution - the ideal point (solution) 
%                  output.Trainfunc - the objective function values of the ideal solution
%                  output.Performance - the performance metric results of ideal solution
%                  output.Solution2 - the same as ideal solution, but it is a set recording the index of
%                                     selected features



    [~,M]=size(trainfuncs);
    V=size(solutions,2);
    
    F_solutions=[solutions,trainfuncs,performance];
   
    [uobj,p_in_f]=unique(F_solutions(:,(V+1:M+V)),'rows');
    N = size(uobj,1);
    W = repmat(w, N,1);
     upoints=zscore(uobj).* W;
    
    per_point=min(upoints);
   % per_point=(zeros(1,M)-mean(uobj))./std(uobj);
    uPointNum=size(upoints,1);
    dist_norm=zeros(uPointNum,1);
    for i=1:  uPointNum
       dist_norm(i)=norm(upoints(i,:)-per_point);
    end
    [V_dist,I_dist]=min(dist_norm);
    obj_set=F_solutions(p_in_f(I_dist),(V+1:M+V));

    Per_result=F_solutions(ifinclude(F_solutions(:,(V+1:M+V)),obj_set) ,:);

    output.Solution=Per_result(:,1:V);
    output.Trainfunc=Per_result(:,[V+1:V+M]);
    output.Performance=Per_result(:,[V+M+1:end]);
    for i = 1:size(output.Solution,1)
       output.Solution2(i,:) = find(output.Solution(i,:) == 1); 
    end    
end