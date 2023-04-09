% syms x
% n=30;
% f1 = x;  % Min
% h = 1 - (f1/g)^2 ;
% g = 1 + 9/(n-1) * symsum(x,x,2,n)
% f2 = g*h;   % Min

% X between 0 and 1


% Call our moga function



n = 30;
fun = @(x) [x, (1 - (x(1)/(1 + 9/(n-1) * sum(x(2:end)))).^2) * (1 + 9/(n-1) * sum(x(2:end)))];
lb = 0;
ub = 1;
nonlcon = @(x) deal([], [1 - (x(1)/(1 + 9/(n-1) * sum(x(2:end))))^2]);

options = optimoptions('gamultiobj', 'PopulationSize', 100, 'MaxGenerations', 500, 'Display', 'final', 'PlotFcn',@gaplotpareto);
[x, fval] = gamultiobj(fun, n, [], [], [], [], lb, ub, nonlcon, options);