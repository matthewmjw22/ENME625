% syms x
% n=30;
% f1 = x;  % Min
% h = 1 - sqrt(f1/g)  -  (f1/g)*sin(10*pi*f1) ;
% g = 1 + 9/(n-1) * symsum(x,x,2,n)
% f2 = g*h;   % Min
% 
% % X between 0 and 1


% Call our moga function



n = 30;
f1 = @(x) x; % minimize
g = @(x) 1 + 9/(n-1) * sum(x(2:end));
h = @(x) 1 - sqrt(x(1)/g(x)) - (x(1)/g(x))*sin(10*pi*x(1));
f2 = @(x) g(x)*h(x); % minimize

lb = 0; % lower bound
ub = 1; % upper bound

nonlcon = @(x) deal([], [1 - x(1)]); % nonlinear constraint, x1 <= 1

options = optimoptions('gamultiobj', 'PopulationSize', 100, 'MaxGenerations', 500, 'Display', 'final', 'PlotFcn',@gaplotpareto);
[x,fval,exitflag,output] = gamultiobj(@(x) [f1(x), f2(x)], n, [], [], [], [], lb, ub, nonlcon, options);

