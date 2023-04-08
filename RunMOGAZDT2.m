syms x
n=30;
f1 = x;  % Min
h = 1 - (f1/g)^2 ;
g = 1 + 9/(n-1) * symsum(x,x,2,n)
f2 = g*h;   % Min

% X between 0 and 1


% Call our moga function