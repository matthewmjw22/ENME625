clc
clear all
% Declare global variable for later use

% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% GA run parameters
num_runs = 20
population_size = 200
num_generations = 20
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% define first rank (pareto front) storage vector:
overall_runs_rank_1 = []
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% FUNCTION LIBRARY

% TEST PROBLEM ---------> FUNCTION TO CALL
%******************************************************************
%    OSY       ---------> RUN_OSY(num_runs, overall_runs_rank_1,...)
%    CTP       ---------> RUN_CTP(num_runs, overall_runs_rank_1,...)
%    TNK       ---------> RUN_TNK(num_runs, overall_runs_rank_1,...)
%   ZDT1       ---------> RUN_ZDT1(num_runs, overall_runs_rank_1,...)
%   ZDT2       ---------> RUN_ZDT2(num_runs, overall_runs_rank_1,...)
%   ZDT3       ---------> RUN_ZDT3(num_runs, overall_runs_rank_1,...)

% CALL THE TEST PROBLEM YOU WISH TO RUN
RUN_CTP(num_runs, overall_runs_rank_1, population_size, num_generations)
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%---------------------------------------------------------------------------
function RUN_OSY(num_runs, overall_runs_rank_1, population_size, num_generations)
    
    % define global generation tracker (for plotting purposes)
    global gen
    %declare global valriable for storing all individual objective function
    %value - used for determining pareto front
    global objective_func_value_storage

    for run = 1:num_runs
    %---------------------------- OSY PROBLEM-------------------------------
    
        nvars = 6;
        lb = [0; 0; 1; 0; 1; 0];
        ub = [10; 10; 5; 6; 5; 10];
        
        options = optimoptions('ga');
        options = optimoptions(options,'MaxGenerations', num_generations);
        options = optimoptions(options,'CreationFcn', @gacreationuniform);
        options = optimoptions(options,'CrossoverFcn', @crossoverscattered);
        options = optimoptions(options,'MutationFcn', {  @mutationuniform [] });
        options = optimoptions(options,'Display', 'iter');
        options = optimoptions(options,'MaxStallGenerations', 40);
        options = optimoptions(options, 'PlotFcn', @gaplotbestf);
        options = optimoptions(options,'Vectorized', 'on')
        options = optimoptions(options,'PopulationSize', population_size);
    
        gen = 0;
        objective_func_value_storage = []
        
        % call the GA for the required test problem
        [~,fval] = ga(@GA_Fitness_Func_OSY,nvars,[],[],[],[],lb,ub,[],options);
        legend('Population','Best')
        
        % storage array for storing the "first rank" members of the
        % population
        rank_1_population = [];
        
        % sorts the population into fronts
        ranks = non_dominated_sort(objective_func_value_storage);

        % picks out the array indexes of the forst frint candidate
        % solutions
        rank_1_indexes = find(ranks ==1);
        
        % loops through each index and stores the objective function values
        for j = 1:length(rank_1_indexes)
            
            index = rank_1_indexes(j);
        
            rank_1_population = [rank_1_population; objective_func_value_storage(index,1), objective_func_value_storage(index,2)];
        
        end
        
        % for each GA run this stores all of the "first rank" individual
        % designs
        overall_runs_rank_1 = [overall_runs_rank_1; rank_1_population]
    
    end
    
    % storage variable for OVERALL (for all runs) "first rank" solutions
    overall_rank_1_population = [];
    
    % determines rankls and picks out the indexes of the first rank
    % individuals
    ranks = non_dominated_sort(overall_runs_rank_1);
    rank_1_indexes = find(ranks ==1);
    
    % loops through each index and adds the objective function values to
    % the above strage array - which will be plotted
    for j = 1:length(rank_1_indexes)
        
        index = rank_1_indexes(j);
    
        overall_rank_1_population = [overall_rank_1_population;  overall_runs_rank_1(index,1),  overall_runs_rank_1(index,2)];
    
    end

    % plot the final pareto front for the simulated number of GA runs
    scatter(overall_rank_1_population(:,1),  overall_rank_1_population(:,2), 15, ...
         'MarkerEdgeColor',[0 .5 .5],...
         'MarkerFaceColor',[0 .7 .7],...
         'LineWidth',0.75)
end
%----------------------------------------------------------------------------

