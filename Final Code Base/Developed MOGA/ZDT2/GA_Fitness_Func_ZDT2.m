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
    
    % Initialize empty vector for objective function value storage
    % 2 coresponds to 2 objective functions for this problem
    population_objectives_vector = zeros(NumDesign,2);
    
    % R1 = penalty factor
    R1 = 1000000;
    
    % CALCULATE THE INITIAL OBJECTIVE FUNCTION VALUES FOR EACH INDIVIDUAL
    % ix is the index for current design
    for ix = 1:NumDesign

        % pluck indiovidual dsign out of the population array
        Input = X(ix,:);
    
        x1 = Input(1);
        x2 = Input(2);
        x3 = Input(3);
        x4 = Input(4);
        x5 = Input(5);
        x6 = Input(6);
        x7 = Input(7);
        x8 = Input(8);
        x9 = Input(9);
        x10 = Input(10);
        x11 = Input(11);
        x12 = Input(12);
        x13 = Input(13);
        x14 = Input(14);
        x15 = Input(15);
        x16 = Input(16);
        x17 = Input(17);
        x18 = Input(18);
        x19 = Input(19);
        x20 = Input(20);
        x21 = Input(21);
        x22 = Input(22);
        x23 = Input(23);
        x24 = Input(24);
        x25 = Input(25);
        x26 = Input(26);
        x27 = Input(27);
        x28 = Input(28);
        x29 = Input(29);
        x30 = Input(30);
    
        g = 1 + (9/29)*sum(Input(2:30));
    
        F1 = x1; % Min
        F2 = (1 - (x1/g)^2)*g;  %Min

        % update fittness vector
        population_objectives_vector(ix,1) = F1;
        population_objectives_vector(ix,2) = F2;
    end
    
    
    % DETERMINE THE FRONTS OF THE POPULATION SET
    fronts = non_dominated_sort(population_objectives_vector);
    
    % CALCULATE THE ADJUSTED FITTNESS VALUES FOR EACH INDIVIDUAL
    [dist, niche, shared_fitness] = calc_rank_distances(X,  population_objectives_vector, fronts, .75, 1, .25);
    
    
    % define final population fitness storage vector:
    % Define final population fitness output vector:
    final_population_fitness = -shared_fitness;

    
    % ------------------ OUTPUT FORMARTTING ------------------------------
    % output population data to excel file:
    population_data = [X, population_objectives_vector, fronts, final_population_fitness];
    filename = 'population_data_tracker.xlsx';
    writematrix(population_data,filename,'Sheet',1);
    
    % Plot the latest generations
    %plot(gen.*ones(NumDesign,1),population_objectives_vector,'.k');
    %plot(gen, min(population_objectives_vector),'+m');
    %gen = gen+1;
    %pause(0.1)