syms x1 x2

f1 = x1;  % Min

f2 = x2;  % Min

g1 = x1^2 + x2^2 -1 - 0.1*cos(16*atan(x1/x2)) <= 0;

g2 = (x1 - 0.5)^2 + (x2 - 0.5)^2 -0.5 <= 0;

% x1 and x2 between [0, pi]