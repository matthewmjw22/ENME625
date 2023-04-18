clc
clear all

nvars = 2;
lb = [0; 0];
ub = [pi; pi];
MaxGenerations_Data = 300;

[x,fval,exitflag,output,population,score] = GA_TNK(nvars,lb,ub,MaxGenerations_Data);

fval
x

func = objective_functionRunMOGA_TNK(x);
f1 = func(:, 1)
f2 = func(:, 2)

for i = 1:size(func, 1)
    scatter(f1(1, :), f2(1, :))
end