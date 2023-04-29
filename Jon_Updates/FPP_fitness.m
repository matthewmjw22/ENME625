function final_population_fitness = FPP_fitness(X)

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
    global P1
    global P2
    
    % Initialize empty vector for objective function value storage
    % 2 coresponds to 2 objective functions for this problem
    population_objectives_vector = zeros(NumDesign,2);
    
    % R1 = penalty factor
    R1 = 100000000;
    
    % CALCULATE THE INITIAL OBJECTIVE FUNCTION VALUES FOR EACH INDIVIDUAL
    % ix is the index for current design
    for ix = 1:NumDesign
    
        % pluck indiovidual dsign out of the population array
        x = X(ix,:);
        
        % ---------- INITIAL OBJECTIVE FUNCTION VALUATION -------------------
    
        pathPoints = x(1);
        W_x = x(2);
        W_y = x(3);
        AirSpeed = x(4);
        sizeX = x(5);
        sizeY = x(6);
        method = x(7);
        integrationFineness = x(8);

        F1 = getTimeFromPath(pathPoints,W_x,W_y,AirSpeed,sizeX,sizeY,method,integrationFineness);
        F2 = -(((pathPoints(1, 1) - 10)^2   +    (pathPoints(1, 1) - 40)^2)     +   ((pathPoints(1, 2) - 8)^2   +    (pathPoints(1, 1) - 20)^2));  
    
        % update fittness vector
        population_objectives_vector(ix,1) = F1;
        population_objectives_vector(ix,2) = F2;
    end
    
    % CONSTRAINT HANDELING
    % define empty array for storing constrain values:
    constrained_fitness = zeros(NumDesign,2);
    
    %tracking variable fon constraints:
    violation_tracker = zeros(NumDesign,1);

    for ix = 1:NumDesign
    
        % pluck indiovidual dsign out of the population array
        x = X(ix,:);
    
        C = [zeros(2,1)];
        pathPoints = x(1);
        W_x = x(2);
        W_y = x(3);
        AirSpeed = x(4);
        sizeX = x(5);
        sizeY = x(6);
        method = x(7);
        integrationFineness = x(8);
    
        C(1) = ((pathPoints(1, 1) - 10)^2 + (pathPoints(1, 2) - 8)^2) - 3^2;
        % Add P * 3^2 to add uncertainty to size of red circle 
        C(2) = ((pathPoints(1, 1) - 40)^2 + (pathPoints(1, 2) - 20)^2) - 3^2;
    
        Ceq = [];
    
         % initilize constraint violation value = 0
        total_violation = 0;
    
        for z = 1:length(C)
    
            if C(z) > 0
    
                total_violation = total_violation + C(z);
   
            end 
    
        end

        violation_tracker(ix,1) = total_violation * R1;

        constrained_fitness(ix,1) = population_objectives_vector(ix,1) + (total_violation * R1);
        constrained_fitness(ix,2) = population_objectives_vector(ix,2) + (total_violation * R1);
    end
    
    % attempting to implement CH-I2 (Kurpati et al 2002)
    %average_constraint_violation = sum(violation_storage) / NumDesign;
    
    % DETERMINE THE FRONTS OF THE POPULATION SET
    fronts = non_dominated_sort(constrained_fitness);
    
    % CALCULATE THE ADJUSTED FITTNESS VALUES FOR EACH INDIVIDUAL
    [dist, niche, shared_fitness] = calc_rank_distances(X,  constrained_fitness, fronts, .50, 4, .25);
    
    
    % define final population fitness storage vector:
    % Define final population fitness output vector:
    final_population_fitness = -shared_fitness;
    
    

    
    
    % ------------------ OUTPUT FORMARTTING ------------------------------
    % output population data to excel file:
    population_data = [X, population_objectives_vector, fronts, violation_tracker, constrained_fitness, final_population_fitness];
    filename = 'population_data_tracker.xlsx';
    writematrix(population_data,filename,'Sheet',1);
    
    % Plot the latest generations
    plot(gen.*ones(NumDesign,1),constrained_fitness,'.k');
    plot(gen, min(constrained_fitness),'+m');
    gen = gen+1;
    pause(0.1)