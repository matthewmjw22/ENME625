function final_population_fitness = GA_Fitness_Func_ZDT2(X)

% This function calculates the multi-objective, constraint adusted fitness
% of a population of candidate solutions

% INPUTS: 
% X - Matlab generated population of candidate designs (with length n -
% number of design variables)

% OUTPUTS:
% final_population_fitness - vector of fitness values for each member of
% the generated population

% PROCEDURE:
% 1. calculate objective function value(s) for each member of population
% 2. calculate fronts for population
% 3. calculate adjueted fitness for each population member (nc, etc)
% 4. calculate constraint adjusted fitness

% Documentation: framerwork was inspired from Dr. Aute's GA code

% determine the number of designs in the population
NumDesign = size(X, 1);

global gen
global objective_func_value_storage

% Initialize empty vector for objective function value storage
% 2 coresponds to 2 objective functions for this problem
population_objectives_vector = zeros(NumDesign,2);

% R1 = penalty factor
R1 = 1000;

% CALCULATE THE INITIAL OBJECTIVE FUNCTION VALUES FOR EACH INDIVIDUAL
% ix is the index for current design
for ix = 1:NumDesign

    % pluck indiovidual dsign out of the population array
    x = X(ix,:);
    
    % ---------- INITIAL OBJECTIVE FUNCTION VALUATION -------------------

    x1 = x(1);

    F1 = x1; % Min
    F2 = 1 - (x1)^2;  %Min

    % update fittness vector
    population_objectives_vector(ix,1) = F1;
    population_objectives_vector(ix,2) = F2;
end

% DETERMINE THE FRONTS OF THE POPULATION SET
fronts = non_dominated_sort(population_objectives_vector);

% CALCULATE THE ADJUSTED FITTNESS VALUES FOR EACH INDIVIDUAL
[dist, niche, shared_fitness] = calc_rank_distances(X, population_objectives_vector, fronts, .75, 1, .25);

% CONSTRAINT HANDELING
% define empty array for storing constrain values:
constrained_fitness = zeros(NumDesign,1);

for ix = 1:NumDesign

    % pluck indiovidual dsign out of the population array
    x = X(ix,:);

    x1 = x(1);
    x2 = x(2);
    x3 = x(3);
    x4 = x(4);
    x5 = x(5);
    x6 = x(6);
    
    C = [zeros(6,1)];
    C(1) = 1 - (x1+x2)/2;
    C(2) = (x1 + x2)/6 -1;
    C(3) =(x2-x1)/2 - 1;
    C(4) = (x1 - 3*x2)/2 -1;
    C(5) =((x3-3)^2 + x4)/4 -1;
    C(6) = 1 - ((x5 - 3)^2 + x6)/4;
    Ceq = [];
    constrained_fitness(ix) = -shared_fitness(ix) + R1*sum(C(C>0));
end



% Define final population fitness output vector:
final_population_fitness = constrained_fitness

% ------------------ OUTPUT FORMARTTING ------------------------------

% output population data to excel file:
population_data = [population_objectives_vector, fronts, niche, shared_fitness];
filename = 'population_data.xlsx';
writematrix(population_data,filename,'Sheet',1)

% append to value storage global vector
objective_func_value_storage = [objective_func_value_storage; population_objectives_vector]

% Plot the latest generations
plot(gen.*ones(NumDesign,1),constrained_fitness,'.k');
plot(gen, min(constrained_fitness),'+m');
gen = gen+1;
pause(0.1)