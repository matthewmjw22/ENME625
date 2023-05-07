clc
clear all

nvars = 6;
lb = [0; 0; 1; 0; 1; 0];
ub = [10; 10; 5; 6; 5; 10];
MaxGenerations_Data = 1000;

[x,fval,exitflag,output,population,score] = gamultiobjSOLVER(nvars,lb,ub,MaxGenerations_Data);

fval
x

pareto_spread = Pareto_Spread(fval);
pareto_spread
clus = cluster(fval, 200);
clus

for i = 1:size(population, 1)
    values(:, i) = objective_functionRunMOGA_OSY(population(i, :));
end

OS = (max(values(1, :)) - min(values(1,:)))*(max(values(2, :)) - min(values(2,:)))
pareto_spread/OS