%---------------------------------------------------------------------------
function RUN_CTP(num_runs, overall_runs_rank_1, population_size, num_generations)
    
    % define global generation tracker (for plotting purposes)
    global gen
    %declare global valriable for storing all individual objective function
    %value - used for determining pareto front
    global objective_func_value_storage

    for run = 1:num_runs
    %---------------------------- CTP PROBLEM-------------------------------
    
        nvars = 10;
        lb = [0; -5; -5; -5; -5; -5; -5; -5; -5; -5];
        ub = [1; 5; 5; 5; 5; 5; 5; 5; 5; 5];
        
        options = optimoptions('ga');
        options = optimoptions(options,'MaxGenerations', num_generations);
        options = optimoptions(options,'CreationFcn', @gacreationuniform);
        options = optimoptions(options,'CrossoverFcn', @crossoverscattered);
        options = optimoptions(options,'MutationFcn', {  @mutationuniform [] });
        options = optimoptions(options,'Display', 'iter');
        options = optimoptions(options,'MaxStallGenerations', 40);
        options = optimoptions(options, 'PlotFcn', @gaplotbestf);
        options = optimoptions(options,'Vectorized', 'on')
        options = optimoptions(options,'PopulationSize', population_size);
    
        gen = 0;
        objective_func_value_storage = []
        
        % call the GA for the required test problem
        [~,fval] = ga(@GA_Fitness_Func_CTP,nvars,[],[],[],[],lb,ub,[],options);
        legend('Population','Best')
        
        % storage array for storing the "first rank" members of the
        % population
        rank_1_population = [];
        
        % sorts the population into fronts
        ranks = non_dominated_sort(objective_func_value_storage);

        % picks out the array indexes of the forst frint candidate
        % solutions
        rank_1_indexes = find(ranks ==1);
        
        % loops through each index and stores the objective function values
        for j = 1:length(rank_1_indexes)
            
            index = rank_1_indexes(j);
        
            rank_1_population = [rank_1_population; objective_func_value_storage(index,1), objective_func_value_storage(index,2)];
        
        end
        
        % for each GA run this stores all of the "first rank" individual
        % designs
        overall_runs_rank_1 = [overall_runs_rank_1; rank_1_population]
    
    end
    
    % storage variable for OVERALL (for all runs) "first rank" solutions
    overall_rank_1_population = [];
    
    % determines rankls and picks out the indexes of the first rank
    % individuals
    ranks = non_dominated_sort(overall_runs_rank_1);
    rank_1_indexes = find(ranks ==1);
    
    % loops through each index and adds the objective function values to
    % the above strage array - which will be plotted
    for j = 1:length(rank_1_indexes)
        
        index = rank_1_indexes(j);
    
        overall_rank_1_population = [overall_rank_1_population;  overall_runs_rank_1(index,1),  overall_runs_rank_1(index,2)];
    
    end

    % plot the final pareto front for the simulated number of GA runs
    scatter(overall_rank_1_population(:,1),  overall_rank_1_population(:,2), 20, ...
         'MarkerEdgeColor',[0 .5 .5],...
         'MarkerFaceColor',[0 .7 .7],...
         'LineWidth',0.75)
end
%----------------------------------------------------------------------------

