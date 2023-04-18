clc
clear all

nvars = 1;
lb = 0;
ub = 1;
MaxGenerations_Data = 200;

[x,fval,exitflag,output,population,score] = gamultiobjsolver_ZDT3(nvars,lb,ub,MaxGenerations_Data);

fval
x


% Quality Metrics

% Pareto Spread 
% extract x and y values
x = fval(:,1);
y = fval(:,2);

% calculate range of x and y values
x_range = max(x) - min(x);
y_range = max(y) - min(y);

% calculate maximum range and Pareto spread
pareto_spread =x_range*y_range


% Cluster(CLu) 
% cluster = number of the observed Pareto solutions/he number of distinct choices



% assume your array is called x
num_rows = size(x, 1); % get the number of rows in x
unique_rows = zeros(num_rows, 1); % initialize a vector to store the number of unique rows

for i = 1:num_rows
    % get the unique row
    unique_row = unique(x(i, :));
    
    % check if the unique row is the same as the original row
    if isequal(unique_row, x(i, :))
        unique_rows(i) = 1; % if the row is unique, set the corresponding element in unique_rows to 1
    end
end

num_distinct = sum(unique_rows); % get the total number of distinct rows
Cluster = num_rows/num_distinct