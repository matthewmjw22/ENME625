% ENME 625 Multidisciplinary Optimization
% University of Maryland College Park

% Genetic Algorithm (GA) Demo 
% Single- and Multi-objective algorithms
% Two-bar truss example Palli et al. (1999)

% Last Update 20200402 : Azarm, SA, Aute VC., 
% Used revised function names to avoid warnings, tested with version 2019b.
% Added fobj variable to store/plot actual objective values instead of
% penalized values.

% For use with GA/MOGA Demo

function  f = MOGAObjFun(DesignVector, figHandle)
% NumDesign = total number of design
NumDesign = size(DesignVector, 1);
% f = objective function , intialized 
f = zeros(NumDesign,2);

% Store objectives only for plotting purposes
fobj = zeros(NumDesign,2);

% R1 = penalty factor
R1 = 10000;
% ix is the index for current design
for ix = 1:NumDesign
    x = DesignVector(ix,:);
    % f1 = total volume
    f(ix, 1) = x(1)*sqrt(16+x(3)^2)+ x(2)*sqrt(1+x(3)^2);
    % s1 = normal stree on bar 1
    s1 = 20*sqrt(16+x(3)^2)/(x(1)*x(3));
    % s2 = normal stree on bar 2
    s2 = 80*sqrt(1+x(3)^2)/(x(2)*x(3));
    f(ix, 2) = max(s1, s2);
    
    fobj(ix,1) = f(ix,1);
    fobj(ix,2) = f(ix,2);
    
    g(1) = 20*sqrt(16+x(3)^2)/(1e+4*x(1)*x(3))-1;
    g(2) = 80*sqrt(1+ x(3)^2)/(1e+4*x(2)*x(3))-1;
    
    % Add a penalty to teh fitness value for all infeasible candidates
    if any(g) > 0 % infeasible
        f(ix, 1) = f(ix, 1)+R1*sum(g(g>0));
        f(ix, 2) = f(ix, 2)+R1*sum(g(g>0));
    end
end

% Plot current population
plotHandle = findobj(figHandle,'Tag', 'plot');

% Plot for non-penalized objective functions
% We could plot the penalized values as well, just use f, instead of fobj
set(plotHandle,'Xdata',fobj(:,1),'Ydata',fobj(:,2));
drawnow

% Pause briefly to wait for the plot to render
pause(0.1)