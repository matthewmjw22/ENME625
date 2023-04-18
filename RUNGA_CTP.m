clc
clear all

nvars = 10;
lb = [0; -5; -5; -5; -5; -5; -5; -5; -5; -5];
ub = [1; 5; 5; 5; 5; 5; 5; 5; 5; 5];
MaxGenerations_Data = 2000;

[x,fval,exitflag,output,population,score] = GA(nvars,lb,ub,MaxGenerations_Data);

fval
x

func = objective_functionCTP_batch(x);
f1 = func(:, 1)
f2 = func(:, 2)

for i = 1:size(func, 1)
    scatter(f1(1, :), f2(1, :))
end
