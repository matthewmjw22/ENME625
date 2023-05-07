clc
clear all

nvars = 30;
lb = zeros(30, 1);
ub = ones(30, 1);
MaxGenerations_Data = 10000;

[x,fval,exitflag,output,population,score] = gamultiobjsolver_ZDT1(nvars,lb,ub,MaxGenerations_Data);

fval
x

pareto_spread = Pareto_Spread(fval);
pareto_spread
clus = cluster(fval, 100);
clus

for i = 1:size(population, 1)
    values(:, i) = objective_functionZDT1(population(i, :));
end

OS = (max(values(1, :)) - min(values(1,:)))*(max(values(2, :)) - min(values(2,:)))
pareto_spread/OS