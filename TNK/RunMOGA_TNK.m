

clc
clear all

nvars = 2;
lb = [0; 0];
ub = [pi; pi];
MaxGenerations_Data = 200;

[X,fval,exitflag,output,population,score] = gammultiobjsolverTNK(nvars,lb,ub,MaxGenerations_Data);

fval
X

pareto_spread = Pareto_Spread(fval);
pareto_spread
clus = cluster(fval, 100);
clus

for i = 1:size(population, 1)
    values(:, i) = objective_functionRunMOGA_TNK(population(i, :));
end

OS = (max(values(1, :)) - min(values(1,:)))*(max(values(2, :)) - min(values(2,:)));
pareto_spread/OS