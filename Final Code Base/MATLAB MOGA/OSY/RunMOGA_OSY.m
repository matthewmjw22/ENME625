clc
clear all

nvars = 6;
lb = [0; 0; 1; 0; 1; 0];
ub = [10; 10; 5; 6; 5; 10];
MaxGenerations_Data = 1000;

[x,fval,exitflag,output,population,score] = gamultiobjSOLVER(nvars,lb,ub,MaxGenerations_Data);

fval;
x;

pareto_spread = Pareto_Spread(fval);
clus = cluster(fval, 200);

for i = 1:size(population, 1)
    values(:, i) = objective_functionRunMOGA_OSY(population(i, :));
end

OS = (max(values(1, :)) - min(values(1,:)))*(max(values(2, :)) - min(values(2,:)));

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
disp(['Pareto Spread: ' num2str(pareto_spread/20147)]);
disp(['Cluster Metric: ' num2str(clus)]);
disp(['Function calls per pareto point: ' num2str(calls_per_pareto)]);
disp(['Number of Pareto Points: ' num2str(num_pareto_points)]);
disp('+++++++++++++++++++++++++++++++++++++++++++++++++++++');



