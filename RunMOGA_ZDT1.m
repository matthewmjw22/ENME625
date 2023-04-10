clc
clear all

nvars = 1;
lb = 0;
ub = 1;
MaxGenerations_Data = 100;

[x,fval,exitflag,output,population,score] = gamultiobjsolver_ZDT1(nvars,lb,ub,MaxGenerations_Data);

fval
x