%---------------------------------------------------------------------------
function RUN_TNK(num_runs, overall_runs_rank_1, population_size, num_generations)
    
    % define global generation tracker (for plotting purposes)
    global gen
    %declare global valriable for storing all individual objective function
    %value - used for determining pareto front
    global objective_func_value_storage

    for run = 1:num_runs
    %---------------------------- TNK PROBLEM-------------------------------
    
        nvars = 2;
        lb = [0; 0];
        ub = [pi; pi];
        
        options = optimoptions('ga');
        options = optimoptions(options,'MaxGenerations', num_generations);
        options = optimoptions(options,'CreationFcn', @gacreationuniform);
        options = optimoptions(options,'CrossoverFcn', @crossoverscattered);
        options = optimoptions(options,'MutationFcn', {  @mutationuniform [] });
        options = optimoptions(options,'Display', 'iter');
        options = optimoptions(options,'MaxStallGenerations', 40);
        options = optimoptions(options, 'PlotFcn', @gaplotbestf);
        options = optimoptions(options,'Vectorized', 'on')
        options = optimoptions(options,'PopulationSize', population_size);
    
        gen = 0;
        objective_func_value_storage = []
        
        % call the GA for the required test problem
        [~,fval] = ga(@GA_Fitness_Func_TNK,nvars,[],[],[],[],lb,ub,[],options);
        legend('Population','Best')
        
        % storage array for storing the "first rank" members of the
        % population
        rank_1_population = [];
        
        % sorts the population into fronts
        ranks = non_dominated_sort(objective_func_value_storage);

        % picks out the array indexes of the forst frint candidate
        % solutions
        rank_1_indexes = find(ranks ==1);
        
        % loops through each index and stores the objective function values
        for j = 1:length(rank_1_indexes)
            
            index = rank_1_indexes(j);
        
            rank_1_population = [rank_1_population; objective_func_value_storage(index,1), objective_func_value_storage(index,2)];
        
        end
        
        % for each GA run this stores all of the "first rank" individual
        % designs
        overall_runs_rank_1 = [overall_runs_rank_1; rank_1_population]
    
    end
    
    % storage variable for OVERALL (for all runs) "first rank" solutions
    overall_rank_1_population = [];
    
    % determines rankls and picks out the indexes of the first rank
    % individuals
    ranks = non_dominated_sort(overall_runs_rank_1);
    rank_1_indexes = find(ranks ==1);
    
    % loops through each index and adds the objective function values to
    % the above strage array - which will be plotted
    for j = 1:length(rank_1_indexes)
        
        index = rank_1_indexes(j);
    
        overall_rank_1_population = [overall_rank_1_population;  overall_runs_rank_1(index,1),  overall_runs_rank_1(index,2)];
    
    end

    % plot the final pareto front for the simulated number of GA runs
    scatter(overall_rank_1_population(:,1),  overall_rank_1_population(:,2), 20, ...
         'MarkerEdgeColor',[0 .5 .5],...
         'MarkerFaceColor',[0 .7 .7],...
         'LineWidth',0.75)
end
%----------------------------------------------------------------------------

%----------------------------------------------------------------------------
function RUN_ZDT1(num_runs, overall_runs_rank_1, population_size, num_generations)
    
    % define global generation tracker (for plotting purposes)
    global gen
    %declare global valriable for storing all individual objective function
    %value - used for determining pareto front
    global objective_func_value_storage

    for run = 1:num_runs
    %---------------------------- ZDT1 PROBLEM-------------------------------
    
        n = 30;
        fun = @(x) [x, (1 + 9/(n-1) * sum(x(2:end)) * (1 - sqrt(x/(1 + 9/(n-1) * sum(x(2:end))))))];
        lb = 0;
        ub = 1;
        nonlcon = @(x) deal([], [1 - sqrt(x(1)/(1 + 9/(n-1) * sum(x(2:end))))]);
        
        options = optimoptions('ga');
        options = optimoptions(options,'MaxGenerations', num_generations);
        options = optimoptions(options,'CreationFcn', @gacreationuniform);
        options = optimoptions(options,'CrossoverFcn', @crossoverscattered);
        options = optimoptions(options,'MutationFcn', {  @mutationuniform [] });
        options = optimoptions(options,'Display', 'iter');
        options = optimoptions(options,'MaxStallGenerations', 40);
        options = optimoptions(options, 'PlotFcn', @gaplotbestf);
        options = optimoptions(options,'Vectorized', 'on')
        options = optimoptions(options,'PopulationSize', population_size);
    
        gen = 0;
        objective_func_value_storage = []
        
        % call the GA for the required test problem
        [~,fval] = ga(@GA_Fitness_Func_ZDT1,n,[],[],[],[],lb,ub,nonlcon,options);
        legend('Population','Best')
        
        % storage array for storing the "first rank" members of the
        % population
        rank_1_population = [];
        
        % sorts the population into fronts
        ranks = non_dominated_sort(objective_func_value_storage);

        % picks out the array indexes of the forst frint candidate
        % solutions
        rank_1_indexes = find(ranks ==1);
        
        % loops through each index and stores the objective function values
        for j = 1:length(rank_1_indexes)
            
            index = rank_1_indexes(j);
        
            rank_1_population = [rank_1_population; objective_func_value_storage(index,1), objective_func_value_storage(index,2)];
        
        end
        
        % for each GA run this stores all of the "first rank" individual
        % designs
        overall_runs_rank_1 = [overall_runs_rank_1; rank_1_population]
    
    end
    
    % storage variable for OVERALL (for all runs) "first rank" solutions
    overall_rank_1_population = [];
    
    % determines rankls and picks out the indexes of the first rank
    % individuals
    ranks = non_dominated_sort(overall_runs_rank_1);
    rank_1_indexes = find(ranks ==1);
    
    % loops through each index and adds the objective function values to
    % the above strage array - which will be plotted
    for j = 1:length(rank_1_indexes)
        
        index = rank_1_indexes(j);
    
        overall_rank_1_population = [overall_rank_1_population;  overall_runs_rank_1(index,1),  overall_runs_rank_1(index,2)];
    
    end

    % plot the final pareto front for the simulated number of GA runs
    scatter(overall_rank_1_population(:,1),  overall_rank_1_population(:,2), ...
         'MarkerEdgeColor',[0 .5 .5],...
         'MarkerFaceColor',[0 .7 .7],...
         'LineWidth',1.5)
