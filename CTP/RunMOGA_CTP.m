clc
clear all

nvars = 10;
lb = [0; -5; -5; -5; -5; -5; -5; -5; -5; -5];
ub = [1; 5; 5; 5; 5; 5; 5; 5; 5; 5];
MaxGenerations_Data = 1000;

[x,fval,exitflag,output,population,score] = gamultiobjsolver_CTP(nvars,lb,ub,MaxGenerations_Data);

fval
x


pareto_spread = Pareto_Spread(fval);
pareto_spread
clus = cluster(fval, 200);
clus


for i = 1:size(population, 1)
    values(:, i) = objective_functionCTP(population(i, :));
end

OS = (max(values(1, :)) - min(values(1,:)))*(max(values(2, :)) - min(values(2,:)))
pareto_spread/OS