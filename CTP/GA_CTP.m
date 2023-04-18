function [x,fval,exitflag,output,population,score] = GA(nvars,lb,ub,MaxGenerations_Data)
%% This is an auto generated MATLAB file from Optimization Tool.

%% Start with the default options
options = optimoptions('ga');
%% Modify options setting
options = optimoptions(options,'MaxGenerations', MaxGenerations_Data);
options = optimoptions(options,'CreationFcn', @gacreationuniform);
options = optimoptions(options,'CrossoverFcn', @crossoverscattered);
options = optimoptions(options,'MutationFcn', {  @mutationuniform [] });
options = optimoptions(options,'Display', 'iter');
options = optimoptions(options,'MaxStallGenerations', 1000);
options = optimoptions(options, 'PlotFcn', @gaplotbestf);
% options = optimoptions(options,'Vectorized', 'on')
[x,fval,exitflag,output,population,score] = ...
ga(@Fitness_CTP,nvars,[],[],[],[],lb,ub,[],[],options);