end
%----------------------------------------------------------------------------

%----------------------------------------------------------------------------
function RUN_ZDT2(num_runs, overall_runs_rank_1, population_size, num_generations)
    
    % define global generation tracker (for plotting purposes)
    global gen
    %declare global valriable for storing all individual objective function
    %value - used for determining pareto front
    global objective_func_value_storage

    for run = 1:num_runs
    %---------------------------- ZDT1 PROBLEM-------------------------------
    
        n = 30;
        fun = @(x) [x, (1 + 9/(n-1) * sum(x(2:end)) * (1 - sqrt(x/(1 + 9/(n-1) * sum(x(2:end))))))];
        lb = 0;
        ub = 1;
        nonlcon = @(x) deal([], [1 - sqrt(x(1)/(1 + 9/(n-1) * sum(x(2:end))))]);
        
        options = optimoptions('ga');
        options = optimoptions(options,'MaxGenerations', num_generations);
        options = optimoptions(options,'CreationFcn', @gacreationuniform);
        options = optimoptions(options,'CrossoverFcn', @crossoverscattered);
        options = optimoptions(options,'MutationFcn', {  @mutationuniform [] });
        options = optimoptions(options,'Display', 'iter');
        options = optimoptions(options,'MaxStallGenerations', 40);
        options = optimoptions(options, 'PlotFcn', @gaplotbestf);
        options = optimoptions(options,'Vectorized', 'on')
        options = optimoptions(options,'PopulationSize', population_size);
    
        gen = 0;
        objective_func_value_storage = []
        
        % call the GA for the required test problem
        [~,fval] = ga(@GA_Fitness_Func_ZDT2,n,[],[],[],[],lb,ub,nonlcon,options);
        legend('Population','Best')
        
        % storage array for storing the "first rank" members of the
        % population
        rank_1_population = [];
        
        % sorts the population into fronts
        ranks = non_dominated_sort(objective_func_value_storage);

        % picks out the array indexes of the forst frint candidate
        % solutions
        rank_1_indexes = find(ranks ==1);
        
        % loops through each index and stores the objective function values
        for j = 1:length(rank_1_indexes)
            
            index = rank_1_indexes(j);
        
            rank_1_population = [rank_1_population; objective_func_value_storage(index,1), objective_func_value_storage(index,2)];
        
        end
        
        % for each GA run this stores all of the "first rank" individual
        % designs
        overall_runs_rank_1 = [overall_runs_rank_1; rank_1_population]
    
    end
    
    % storage variable for OVERALL (for all runs) "first rank" solutions
    overall_rank_1_population = [];
    
    % determines rankls and picks out the indexes of the first rank
    % individuals
    ranks = non_dominated_sort(overall_runs_rank_1);
    rank_1_indexes = find(ranks ==1);
    
    % loops through each index and adds the objective function values to
    % the above strage array - which will be plotted
    for j = 1:length(rank_1_indexes)
        
        index = rank_1_indexes(j);
    
        overall_rank_1_population = [overall_rank_1_population;  overall_runs_rank_1(index,1),  overall_runs_rank_1(index,2)];
    
    end

    % plot the final pareto front for the simulated number of GA runs
    scatter(overall_rank_1_population(:,1),  overall_rank_1_population(:,2), ...
         'MarkerEdgeColor',[0 .5 .5],...
         'MarkerFaceColor',[0 .7 .7],...
         'LineWidth',1.5)
end
%----------------------------------------------------------------------------