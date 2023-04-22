function pareto_spread = Pareto_Spread(fval)

% Pareto Spread 
% extract x and y values
x = fval(:,1);
y = fval(:,2);

% calculate range of x and y values
x_range = max(x) - min(x);
y_range = max(y) - min(y);

% calculate maximum range and Pareto spread
pareto_spread =x_range*y_range;
end