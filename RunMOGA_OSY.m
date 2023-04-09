syms x1 x2 x3 x4 x5 x6

f1 = -(25*(x1-2)^2 + (x2 -2)^2 + (x3-1)^2 + (x4-4)^2 + (x5-1)^2); % Min
f2 = x1^2+x2^2+x3^2+x4^2+x5^2 + x6^2;  %Min

g1 = isAlways(1 - (x1+x2)/2 <= 0);
g2 = isAlways((x1 + x2)/6 -1 <= 0);
g3 = isAlways((x2-x1)/2 - 1 <= 0);
g4 = isAlways((x1 - 3*x2)/2 -1 <= 0);
g5 = isAlways(((x3-3)^2 + x4)/4 -1 <= 0);
g6 = isAlways(1 - ((x5 - 3)^2 + x6)/4 <= 0);

% x1 x2 and x6 between [0, 10]
% x3 and x5 bounded [1, 5]
% x4 between [0, 6]

lb = [0, 0, 1, 0, 1, 0];
ub = [10, 10, 5, 6, 5, 10];

fun = @(x) [f1, f2];
nonlcon = @(x) deal([g1, g2, g3, g4, g5, g6], []); % return two empty arrays for equality constraints

options = optimoptions('gamultiobj','PopulationSize',100,'MaxGenerations',500,'Display','final', 'PlotFcn',@gaplotpareto);

[x,fval] = gamultiobj(fun,6,[],[],[],[],lb,ub,nonlcon,options);