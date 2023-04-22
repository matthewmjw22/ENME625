clc
clear all
% Declare global variable for later use

% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% GA run parameters
num_runs = 5;
population_size = 300;
num_generations = 25;
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

% color vector list:
color_vector = {[0.5 0.4 0.1]; [0.8, 0.4, 0.6]};

% CALL THE TEST PROBLEM YOU WISH TO RUN
RUN_CTP(num_runs, population_size, num_generations);

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%---------------------------------------------------------------------------
function RUN_OSY(num_runs, population_size, num_generations)
    
    % define global generation tracker (for plotting purposes)
    global gen
    %declare global valriable for storing all individual objective function
    %value - used for determining pareto front

    % define first rank (pareto front) storage vector:
    population_storage = [];

    for run = 1:num_runs
    %---------------------------- OSY PROBLEM-------------------------------
    
        nvars = 6;
        lb = [0, 0, 1, 0, 1, 0];
        ub = [10,10, 5, 6, 5, 10];
        
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
       
        % call the GA for the required test problem
        [x,fval,exitflag,output,population,score] = ga(@GA_Fitness_Func_OSY,nvars,[],[],[],[],lb,ub,[],options);
        legend('Population','Best');

        %---------------------------------------------------------
        % calculating the objectivre function values for the final
        % generation population

        % objective function value storage array:
        objective_func_value_storage = zeros(population_size,2);

        for ix = 1:size(population,1)
        
            % pluck indiovidual dsign out of the population array
            x = population(ix,:);
            
            % ---------- INITIAL OBJECTIVE FUNCTION VALUATION -------------------
        
            x1 = x(1);
            x2 = x(2);
            x3 = x(3);
            x4 = x(4);
            x5 = x(5);
            x6 = x(6);
        
            F1 = -1*((25*(x1-2)^2) + ((x2 -2)^2) + ((x3-1)^2) + ((x4-4)^2) + ((x5-1)^2)); % Min
            F2 = (x1^2) + (x2^2) + (x3^2) + (x4^2) + (x5^2) + (x6^2);  %Min
        
            % update fittness vector
            objective_func_value_storage(ix,1) = F1;
            objective_func_value_storage(ix,2) = F2;
        end

        population_storage = [population_storage; objective_func_value_storage]
        %--------------------------------------------------------
    
    end
    
     % plot the final pareto front for the simulated number of GA runs
    figure('Name','Overall Population');
    scatter(population_storage(:,1), population_storage(:,2), 5, ...
         'MarkerEdgeColor',[0 .5 .5],...
         'MarkerFaceColor',[0 .7 .7],...
         'LineWidth',0.75)

    % determines rankls and picks out the indexes of the first rank
    % individuals
    ranks = non_dominated_sort(population_storage);
    rank_1_indexes_overall = find(ranks == 1);

     % storage variable for OVERALL (for all runs) "first rank" solutions
    overall_rank_1_population = zeros(length(rank_1_indexes_overall), 2);
    
    % loops through each index and adds the objective function values to
    % the above strage array - which will be plotted
    for j = 1:length(rank_1_indexes_overall)
        
        index = rank_1_indexes_overall(j);
    
        overall_rank_1_population(j,1) = population_storage(index,1);
        overall_rank_1_population(j,2) = population_storage(index,2);
    
    end

    % plot the final pareto front for the simulated number of GA runs
    figure('Name','Pareto Front');
    scatter(overall_rank_1_population(:,1),  overall_rank_1_population(:,2), 15, ...
         'MarkerEdgeColor',[0 .5 .5],...
         'MarkerFaceColor',[0 .7 .7],...
         'LineWidth',0.75)
        xlim([-300 0])
        ylim([0 80])
end
%----------------------------------------------------------------------------

