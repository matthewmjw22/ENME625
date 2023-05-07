clc
clear all

nvars = 30;
lb = zeros(30, 1);
ub = ones(30, 1);
MaxGenerations_Data = 100000000;

[x,fval,exitflag,output,population,score] = gamultiobjsolver_ZDT2(nvars,lb,ub,MaxGenerations_Data);

fval;
x;


pareto_spread = Pareto_Spread(fval);
pareto_spread;
clus = cluster(fval, 100);
clus;

for i = 1:size(population, 1)
    values(:, i) = objective_functionZDT2(population(i, :));
end

OS = (max(values(1, :)) - min(values(1,:)))*(max(values(2, :)) - min(values(2,:)));
pareto_spread/OS;

num_function_calls = output.funccount;
num_pareto_points = length(fval);

%function calls per pareto optimal point
calls_per_pareto = ceil(num_function_calls/num_pareto_points);

%Format the quality output metrics for user viewing:
%Note: the quality adjustment factor (the number that the pareto spread has
%been devided by) has been determined through condiucting multiple runs of
%the test problem
disp('+++++++++++++++++++++++++++++++++++++++++++++++++++++');
disp('OSY QUALITY METRICS:');
disp('---');
disp(['Pareto Spread: ' num2str(pareto_spread/0.984)]);
disp(['Cluster Metric: ' num2str(clus)]);
disp(['Function calls per pareto point: ' num2str(calls_per_pareto)]);
disp(['Number of Pareto Points: ' num2str(num_pareto_points)]);
disp('+++++++++++++++++++++++++++++++++++++++++++++++++++++');