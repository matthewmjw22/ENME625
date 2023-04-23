% ENME 625 Multidisciplinary Optimization
% University of Maryland College Park

% Genetic Algorithm (GA) Demo 
% Single- and Multi-objective algorithms
% Two-bar truss example Palli et al. (1999)

% Last Update 20200402 : Azarm, SA, Aute VC., 
% Used revised function names to avoid warnings, tested with version 2019b.


function  f = GAObjFun(DesignVector)
global gen

% NumDesign = total number of design
NumDesign = size(DesignVector, 1);

% f = objective function , intialized 
f = zeros(NumDesign,1);


% R1 = penalty factor
R1 = 1000;

% ix is the index for current design

for ix = 1:NumDesign
    x = DesignVector(ix,:);
    % f1 = total volume
    f(ix) = x(1)*sqrt(16+x(3)^2)+ x(2)*sqrt(1+x(3)^2);
    
    g(1) = 20*sqrt(16+x(3)^2)/(1e+5*x(1)*x(3))-1;
    g(2) = 80*sqrt(1+ x(3)^2)/(1e+5*x(2)*x(3))-1;
    
    if any(g)>0 % infeasible
        f(ix) = f(ix)+R1*sum(g(g>0));
    end
end


% Plot the latest generations
plot(gen*ones(NumDesign,1),f,'.k');
plot(gen, min(f),'+m');
gen = gen+1;
pause(0.1)