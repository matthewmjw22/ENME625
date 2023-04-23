% ENME 625 Multidisciplinary Optimization
% University of Maryland College Park

% Genetic Algorithm (GA) Demo 
% Single- and Multi-objective algorithms
% Two-bar truss example Palli et al. (1999)

% Last Update 20200402 : Azarm, SA, Aute VC., 
% Used revised function names to avoid warnings, tested with version 2019b.


% Clear and Close everything incase we have Figure windows open from
% previous runs of this code.

clear all
close all

% Declare global variable for later use
global gen
% number of design variables
nvars = 3;
% lower and upper bound of design variables
% lb = [1e-4 1e-4 1];
% ub = [0.25 0.25 3];
lb = [1e-6 1e-6  1];
ub = [1    1     3];
% Start with the default options and modify options setting
options = optimoptions('ga');
options = optimoptions(options,'PopulationSize', 60);
% options = gaoptimset(options,'PlotFcns', {@gaplotpareto });
% options = gaoptimset(options,'PlotFcns', {@gaplotbestf });
options = optimoptions(options,'Generations', 100);
options = optimoptions(options,'Display', 'iter');
options = optimoptions(options,'Vectorized', 'on');

% Single-objective GA
% Create figure for population
figHandle = figure('Name','Single-objective GA Demo','NumberTitle','off');
set(gcf, 'units' ,'normalized', 'position', [0.2,0.2,0.6,0.6]);
axis([0 100 0 1.8]);
xlabel('Generation','interp','none')
ylabel('Volume','interp','none')
title ('Population and Best Fitness')
grid on
hold all

gen = 0;
[~,fval] = ga(@GAObjFun,nvars,[],[],[],[],lb,ub,[],options);
legend('Population','Best')

% Multi-objective GA
% creat figure for population
figHandle = figure('Name','Multi-objective GA Demo','NumberTitle','off');
axis([0 2 0 1e+4]);
xlabel('Volume','interp','none')
ylabel('Maximum Stress','interp','none')
title ('Population and Pareto')
grid on
hold all
plotHandle = plot(0,0,'ok');
set(plotHandle, 'Tag', 'plot');

set(gcf, 'units' ,'normalized', 'position', [0.2,0.2,0.6,0.6]);

% options1 = optimoptions(options1, 'ParetoFraction', 0.6);
options = optimoptions('gamultiobj', 'ParetoFraction', 0.6, ...
                        'PopulationSize', 100, ...
                        'Generations', 200, ...
                        'Vectorized', 'on');
[~,fval] = gamultiobj(@(x)MOGAObjFun(x,figHandle),nvars,[],[],[],[],lb,ub,options);

hold on
plot(fval(:,1),fval(:,2),'pm');
legend('Population','Pareto frontier')

hold off

