clc
clear all

nvars = 2;
lb = [0; 0];
ub = [pi; pi];
MaxGenerations_Data = 200;

[x,fval,exitflag,output,population,score] = gammultiobjsolverTNK(nvars,lb,ub,MaxGenerations_Data);

fval
x