clc
clear all

nvars = 6;
lb = [0; 0; 1; 0; 1; 0];
ub = [10; 10; 5; 6; 5; 10];
MaxGenerations_Data = 200;

[x,fval,exitflag,output,population,score] = GA_OSY(nvars,lb,ub,MaxGenerations_Data);

fval
x

func = objective_functionRunMOGA_OSY(x);
f1 = func(:, 1)
f2 = func(:, 2)

for i = 1:size(func, 1)
    scatter(f1(1, :), f2(1, :))
end
