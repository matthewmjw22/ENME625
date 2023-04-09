function [x,fval,exitflag,output,population,score] = gamultiobjSOLVER(nvars,lb,ub,MaxGenerations_Data)
%% This is an auto generated MATLAB file from Optimization Tool.

%% Start with the default options
options = optimoptions('gamultiobj');
%% Modify options setting
options = optimoptions(options,'MaxGenerations', MaxGenerations_Data);
options = optimoptions(options,'CrossoverFcn', {  @crossoverintermediate [] });
options = optimoptions(options,'Display', 'off');
options = optimoptions(options,'PlotFcn', { @gaplotpareto });
[x,fval,exitflag,output,population,score] = ...
gamultiobj(@objective_functionRunMOGA_OSY,nvars,[],[],[],[],lb,ub,@nonlinear_constraintsRunMOGA_OSY,options);