%---------------------------------------------------------------------------
function RUN_CTP(num_runs, population_size, num_generations)
    
    % define global generation tracker (for plotting purposes)
    global gen

    % define first rank (pareto front) storage vector:
    population_storage = [];

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
       
        % call the GA for the required test problem
        [x,fval,exitflag,output,population,score] = ga(@GA_Fitness_Func_CTP,nvars,[],[],[],[],lb,ub,[],options);
        legend('Population','Best');

        %---------------------------------------------------------
        % calculating the objectivre function values for the final
        % generation population

        % objective function value storage array:
        objective_func_value_storage = zeros(population_size,2);

        for ix = 1:size(population,1)
        
            x = population(ix,:);
        
        % ---------- INITIAL OBJECTIVE FUNCTION VALUATION -------------------
    
            x1 = x(1);
            x2 = x(2);
            x3 = x(3);
            x4 = x(4);
            x5 = x(5);
            x6 = x(6);
            x7 = x(7);
            x8 = x(8);
            x9 = x(9);
            x10 = x(10);
        
        
            F1 = x1;
            F2 = abs((1 + (x2+x3+x4+x5+x6+x7+x8+x9+x10)^.25))*(1 - sqrt(x1/(abs((1 + (x2+x3+x4+x5+x6+x7+x8+x9+x10)^.25)))));
        
            % update fittness vector
            objective_func_value_storage(ix,1) = F1;
            objective_func_value_storage(ix,2) = F2;
        end

        population_storage = [population_storage; objective_func_value_storage]
        %--------------------------------------------------------
    
    end
    
     % plot the final pareto front for the simulated number of GA runs
    figure('Name','Overall Population');
    scatter(population_storage(:,1), population_storage(:,2), 5, ...
         'MarkerEdgeColor',[0 .5 .5],...
         'MarkerFaceColor',[0 .7 .7],...
         'LineWidth',0.75)
    
    % determines rankls and picks out the indexes of the first rank
    % individuals
    ranks = non_dominated_sort(population_storage);
    rank_1_indexes_overall = find(ranks == 1);

     % storage variable for OVERALL (for all runs) "first rank" solutions
    overall_rank_1_population = zeros(length(rank_1_indexes_overall), 2);
    
    % loops through each index and adds the objective function values to
    % the above strage array - which will be plotted
    for j = 1:length(rank_1_indexes_overall)
        
        index = rank_1_indexes_overall(j);
    
        overall_rank_1_population(j,1) = population_storage(index,1);
        overall_rank_1_population(j,2) = population_storage(index,2);
    
    end

    % plot the final pareto front for the simulated number of GA runs
    figure('Name','Pareto Front');
    scatter(overall_rank_1_population(:,1),  overall_rank_1_population(:,2), 15, ...
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
        objective_func_value_storage = [];
        
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

         % plot the final pareto front for the simulated number of GA runs
        scatter(overall_runs_rank_1(:,1), overall_runs_rank_1(:,2), ...
         'MarkerEdgeColor',[0 .5 .5],...
         'MarkerFaceColor',[0 .7 .7],...
         'LineWidth',1.5)
    
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
    %---------------------------- ZDT2 PROBLEM-------------------------------
    
        nvars = 30;
        lb = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
        ub = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];
        
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
        [~,fval] = ga(@GA_Fitness_Func_ZDT2,nvars,[],[],[],[],lb,ub,[],options);
        legend('Population','Best')
        
        % storage array for storing the "first rank" members of the
        % population
        rank_1_population = [];
        
        % sorts the population into fronts
        ranks = non_dominated_sort(objective_func_value_storage)

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
        overall_runs_rank_1 = [overall_runs_rank_1; rank_1_population];

         % plot the run's first rank front
        scatter(overall_runs_rank_1(:,1), overall_runs_rank_1(:,2), ...
         'MarkerEdgeColor',[0 .5 .5],...
         'MarkerFaceColor',[0 .7 .7],...
         'LineWidth',1.5)
    
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
         'LineWidth',1.5) 

end
%----------------------------------------------------------------------------

%----------------------------------------------------------------------------
function RUN_ZDT3(num_runs, population_size, num_generations)
    
    % define global generation tracker (for plotting purposes)
    global gen
    %declare global valriable for storing all individual objective function
    %value - used for determining pareto front
    global objective_func_value_storage

     % define first rank (pareto front) storage vector:
    overall_runs_rank_1 = [];

    for run = 1:num_runs
    %---------------------------- ZDT1 PROBLEM-------------------------------
    
       nvars = 30;
        lb = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
        ub = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];
        
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
        [~,fval] = ga(@GA_Fitness_Func_ZDT3,nvars,[],[],[],[],lb,ub,[],options);
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