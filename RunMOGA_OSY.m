clc
clear all

nvars = 6;
lb = [0; 0; 1; 0; 1; 0];
ub = [10; 10; 5; 6; 5; 10];
MaxGenerations_Data = 100;

[x,fval,exitflag,output,population,score] = gamultiobjSOLVER(nvars,lb,ub,MaxGenerations_Data);

fval
x