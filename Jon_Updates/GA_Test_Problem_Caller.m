clc
clear all
close all

% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% FUNCTION LIBRARY

% TEST PROBLEM ---------> FUNCTION TO CALL
%******************************************************************
%    OSY       ---------> RUN_OSY(15, 250, 120);
%    CTP       ---------> RUN_CTP(15, 250, 120);
%    TNK       ---------> RUN_TNK(15, 250, 120);
%   ZDT1       ---------> RUN_ZDT1(15, 400, 120);
%   ZDT2       ---------> RUN_ZDT2(15, 400, 120);
%   ZDT3       ---------> RUN_ZDT3(15, 400, 120);
%   TNK MORO   ---------> RUN_TNK_MORO(15, 600, 120);
%******************************************************************

%##########################################################################
% CALL THE TEST PROBLEM YOU WISH TO RUN
% ENTER THE PROBLEM DESIGNATOR AFTER RUN_
RUN_OSY(12, 250, 120);
%##########################################################################

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%---------------------------------------------------------------------------
function RUN_OSY(num_runs, population_size, num_generations)
    
    % define global generation tracker (for plotting purposes)
    global gen
    %declare global valriable for storing all individual objective function
    %value - used for determining pareto front

    % define first rank (pareto front) storage vector:
    population_storage = [];

    % Create the waitbar
    h = waitbar(0, 'Determining Pareto Front...');

    %create figure for stochastic element plotting
    figure('Name', 'Each GA Run Non Dominant Set');

    % initilize counter for determining # of pareto points per function
    % call metric
    num_function_calls = 0;

    %initizlize quality metric storage arrays
    % these arrays will store each GA run's quality metrics for future
    % analysis
    pareto_spread_storage = zeros(num_runs,1);
    cluster_storage = zeros(num_runs,1);


    for run = 1:num_runs
    %---------------------------- OSY PROBLEM-------------------------------
    
        nvars = 6;
        lb = [0, 0, 1, 0, 1, 0];
        ub = [10,10, 5, 6, 5, 10];
        
        options = optimoptions('ga');
        options = optimoptions(options,'MaxGenerations', num_generations);
        options = optimoptions(options,'EliteCount', ceil(0.85*population_size))
        options = optimoptions(options,'CreationFcn', @gacreationuniform);
        options = optimoptions(options,'CrossoverFcn', @crossoverscattered);
        options = optimoptions(options,'MutationFcn', {  @mutationadaptfeasible [] });
        %options = optimoptions(options,'Display', 'iter');
        options = optimoptions(options,'MaxStallGenerations', 40);
        %options = optimoptions(options, 'PlotFcn', @gaplotbestf);
        options = optimoptions(options,'Vectorized', 'on')
        options = optimoptions(options,'PopulationSize', population_size);
    
        gen = 0;
       
        % call the GA for the required test problem
        [x,fval,exitflag,output,population,score] = ga(@GA_Fitness_Func_OSY,nvars,[],[],[],[],lb,ub,[],options);

        % Extract the number of function evaluations from the output structure
        num_function_calls = num_function_calls + output.funccount;

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

        % CONSTRAINT HANDELING
        % define empty array for storing constrain values:
        constrained_fitness = zeros(size(population,1),2);
    
        for ix = 1:size(population,1)
        
            % pluck indiovidual dsign out of the population array
            x = population(ix,:);
        
            x1 = x(1);
            x2 = x(2);
            x3 = x(3);
            x4 = x(4);
            x5 = x(5);
            x6 = x(6);
            
            C = [zeros(6,1)];
            C(1) = 1 - (x1+x2)/2;
            C(2) = ((x1 + x2)/6) - 1;
            C(3) =(x2-x1)/2 - 1;
            C(4) = (x1 - 3*x2)/2 -1;
            C(5) =(((x3-3)^2 + x4)/4) -1;
            C(6) = 1 - ((x5 - 3)^2 + x6)/4;
            Ceq = [];

             % initilize constraint violation value = 0
            total_violation = 0;
        
            for z = 1:length(C)
        
                if C(z) > 0
        
                    total_violation = total_violation + C(z);

                elseif isnan(C(z))

                    total_violation = total_violation + 100000;
       
                end 
        
            end
    
            constrained_fitness(ix,1) = objective_func_value_storage(ix,1) + (total_violation * 1000);
            constrained_fitness(ix,2) = objective_func_value_storage(ix,2) + (total_violation * 1000);
        end

        population_storage = [population_storage; constrained_fitness];

        %*****************************************************************************************
        %% PLOTS THE FIRST FRONT FOR EACH RUN - HIGHLIGHTS STOCHASTIC EFFECTS
        % determines ranks and picks out the indexes of the first rank
        % individuals
        ranks = non_dominated_sort(constrained_fitness);
        rank_1_indexes_overall = find(ranks == 1);
    
         % storage variable for OVERALL (for all runs) "first rank" solutions
        overall_rank_1_population = zeros(length(rank_1_indexes_overall), 2);
        
        % loops through each index and adds the objective function values to
        % the above storage array - which will be plotted
        for j = 1:length(rank_1_indexes_overall)
            
            index = rank_1_indexes_overall(j);
        
            overall_rank_1_population(j,1) = constrained_fitness(index,1);
            overall_rank_1_population(j,2) = constrained_fitness(index,2);
        
        end

        %% calculate the quality metrics for this instance (GA run) first
        % front non-dominated set
        % Pareto Spread

        normalization_factor = 20147;

        pareto_spread_storage(run,1) = Pareto_Spread(overall_rank_1_population)/normalization_factor;
    
        % cluster metric
        cluster_storage(run,1) = cluster(overall_rank_1_population, 200);
    
        %% Plot the GA-Run's Non-Dominated Set
        % Plot the points
        plot(overall_rank_1_population(:,1),  overall_rank_1_population(:,2), '*');
    
        % Keep the current plot active
        hold on;
        %***************************************************************************************

       % Update the waitbar
        progress = run / num_runs;
        waitbar(progress, h, sprintf('GA Run Number: %d/%d  |  Progress: %.1f%%', run, num_runs, progress * 100));
    
    end

    % Close the waitbar
    close(h);
    

    %% Determine the Final Pareto Front from the population
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

    % remove duplicate points from the pareto front array
    overall_rank_1_population = unique(overall_rank_1_population,'rows');

    %% ADD THE FINAL PARETO SET TO THE PLOT OF ALL THE DIFFERENT DOMINANT SETS
    % Turn off the hold to stop adding new plots to the current figure
    scatter(overall_rank_1_population(:,1),  overall_rank_1_population(:,2), 20, ...
         'MarkerFaceColor',[0.5 ,.8, 0.2],...
         'MarkerEdgeColor',[0.5, 0.8, 0.2],...
         'LineWidth',0.75)

    % Add labels and title (optional)
    xlabel('Objective 1');
    ylabel('Objective 2');
    title('Dominant Solution Set From Each GA Run');
    
    % Display the legend (optional)
    legend_str = arrayfun(@(i) sprintf('GA Run %d', i), 1:num_runs, 'UniformOutput', false);
    final_element = 'Pareto Set';
    legend_str = [legend_str, final_element];
    legend(legend_str);

    hold off;
    %% Plot the Final Pareto Set
    % plot the final pareto front for the simulated number of GA runs
    figure('Name','Pareto Front');
    scatter(overall_rank_1_population(:,1),  overall_rank_1_population(:,2), 15, ...
         'MarkerEdgeColor',[0 .5 .5],...
         'MarkerFaceColor',[0 .7 .7],...
         'LineWidth',0.75)
    title('OSY Problem Pareto Front')
    xlabel('Objective 1') 
    ylabel('Objective 2') 

    % plot pareto additons for each sucessive GA run:
    % Calculate the number of points per group
    points_per_group = size(overall_rank_1_population, 1) / num_runs;
    
    % Set up a figure
    figure('Name','Pareto Front By GA Run');
    
    % Create a colormap
    colors = jet(num_runs);
    
    % Initialize the legend entries
    legend_entries = cell(num_runs, 1);
    
    % Plot the points with different colors
    hold on;
    for i = 1:num_runs
        % Calculate the indices for the current group
        start_idx = (i - 1) * points_per_group + 1;
        end_idx = i * points_per_group;
        
        % Extract the current group of points
        group = overall_rank_1_population(start_idx:end_idx, :);
        
        % Plot the current group with its corresponding color
        plot(group(:, 1), group(:, 2), '.', 'Color', colors(i, :), 'MarkerSize', 15);
        
        % Update the legend entry for the current group
        legend_entries{i} = sprintf('GA run %d', i);
    end
    
    % Customize the plot (optional)
    title('Pareto Front Additions by GA Run Instance');
    xlabel('Objective 1');
    ylabel('Objective');
    legend(legend_entries);
    grid on;
    
    % Display the plot
    hold off;

    %% Plot the statistics for the independent GA run quality metrics

    figure('Name', 'Quality Metric Box and Whiskers Plot');
    % Create a box and whiskers plot using the grouping variable
    boxplot([pareto_spread_storage,cluster_storage],'Notch','on','Labels',{'Pareto Spread','Cluster'})
    
    % Add labels and a title
    xlabel('Groups');
    ylabel('Values');
    title('Box and Whiskers Plot');

    %% calculate the qaulity metrics for the final Pareto front

    % Pareto Spread
    pareto_spread = Pareto_Spread(overall_rank_1_population);
    
    % cluster metric
    clus = cluster(overall_rank_1_population, 200);

    % number of function calls per pareto point
    calls_per_pareto =  ceil(num_function_calls / length(overall_rank_1_population)); 

    % Initialize an array to store the distances
    distances = zeros(size(overall_rank_1_population, 1), 1);
    
    % Loop through each point and calculate the distance
    for i = 1:size(overall_rank_1_population, 1)
        distances(i) = norm(overall_rank_1_population(i, :) - [-300 0]);
    end
    
    % Calculate the mean and standard deviation of the distances
    mean_distance = mean(distances);
    std_distance = std(distances);
    
    % Print out the results
    fprintf('Mean distance: %.2f\n', mean_distance);
    fprintf('Standard deviation of distances: %.2f\n', std_distance);

     table_data = {
                    
                 'Number of Pareto Points', length(overall_rank_1_population);
                 'Pareto Spread', pareto_spread;
                 ' cluster metric', clus
                 'function calls per pareto point', calls_per_pareto
        
                 }

    % Create a figure
    fig = figure('Name', 'Problem Data');

    % Create a table in the figure
    uitable(fig, 'Data', table_data);

end
%----------------------------------------------------------------------------

%---------------------------------------------------------------------------
function RUN_CTP(num_runs, population_size, num_generations)
    
    % define global generation tracker (for plotting purposes)
    global gen

    % define first rank (pareto front) storage vector:
    population_storage = [];

    %create figure for stochastic element plotting
    figure;

    % Create the waitbar
    h = waitbar(0, 'Determining Pareto Front...');

    % initilize counter for determining # of pareto points per function
    % call metric
    num_function_calls = 0;

    %initizlize quality metric storage arrays
    % these arrays will store each GA run's quality metrics for future
    % analysis
    pareto_spread_storage = zeros(num_runs,1);
    cluster_storage = zeros(num_runs,1);

    for run = 1:num_runs
    %---------------------------- CTP PROBLEM-------------------------------
    
        nvars = 10;
        lb = [0; -5; -5; -5; -5; -5; -5; -5; -5; -5];
        ub = [1; 5; 5; 5; 5; 5; 5; 5; 5; 5];
        
       options = optimoptions('ga');
        options = optimoptions(options,'MaxGenerations', num_generations);
        options = optimoptions(options,'CreationFcn', @gacreationuniform);
        options = optimoptions(options,'EliteCount', ceil(0.85*population_size));
        options = optimoptions(options,'CrossoverFcn', @crossoverscattered);
        options = optimoptions(options,'MutationFcn', {  @mutationadaptfeasible [] });
        options = optimoptions(options,'Display', 'iter');
        options = optimoptions(options,'MaxStallGenerations', 40);
        %options = optimoptions(options, 'PlotFcn', @gaplotbestf);
        options = optimoptions(options,'Vectorized', 'on')
        options = optimoptions(options,'PopulationSize', population_size);
    
        gen = 0;
       
        % call the GA for the required test problem
        [x,fval,exitflag,output,population,score] = ga(@GA_Fitness_Func_CTP,nvars,[],[],[],[],lb,ub,[],options);

        % Extract the number of function evaluations from the output structure
        num_function_calls = num_function_calls + output.funccount;

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

        % CONSTRAINT HANDELING
        % define empty array for storing constrain values:
        constrained_fitness = zeros(size(population,1),2);
    
        for ix = 1:size(population,1)
        
           % pluck indiovidual dsign out of the population array
            x = population(ix,:);
        
            C = [zeros(1,1)];
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
        
            C(1) = -(cos(-.2*pi)*(abs((1 + (x2+x3+x4+x5+x6+x7+x8+x9+x10)^.25))*(1 - sqrt(x1/(abs((1 + (x2+x3+x4+x5+x6+x7+x8+x9+x10)^.25))))) -1) - sin(-.2*pi)*x1    -     0.2*abs(sin(10*pi*(sin(-.2*pi)*(abs(1 + (x2+x3+x4+x5+x6+x7+x8+x9+x10)^.25) -1) + cos(-.2*pi)*x1)^1))^6);                      
            Ceq = [];

             % initilize constraint violation value = 0
            total_violation = 0;
        
            for z = 1:length(C)
        
                if C(z) > 0
        
                    total_violation = total_violation + C(z);

                elseif isnan(C(z))

                    total_violation = total_violation + 1000;
       
                end 
        
            end
    
            constrained_fitness(ix,1) = objective_func_value_storage(ix,1) + (total_violation * 1000);
            constrained_fitness(ix,2) = objective_func_value_storage(ix,2) + (total_violation * 1000);
        end

        population_storage = [population_storage; constrained_fitness];
     
        %*****************************************************************************************
        %% PLOTS THE FIRST FRONT FOR EACH RUN - HIGHLIGHTS STOCHASTIC
        % EFFECTS
        % determines rankls and picks out the indexes of the first rank
        % individuals
        ranks = non_dominated_sort(constrained_fitness)
        rank_1_indexes_overall = find(ranks == 1);
    
         % storage variable for OVERALL (for all runs) "first rank" solutions
        overall_rank_1_population = zeros(length(rank_1_indexes_overall), 2);
        
        % loops through each index and adds the objective function values to
        % the above strage array - which will be plotted
        for j = 1:length(rank_1_indexes_overall)
            
            index = rank_1_indexes_overall(j);
        
            overall_rank_1_population(j,1) = constrained_fitness(index,1);
            overall_rank_1_population(j,2) = constrained_fitness(index,2);
        
        end

        %% calculate the quality metrics for this instance (GA run) first
        % front non-dominated set
        % Pareto Spread

        normalization_factor = 1.7409;

        pareto_spread_storage(run,1) = Pareto_Spread(overall_rank_1_population)/normalization_factor;
    
        % cluster metric
        cluster_storage(run,1) = cluster(overall_rank_1_population, 200);
    
        %% Plot the GA-Run's Non-Dominated Set
    
         % Plot the points
        plot(overall_rank_1_population(:,1),  overall_rank_1_population(:,2), '*');
    
        % Keep the current plot active
        hold on;
        %***************************************************************************************

       % Update the waitbar
        progress = run / num_runs;
        waitbar(progress, h, sprintf('GA Run Number: %d/%d  |  Progress: %.1f%%', run, num_runs, progress * 100));
    
    end

    % Close the waitbar
    close(h);
    

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

    % remove duplicate points from the pareto front array
    overall_rank_1_population = unique(overall_rank_1_population,'rows');

    %% ADD THE FINAL PARETO SET TO THE PLOT OF ALL THE DIFFERENT DOMINANT SETS
    % Turn off the hold to stop adding new plots to the current figure
    scatter(overall_rank_1_population(:,1),  overall_rank_1_population(:,2), 20, ...
         'MarkerFaceColor',[0.5 ,.8, 0.2],...
         'MarkerEdgeColor',[0.5, 0.8, 0.2],...
         'LineWidth',0.75)

    % Add labels and title (optional)
    xlabel('Objective 1');
    ylabel('Objective 2');
    title('Dominant Solution Set From Each GA Run');
    
    % Display the legend (optional)
    legend_str = arrayfun(@(i) sprintf('GA Run %d', i), 1:num_runs, 'UniformOutput', false);
    final_element = 'Pareto Set';
    legend_str = [legend_str, final_element];
    legend(legend_str);

    hold off;
    %% Plot the Final Pareto Set

    % plot the final pareto front for the simulated number of GA runs
    figure('Name','Pareto Front');
    scatter(overall_rank_1_population(:,1),  overall_rank_1_population(:,2), 15, ...
         'MarkerEdgeColor',[0 .5 .5],...
         'MarkerFaceColor',[0 .7 .7],...
         'LineWidth',0.75)
    title('CTP Problem Pareto Front')
    xlabel('Objective 1') 
    ylabel('Objective 2') 

    % plot pareto additons for each sucessive GA run:
    % Calculate the number of points per group
    points_per_group = size(overall_rank_1_population, 1) / num_runs;
    
    % Set up a figure
    figure('Name','Pareto Front By GA Run');
    
    % Create a colormap
    colors = jet(num_runs);
    
    % Initialize the legend entries
    legend_entries = cell(num_runs, 1);
    
    % Plot the points with different colors
    hold on;
    for i = 1:num_runs
        % Calculate the indices for the current group
        start_idx = (i - 1) * points_per_group + 1;
        end_idx = i * points_per_group;
        
        % Extract the current group of points
        group = overall_rank_1_population(start_idx:end_idx, :);
        
        % Plot the current group with its corresponding color
        plot(group(:, 1), group(:, 2), '.', 'Color', colors(i, :), 'MarkerSize', 15);
        
        % Update the legend entry for the current group
        legend_entries{i} = sprintf('GA run %d', i);
    end
    
    % Customize the plot (optional)
    title('Pareto Front Additions by GA Run Instance');
    xlabel('Objective 1');
    ylabel('Objective');
    legend(legend_entries);
    grid on;
    
    % Display the plot
    hold off;

    %% Plot the statistics for the independent GA run quality metrics

    figure('Name', 'Quality Metric Box and Whiskers Plot');
    % Create a box and whiskers plot using the grouping variable
    boxplot([pareto_spread_storage,cluster_storage],'Notch','on','Labels',{'Pareto Spread','Cluster'})
    
    % Add labels and a title
    xlabel('Groups');
    ylabel('Values');
    title('Box and Whiskers Plot');

    %% calculate the qaulity metrics for the final Pareto front

    % Pareto Spread
    pareto_spread = Pareto_Spread(overall_rank_1_population);
    
    % cluster metric
    clus = cluster(overall_rank_1_population, 200);

    % number of function calls per pareto point
    calls_per_pareto =  ceil(num_function_calls / length(overall_rank_1_population)); 

    % Initialize an array to store the distances
    distances = zeros(size(overall_rank_1_population, 1), 1);
    
    % Loop through each point and calculate the distance
    for i = 1:size(overall_rank_1_population, 1)
        distances(i) = norm(overall_rank_1_population(i, :) - [-300 0]);
    end
    
    % Calculate the mean and standard deviation of the distances
    mean_distance = mean(distances);
    std_distance = std(distances);
    
    % Print out the results
    fprintf('Mean distance: %.2f\n', mean_distance);
    fprintf('Standard deviation of distances: %.2f\n', std_distance);

     table_data = {
                    
                 'Number of Pareto Points', length(overall_rank_1_population);
                 'Pareto Spread', pareto_spread;
                 ' cluster metric', clus
                 'function calls per pareto point', calls_per_pareto
        
                 }

    % Create a figure
    fig = figure('Name', 'Problem Data');

    % Create a table in the figure
    uitable(fig, 'Data', table_data);

end
%----------------------------------------------------------------------------

%---------------------------------------------------------------------------
function RUN_TNK(num_runs, population_size, num_generations)
    
    % define global generation tracker (for plotting purposes)
    global gen

    % define first rank (pareto front) storage vector:
    population_storage = [];

    %create figure for stochastic element plotting
    figure;

    % Create the waitbar
    h = waitbar(0, 'Determining Pareto Front...');

    % initilize counter for determining # of pareto points per function
    % call metric
    num_function_calls = 0;

    %initizlize quality metric storage arrays
    % these arrays will store each GA run's quality metrics for future
    % analysis
    pareto_spread_storage = zeros(num_runs,1);
    cluster_storage = zeros(num_runs,1);

    for run = 1:num_runs
    %---------------------------- TNK PROBLEM-------------------------------
    
        nvars = 2;
        lb = [0, 0];
        ub = [pi, pi];
        
        options = optimoptions('ga');
        options = optimoptions(options,'MaxGenerations', num_generations);
        options = optimoptions(options,'CreationFcn', @gacreationuniform);
        options = optimoptions(options,'EliteCount', ceil(0.85*population_size));
        options = optimoptions(options,'CrossoverFcn', @crossoverscattered);
        options = optimoptions(options,'MutationFcn', {  @mutationadaptfeasible [] });
        options = optimoptions(options,'Display', 'iter');
        options = optimoptions(options,'MaxStallGenerations', 40);
        %options = optimoptions(options, 'PlotFcn', @gaplotbestf);
        options = optimoptions(options,'Vectorized', 'on')
        options = optimoptions(options,'PopulationSize', population_size);
    
        gen = 0;
       
        % call the GA for the required test problem
        [x,fval,exitflag,output,population,score] = ga(@GA_Fitness_Func_TNK,nvars,[],[],[],[],lb,ub,[],options);

        % Extract the number of function evaluations from the output structure
        num_function_calls = num_function_calls + output.funccount;


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
    
            F1 = x1; % Min
            F2 = x2;  %Min
        
            % update fittness vector
            objective_func_value_storage(ix,1) = F1;
            objective_func_value_storage(ix,2) = F2;
        end

        % CONSTRAINT HANDELING
        % define empty array for storing constrain values:
        constrained_fitness = zeros(size(population,1),2);
    
        for ix = 1:size(population,1)
        
            % pluck indiovidual dsign out of the population array
            x = population(ix,:);
        
            x1 = x(1);
            x2 = x(2);
    
            C = [zeros(2,1)];
            C(1) = -1*(x1^2 + x2^2 -1 - 0.1*cos(16*atan(x1/x2)));
            C(2) = (x1 - 0.5)^2 + (x2 - 0.5)^2 -0.5;
    
            Ceq = [];
        
             % initilize constraint violation value = 0
            total_violation = 0;
        
            for z = 1:length(C)
        
                if C(z) > 0
        
                    total_violation = total_violation + C(z);

                elseif isnan(C(z))

                    total_violation = total_violation + 1000;
       
                end 
        
            end
    
            constrained_fitness(ix,1) = objective_func_value_storage(ix,1) + (total_violation * 1000);
            constrained_fitness(ix,2) = objective_func_value_storage(ix,2) + (total_violation * 1000);
        end

        population_storage = [population_storage; constrained_fitness];
        %*****************************************************************************************
        %% PLOTS THE FIRST FRONT FOR EACH RUN - HIGHLIGHTS STOCHASTIC
        % EFFECTS
        % determines rankls and picks out the indexes of the first rank
        % individuals
        ranks = non_dominated_sort(constrained_fitness)
        rank_1_indexes_overall = find(ranks == 1);
    
         % storage variable for OVERALL (for all runs) "first rank" solutions
        overall_rank_1_population = zeros(length(rank_1_indexes_overall), 2);
        
        % loops through each index and adds the objective function values to
        % the above strage array - which will be plotted
        for j = 1:length(rank_1_indexes_overall)
            
            index = rank_1_indexes_overall(j);
        
            overall_rank_1_population(j,1) = constrained_fitness(index,1);
            overall_rank_1_population(j,2) = constrained_fitness(index,2);
        
        end

        %% calculate the quality metrics for this instance (GA run) first
        % front non-dominated set
        % Pareto Spread

        normalization_factor = 1.0173;

        pareto_spread_storage(run,1) = Pareto_Spread(overall_rank_1_population)/normalization_factor;
    
        % cluster metric
        cluster_storage(run,1) = cluster(overall_rank_1_population, 200);
    
        %% Plot the GA-Run's Non-Dominated Set
    
         % Plot the points
        plot(overall_rank_1_population(:,1),  overall_rank_1_population(:,2), '*');
    
        % Keep the current plot active
        hold on;
        %***************************************************************************************

       % Update the waitbar
        progress = run / num_runs;
        waitbar(progress, h, sprintf('GA Run Number: %d/%d  |  Progress: %.1f%%', run, num_runs, progress * 100));
    
    end
    

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

    % Close the waitbar
    close(h);

    % remove duplicate points from the pareto front array
    overall_rank_1_population = unique(overall_rank_1_population,'rows');

    %% ADD THE FINAL PARETO SET TO THE PLOT OF ALL THE DIFFERENT DOMINANT SETS
    % Turn off the hold to stop adding new plots to the current figure
    scatter(overall_rank_1_population(:,1),  overall_rank_1_population(:,2), 20, ...
         'MarkerFaceColor',[0.5 ,.8, 0.2],...
         'MarkerEdgeColor',[0.5, 0.8, 0.2],...
         'LineWidth',0.75)

    % Add labels and title (optional)
    xlabel('Objective 1');
    ylabel('Objective 2');
    title('Dominant Solution Set From Each GA Run');
    
    % Display the legend (optional)
    legend_str = arrayfun(@(i) sprintf('GA Run %d', i), 1:num_runs, 'UniformOutput', false);
    final_element = 'Pareto Set';
    legend_str = [legend_str, final_element];
    legend(legend_str);

    hold off;
    %% Plot the Final Pareto Set

    % plot the final pareto front for the simulated number of GA runs
    figure('Name','Pareto Front');
    scatter(overall_rank_1_population(:,1),  overall_rank_1_population(:,2), 15, ...
         'MarkerEdgeColor',[0 .5 .5],...
         'MarkerFaceColor',[0 .7 .7],...
         'LineWidth',0.75)
    title('TNK Problem Pareto Front')
    xlabel('Objective 1') 
    ylabel('Objective 2') 

    % plot pareto additons for each sucessive GA run:
    % Calculate the number of points per group
    points_per_group = size(overall_rank_1_population, 1) / num_runs;
    
    % Set up a figure
    figure;
    
    % Create a colormap
    colors = jet(num_runs);
    
    % Initialize the legend entries
    legend_entries = cell(num_runs, 1);
    
    % Plot the points with different colors
    hold on;
    for i = 1:num_runs
        % Calculate the indices for the current group
        start_idx = (i - 1) * points_per_group + 1;
        end_idx = i * points_per_group;
        
        % Extract the current group of points
        group = overall_rank_1_population(start_idx:end_idx, :);
        
        % Plot the current group with its corresponding color
        plot(group(:, 1), group(:, 2), '.', 'Color', colors(i, :), 'MarkerSize', 15);
        
        % Update the legend entry for the current group
        legend_entries{i} = sprintf('GA run %d', i);
    end
    
    % Customize the plot (optional)
    title('Pareto Front Additions by GA Run Instance');
    xlabel('Objective 1');
    ylabel('Objective');
    legend(legend_entries);
    grid on;
    
    % Display the plot
    hold off;

    %% Plot the statistics for the independent GA run quality metrics

    figure('Name', 'Quality Metric Box and Whiskers Plot');
    % Create a box and whiskers plot using the grouping variable
    boxplot([pareto_spread_storage,cluster_storage],'Notch','on','Labels',{'Pareto Spread','Cluster'})
    
    % Add labels and a title
    xlabel('Groups');
    ylabel('Values');
    title('Box and Whiskers Plot');

    %% calculate the qaulity metrics for the final Pareto front

    % Pareto Spread
    pareto_spread = Pareto_Spread(overall_rank_1_population);
    
    % cluster metric
    clus = cluster(overall_rank_1_population, 200);

    % number of function calls per pareto point
    calls_per_pareto =  ceil(num_function_calls / length(overall_rank_1_population)); 

    % Initialize an array to store the distances
    distances = zeros(size(overall_rank_1_population, 1), 1);
    
    % Loop through each point and calculate the distance
    for i = 1:size(overall_rank_1_population, 1)
        distances(i) = norm(overall_rank_1_population(i, :) - [-300 0]);
    end
    
    % Calculate the mean and standard deviation of the distances
    mean_distance = mean(distances);
    std_distance = std(distances);
    
    % Print out the results
    fprintf('Mean distance: %.2f\n', mean_distance);
    fprintf('Standard deviation of distances: %.2f\n', std_distance);

     table_data = {
                    
                 'Number of Pareto Points', length(overall_rank_1_population);
                 'Pareto Spread', pareto_spread;
                 ' cluster metric', clus
                 'function calls per pareto point', calls_per_pareto
        
                 }

    % Create a figure
    fig = figure('Name', 'Problem Data');

    % Create a table in the figure
    uitable(fig, 'Data', table_data);

end
%----------------------------------------------------------------------------

%----------------------------------------------------------------------------
function RUN_ZDT1(num_runs, population_size, num_generations)
    
    % define global generation tracker (for plotting purposes)
    global gen

    % define first rank (pareto front) storage vector:
    population_storage = [];

    %create figure for stochastic element plotting
    figure;

    % Create the waitbar
    h = waitbar(0, 'Determining Pareto Front...');

    % initilize counter for determining # of pareto points per function
    % call metric
    num_function_calls = 0;

    %initizlize quality metric storage arrays
    % these arrays will store each GA run's quality metrics for future
    % analysis
    pareto_spread_storage = zeros(num_runs,1);
    cluster_storage = zeros(num_runs,1);

    for run = 1:num_runs
    %---------------------------- ZDT1 PROBLEM-------------------------------
    
        nvars = 30;
        lb = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
        ub = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];
        
        options = optimoptions('ga');
        options = optimoptions(options,'MaxGenerations', num_generations);
        options = optimoptions(options,'CreationFcn', @gacreationuniform);
        options = optimoptions(options,'CrossoverFcn', @crossoverscattered);
        %options = optimoptions(options,'EliteCount', ceil(0.85*population_size));
        options = optimoptions(options,'MutationFcn', {  @mutationuniform [] });
        options = optimoptions(options,'Display', 'iter');
        options = optimoptions(options,'MaxStallGenerations', 40);
        %options = optimoptions(options, 'PlotFcn', @gaplotbestf);
        options = optimoptions(options,'Vectorized', 'on')
        options = optimoptions(options,'PopulationSize', population_size);
    
        gen = 0;
        
        % call the GA for the required test problem
        [x,fval,exitflag,output,population,score] = ga(@GA_Fitness_Func_ZDT1,nvars,[],[],[],[],lb,ub,[],options);
        %legend('Population','Best');

        % Extract the number of function evaluations from the output structure
        num_function_calls = num_function_calls + output.funccount;


        %---------------------------------------------------------
        % calculating the objectivre function values for the final
        % generation population

        % objective function value storage array:
        objective_func_value_storage = zeros(population_size,2);

        for ix = 1:size(population,1)
        
            % pluck indiovidual dsign out of the population array
            Input = population(ix,:);
    
            % ---------- INITIAL OBJECTIVE FUNCTION VALUATION -------------------
        
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
            F2 = (1 - sqrt(x1/g))*g;  %Min
        
            % update fittness vector
            objective_func_value_storage(ix,1) = F1;
            objective_func_value_storage(ix,2) = F2;

        end

        population_storage = [population_storage; objective_func_value_storage]
        %*****************************************************************************************
        %% PLOTS THE FIRST FRONT FOR EACH RUN - HIGHLIGHTS STOCHASTIC
        % EFFECTS
        % determines rankls and picks out the indexes of the first rank
        % individuals
        ranks = non_dominated_sort(objective_func_value_storage)
        rank_1_indexes_overall = find(ranks == 1);
    
         % storage variable for OVERALL (for all runs) "first rank" solutions
        overall_rank_1_population = zeros(length(rank_1_indexes_overall), 2);
        
        % loops through each index and adds the objective function values to
        % the above strage array - which will be plotted
        for j = 1:length(rank_1_indexes_overall)
            
            index = rank_1_indexes_overall(j);
        
            overall_rank_1_population(j,1) = objective_func_value_storage(index,1);
            overall_rank_1_population(j,2) = objective_func_value_storage(index,2);
        
        end

        %% calculate the quality metrics for this instance (GA run) first
        % front non-dominated set
        % Pareto Spread

        normalization_factor = 2.6349;

        pareto_spread_storage(run,1) = Pareto_Spread(overall_rank_1_population)/normalization_factor;
    
        % cluster metric
        cluster_storage(run,1) = cluster(overall_rank_1_population, 200);
    
        %% Plot the GA-Run's Non-Dominated Set
    
         % Plot the points
        plot(overall_rank_1_population(:,1),  overall_rank_1_population(:,2), '*');
    
        % Keep the current plot active
        hold on;
        %***************************************************************************************

        % Update the waitbar
        progress = run / num_runs;
        waitbar(progress, h, sprintf('GA Run Number: %d/%d  |  Progress: %.1f%%', run, num_runs, progress * 100));
    
    end
    
     % Close the waitbar
    close(h);
    

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

    % remove duplicate points from the pareto front array
    overall_rank_1_population = unique(overall_rank_1_population,'rows');

    %% ADD THE FINAL PARETO SET TO THE PLOT OF ALL THE DIFFERENT DOMINANT SETS
    % Turn off the hold to stop adding new plots to the current figure
    scatter(overall_rank_1_population(:,1),  overall_rank_1_population(:,2), 20, ...
         'MarkerFaceColor',[0.5 ,.8, 0.2],...
         'MarkerEdgeColor',[0.5, 0.8, 0.2],...
         'LineWidth',0.75)

    % Add labels and title (optional)
    xlabel('Objective 1');
    ylabel('Objective 2');
    title('Dominant Solution Set From Each GA Run');
    
    % Display the legend (optional)
    legend_str = arrayfun(@(i) sprintf('GA Run %d', i), 1:num_runs, 'UniformOutput', false);
    final_element = 'Pareto Set';
    legend_str = [legend_str, final_element];
    legend(legend_str);

    hold off;
    %% Plot the Final Pareto Set

    % plot the final pareto front for the simulated number of GA runs
    figure('Name','Pareto Front');
    scatter(overall_rank_1_population(:,1),  overall_rank_1_population(:,2), 15, ...
         'MarkerEdgeColor',[0 .5 .5],...
         'MarkerFaceColor',[0 .7 .7],...
         'LineWidth',0.75)
    title('ZDT1 Problem Pareto Front')
    xlabel('Objective 1') 
    ylabel('Objective 2') 

    % plot pareto additons for each sucessive GA run:
    % Calculate the number of points per group
    points_per_group = size(overall_rank_1_population, 1) / num_runs;
    
    % Set up a figure
    figure('Name','Pareto Front By GA Run');
    
    % Create a colormap
    colors = jet(num_runs);
    
    % Initialize the legend entries
    legend_entries = cell(num_runs, 1);
    
    % Plot the points with different colors
    hold on;
    for i = 1:num_runs
        % Calculate the indices for the current group
        start_idx = (i - 1) * points_per_group + 1;
        end_idx = i * points_per_group;
        
        % Extract the current group of points
        group = overall_rank_1_population(start_idx:end_idx, :);
        
        % Plot the current group with its corresponding color
        plot(group(:, 1), group(:, 2), '.', 'Color', colors(i, :), 'MarkerSize', 15);
        
        % Update the legend entry for the current group
        legend_entries{i} = sprintf('GA run %d', i);
    end
    
    % Customize the plot (optional)
    title('Pareto Front Additions by GA Run Instance');
    xlabel('Objective 1');
    ylabel('Objective');
    legend(legend_entries);
    grid on;
    
    % Display the plot
    hold off;

    %% Plot the statistics for the independent GA run quality metrics

    figure('Name', 'Quality Metric Box and Whiskers Plot');
    % Create a box and whiskers plot using the grouping variable
    boxplot([pareto_spread_storage,cluster_storage],'Notch','on','Labels',{'Pareto Spread','Cluster'})
    
    % Add labels and a title
    xlabel('Groups');
    ylabel('Values');
    title('Box and Whiskers Plot');

    %% calculate the qaulity metrics for the final Pareto front

    % Pareto Spread
    pareto_spread = Pareto_Spread(overall_rank_1_population);
    
    % cluster metric
    clus = cluster(overall_rank_1_population, 200);

    % number of function calls per pareto point
    calls_per_pareto =  ceil(num_function_calls / length(overall_rank_1_population)); 

    % Initialize an array to store the distances
    distances = zeros(size(overall_rank_1_population, 1), 1);
    
    % Loop through each point and calculate the distance
    for i = 1:size(overall_rank_1_population, 1)
        distances(i) = norm(overall_rank_1_population(i, :) - [-300 0]);
    end
    
    % Calculate the mean and standard deviation of the distances
    mean_distance = mean(distances);
    std_distance = std(distances);
    
    % Print out the results
    fprintf('Mean distance: %.2f\n', mean_distance);
    fprintf('Standard deviation of distances: %.2f\n', std_distance);

     table_data = {
                    
                 'Number of Pareto Points', length(overall_rank_1_population);
                 'Pareto Spread', pareto_spread;
                 ' cluster metric', clus
                 'function calls per pareto point', calls_per_pareto
        
                 }

    % Create a figure
    fig = figure('Name', 'Problem Data');

    % Create a table in the figure
    uitable(fig, 'Data', table_data);
end
%----------------------------------------------------------------------------

%----------------------------------------------------------------------------
function RUN_ZDT2(num_runs, population_size, num_generations)
  % define global generation tracker (for plotting purposes)
    global gen

    % define first rank (pareto front) storage vector:
    population_storage = [];

    %create figure for stochastic element plotting
    figure;

     % Create the waitbar
    h = waitbar(0, 'Determining Pareto Front...');

    % initilize counter for determining # of pareto points per function
    % call metric
    num_function_calls = 0;

    %initizlize quality metric storage arrays
    % these arrays will store each GA run's quality metrics for future
    % analysis
    pareto_spread_storage = zeros(num_runs,1);
    cluster_storage = zeros(num_runs,1);

    for run = 1:num_runs
    %---------------------------- ZDT2 PROBLEM-------------------------------
    
        nvars = 30;
        lb = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
        ub = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];
        
        options = optimoptions('ga');
        options = optimoptions(options,'MaxGenerations', num_generations);
        options = optimoptions(options,'CreationFcn', @gacreationuniform);
        options = optimoptions(options,'CrossoverFcn', @crossoverscattered);
        options = optimoptions(options,'EliteCount', ceil(0.85*population_size));
        options = optimoptions(options,'MutationFcn', {  @mutationuniform [] });
        options = optimoptions(options,'Display', 'iter');
        options = optimoptions(options,'MaxStallGenerations', 40);
        %options = optimoptions(options, 'PlotFcn', @gaplotbestf);
        options = optimoptions(options,'Vectorized', 'on');
        options = optimoptions(options,'PopulationSize', population_size);
    
        gen = 0;
        
        % call the GA for the required test problem
        [x,fval,exitflag,output,population,score] = ga(@GA_Fitness_Func_ZDT2,nvars,[],[],[],[],lb,ub,[],options);

        % Extract the number of function evaluations from the output structure
        num_function_calls = num_function_calls + output.funccount;


        %---------------------------------------------------------
        % calculating the objectivre function values for the final
        % generation population

        % objective function value storage array:
        objective_func_value_storage = zeros(population_size,2);

        for ix = 1:size(population,1)
        
            % pluck indiovidual dsign out of the population array
            Input = population(ix,:);
            
            % ---------- INITIAL OBJECTIVE FUNCTION VALUATION -------------------
        
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
            objective_func_value_storage(ix,1) = F1;
            objective_func_value_storage(ix,2) = F2;

        end

        population_storage = [population_storage; objective_func_value_storage];
        
       % Update the waitbar
        progress = run / num_runs;
        waitbar(progress, h, sprintf('GA Run Number: %d/%d  |  Progress: %.1f%%', run, num_runs, progress * 100));

                %*****************************************************************************************
        %% PLOTS THE FIRST FRONT FOR EACH RUN - HIGHLIGHTS STOCHASTIC
        % EFFECTS
        % determines rankls and picks out the indexes of the first rank
        % individuals
        ranks = non_dominated_sort(objective_func_value_storage);
        rank_1_indexes_overall = find(ranks == 1);
    
         % storage variable for OVERALL (for all runs) "first rank" solutions
        overall_rank_1_population = zeros(length(rank_1_indexes_overall), 2);
        
        % loops through each index and adds the objective function values to
        % the above strage array - which will be plotted
        for j = 1:length(rank_1_indexes_overall)
            
            index = rank_1_indexes_overall(j);
        
            overall_rank_1_population(j,1) = objective_func_value_storage(index,1);
            overall_rank_1_population(j,2) = objective_func_value_storage(index,2);
        
        end

        %% calculate the quality metrics for this instance (GA run) first
        % front non-dominated set
        % Pareto Spread

        normalization_factor = 0.4661;

        pareto_spread_storage(run,1) = Pareto_Spread(overall_rank_1_population)/normalization_factor;
    
        % cluster metric
        cluster_storage(run,1) = cluster(overall_rank_1_population, 200);
    
        %% Plot the GA-Run's Non-Dominated Set
    
         % Plot the points
        plot(overall_rank_1_population(:,1),  overall_rank_1_population(:,2), '*');
    
        % Keep the current plot active
        hold on;
        %***************************************************************************************
    
    end

    % Close the waitbar
    close(h);
    
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

    % remove duplicate points from the pareto front array
    overall_rank_1_population = unique(overall_rank_1_population,'rows');

    %% ADD THE FINAL PARETO SET TO THE PLOT OF ALL THE DIFFERENT DOMINANT SETS
    % Turn off the hold to stop adding new plots to the current figure
    scatter(overall_rank_1_population(:,1),  overall_rank_1_population(:,2), 20, ...
         'MarkerFaceColor',[0.5 ,.8, 0.2],...
         'MarkerEdgeColor',[0.5, 0.8, 0.2],...
         'LineWidth',0.75)

    % Add labels and title (optional)
    xlabel('Objective 1');
    ylabel('Objective 2');
    title('Dominant Solution Set From Each GA Run');
    
    % Display the legend (optional)
    legend_str = arrayfun(@(i) sprintf('GA Run %d', i), 1:num_runs, 'UniformOutput', false);
    final_element = 'Pareto Set';
    legend_str = [legend_str, final_element];
    legend(legend_str);

    hold off;
    %% Plot the Final Pareto Set

    % plot the final pareto front for the simulated number of GA runs
    figure('Name','Pareto Front');
    scatter(overall_rank_1_population(:,1),  overall_rank_1_population(:,2), 15, ...
         'MarkerEdgeColor',[0 .5 .5],...
         'MarkerFaceColor',[0 .7 .7],...
         'LineWidth',0.75)
    title('ZDT2 Problem Pareto Front')
    xlabel('Objective 1') 
    ylabel('Objective 2') 

    % plot pareto additons for each sucessive GA run:
    % Calculate the number of points per group
    points_per_group = size(overall_rank_1_population, 1) / num_runs;
    
    % Set up a figure
    figure('Name','Pareto Front By GA Run');
    
    % Create a colormap
    colors = jet(num_runs);
    
    % Initialize the legend entries
    legend_entries = cell(num_runs, 1);
    
    % Plot the points with different colors
    hold on;
    for i = 1:num_runs
        % Calculate the indices for the current group
        start_idx = (i - 1) * points_per_group + 1;
        end_idx = i * points_per_group;
        
        % Extract the current group of points
        group = overall_rank_1_population(start_idx:end_idx, :);
        
        % Plot the current group with its corresponding color
        plot(group(:, 1), group(:, 2), '.', 'Color', colors(i, :), 'MarkerSize', 15);
        
        % Update the legend entry for the current group
        legend_entries{i} = sprintf('GA run %d', i);
    end
    
    % Customize the plot (optional)
    title('Pareto Front Additions by GA Run Instance');
    xlabel('Objective 1');
    ylabel('Objective');
    legend(legend_entries);
    grid on;
    
    % Display the plot
    hold off;

     %% Plot the statistics for the independent GA run quality metrics

    figure('Name', 'Quality Metric Box and Whiskers Plot');
    % Create a box and whiskers plot using the grouping variable
    boxplot([pareto_spread_storage,cluster_storage],'Notch','on','Labels',{'Pareto Spread','Cluster'})
    
    % Add labels and a title
    xlabel('Groups');
    ylabel('Values');
    title('Box and Whiskers Plot');

    %% calculate the qaulity metrics for the final Pareto front

    % Pareto Spread
    pareto_spread = Pareto_Spread(overall_rank_1_population);
    
    % cluster metric
    clus = cluster(overall_rank_1_population, 400);

    % number of function calls per pareto point
    calls_per_pareto =  ceil(num_function_calls / length(overall_rank_1_population)); 

    % Initialize an array to store the distances
    distances = zeros(size(overall_rank_1_population, 1), 1);
    
    % Loop through each point and calculate the distance
    for i = 1:size(overall_rank_1_population, 1)
        distances(i) = norm(overall_rank_1_population(i, :) - [-300 0]);
    end
    
    % Calculate the mean and standard deviation of the distances
    mean_distance = mean(distances);
    std_distance = std(distances);
    
    % Print out the results
    fprintf('Mean distance: %.2f\n', mean_distance);
    fprintf('Standard deviation of distances: %.2f\n', std_distance);

     table_data = {
                    
                 'Number of Pareto Points', length(overall_rank_1_population);
                 'Pareto Spread', pareto_spread;
                 ' cluster metric', clus
                 'function calls per pareto point', calls_per_pareto
        
                 }

    % Create a figure
    fig = figure('Name', 'Problem Data');

    % Create a table in the figure
    uitable(fig, 'Data', table_data);

end
%----------------------------------------------------------------------------

%----------------------------------------------------------------------------
function RUN_ZDT3(num_runs, population_size, num_generations)
    
    % define global generation tracker (for plotting purposes)
    global gen
    %declare global valriable for storing all individual objective function
    %value - used for determining pareto front

    % define first rank (pareto front) storage vector:
    population_storage = [];

    %create figure for stochastic element plotting
    figure;

    % Create the waitbar
    h = waitbar(0, 'Determining Pareto Front...');

    % initilize counter for determining # of pareto points per function
    % call metric
    num_function_calls = 0;

    %initizlize quality metric storage arrays
    % these arrays will store each GA run's quality metrics for future
    % analysis
    pareto_spread_storage = zeros(num_runs,1);
    cluster_storage = zeros(num_runs,1);

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
        %options = optimoptions(options,'EliteCount', ceil(0.85*population_size));
        options = optimoptions(options,'Display', 'iter');
        options = optimoptions(options,'MaxStallGenerations', 40);
        %options = optimoptions(options, 'PlotFcn', @gaplotbestf);
        options = optimoptions(options,'Vectorized', 'on')
        options = optimoptions(options,'PopulationSize', population_size);
    
        gen = 0;
        objective_func_value_storage = []
        
        % call the GA for the required test problem
        [x,fval,exitflag,output,population,score] = ga(@GA_Fitness_Func_ZDT3,nvars,[],[],[],[],lb,ub,[],options);

        % Extract the number of function evaluations from the output structure
        num_function_calls = num_function_calls + output.funccount;

        %---------------------------------------------------------
        % calculating the objectivre function values for the final
        % generation population

        % objective function value storage array:
        objective_func_value_storage = zeros(population_size,2);

        for ix = 1:size(population,1)
        
            % pluck indiovidual dsign out of the population array
            Input = population(ix,:);
    
            % ---------- INITIAL OBJECTIVE FUNCTION VALUATION -------------------
        
           x1 = Input(1);
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
            F2 = (1 - sqrt(x1/g) - (x1/g)*sin(10*pi*x1))*g;  %Min
        
            % update fittness vector
            objective_func_value_storage(ix,1) = F1;
            objective_func_value_storage(ix,2) = F2;

        end

        population_storage = [population_storage; objective_func_value_storage];
        %--------------------------------------------------------

        % Update the waitbar
        progress = run / num_runs;
        waitbar(progress, h, sprintf('GA Run Number: %d/%d  |  Progress: %.1f%%', run, num_runs, progress * 100));

                %*****************************************************************************************
        %% PLOTS THE FIRST FRONT FOR EACH RUN - HIGHLIGHTS STOCHASTIC
        % EFFECTS
        % determines rankls and picks out the indexes of the first rank
        % individuals
        ranks = non_dominated_sort(objective_func_value_storage)
        rank_1_indexes_overall = find(ranks == 1);
    
         % storage variable for OVERALL (for all runs) "first rank" solutions
        overall_rank_1_population = zeros(length(rank_1_indexes_overall), 2);
        
        % loops through each index and adds the objective function values to
        % the above strage array - which will be plotted
        for j = 1:length(rank_1_indexes_overall)
            
            index = rank_1_indexes_overall(j);
        
            overall_rank_1_population(j,1) = objective_func_value_storage(index,1);
            overall_rank_1_population(j,2) = objective_func_value_storage(index,2);
        
        end

        %% calculate the quality metrics for this instance (GA run) first
        % front non-dominated set
        % Pareto Spread

        normalization_factor = 3.4726;

        pareto_spread_storage(run,1) = Pareto_Spread(overall_rank_1_population)/normalization_factor;
    
        % cluster metric
        cluster_storage(run,1) = cluster(overall_rank_1_population, 200);
    
        %% Plot the GA-Run's Non-Dominated Set
    
         % Plot the points
        plot(overall_rank_1_population(:,1),  overall_rank_1_population(:,2), '*');
    
        % Keep the current plot active
        hold on;
        %***************************************************************************************
    
    end
    
     % Close the waitbar
    close(h);
    

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

    % remove duplicate points from the pareto front array
    overall_rank_1_population = unique(overall_rank_1_population,'rows');

    %% ADD THE FINAL PARETO SET TO THE PLOT OF ALL THE DIFFERENT DOMINANT SETS
    % Turn off the hold to stop adding new plots to the current figure
    scatter(overall_rank_1_population(:,1),  overall_rank_1_population(:,2), 20, ...
         'MarkerFaceColor',[0.5 ,.8, 0.2],...
         'MarkerEdgeColor',[0.5, 0.8, 0.2],...
         'LineWidth',0.75)

    % Add labels and title (optional)
    xlabel('Objective 1');
    ylabel('Objective 2');
    title('Dominant Solution Set From Each GA Run');
    
    % Display the legend (optional)
    legend_str = arrayfun(@(i) sprintf('GA Run %d', i), 1:num_runs, 'UniformOutput', false);
    final_element = 'Pareto Set';
    legend_str = [legend_str, final_element];
    legend(legend_str);

    hold off;
    %% Plot the Final Pareto Set

    % plot the final pareto front for the simulated number of GA runs
    figure('Name','Pareto Front');
    scatter(overall_rank_1_population(:,1),  overall_rank_1_population(:,2), 15, ...
         'MarkerEdgeColor',[0 .5 .5],...
         'MarkerFaceColor',[0 .7 .7],...
         'LineWidth',0.75)
    title('ZDT3 Problem Pareto Front')
    xlabel('Objective 1') 
    ylabel('Objective 2') 

    % plot pareto additons for each sucessive GA run:
    % Calculate the number of points per group
    points_per_group = size(overall_rank_1_population, 1) / num_runs;
    
    % Set up a figure
    figure('Name','Pareto Front By GA Run');
    
    % Create a colormap
    colors = jet(num_runs);
    
    % Initialize the legend entries
    legend_entries = cell(num_runs, 1);
    
    % Plot the points with different colors
    hold on;
    for i = 1:num_runs
        % Calculate the indices for the current group
        start_idx = (i - 1) * points_per_group + 1;
        end_idx = i * points_per_group;
        
        % Extract the current group of points
        group = overall_rank_1_population(start_idx:end_idx, :);
        
        % Plot the current group with its corresponding color
        plot(group(:, 1), group(:, 2), '.', 'Color', colors(i, :), 'MarkerSize', 15);
        
        % Update the legend entry for the current group
        legend_entries{i} = sprintf('GA run %d', i);
    end
    
    % Customize the plot (optional)
    title('Pareto Front Additions by GA Run Instance');
    xlabel('Objective 1');
    ylabel('Objective');
    legend(legend_entries);
    grid on;
    
    % Display the plot
    hold off;

     %% Plot the statistics for the independent GA run quality metrics

    figure('Name', 'Quality Metric Box and Whiskers Plot');
    % Create a box and whiskers plot using the grouping variable
    boxplot([pareto_spread_storage,cluster_storage],'Notch','on','Labels',{'Pareto Spread','Cluster'})
    
    % Add labels and a title
    xlabel('Groups');
    ylabel('Values');
    title('Box and Whiskers Plot');

    %% calculate the qaulity metrics for the final Pareto front

    % Pareto Spread
    pareto_spread = Pareto_Spread(overall_rank_1_population);
    
    % cluster metric
    clus = cluster(overall_rank_1_population, 200);

    % number of function calls per pareto point
    calls_per_pareto =  ceil(num_function_calls / length(overall_rank_1_population)); 

    % Initialize an array to store the distances
    distances = zeros(size(overall_rank_1_population, 1), 1);
    
    % Loop through each point and calculate the distance
    for i = 1:size(overall_rank_1_population, 1)
        distances(i) = norm(overall_rank_1_population(i, :) - [-300 0]);
    end
    
    % Calculate the mean and standard deviation of the distances
    mean_distance = mean(distances);
    std_distance = std(distances);
    
    % Print out the results
    fprintf('Mean distance: %.2f\n', mean_distance);
    fprintf('Standard deviation of distances: %.2f\n', std_distance);

     table_data = {
                    
                 'Number of Pareto Points', length(overall_rank_1_population);
                 'Pareto Spread', pareto_spread;
                 ' cluster metric', clus
                 'function calls per pareto point', calls_per_pareto
        
                 }

    % Create a figure
    fig = figure('Name', 'Problem Data');

    % Create a table in the figure
    uitable(fig, 'Data', table_data);
end

%----------------------------------------------------------------------------
function RUN_TNK_MORO(num_runs, population_size, num_generations)

    
    % define global generation tracker (for plotting purposes)
    global gen

    %create figure for stochastic element plotting
    figure;

    % define first rank (pareto front) storage vector:
    population_storage = [];
    global P1
    global P2
    P1 = 1;
    P2 = 1;

    %Create the waitbar
    h = waitbar(0, 'Determining Pareto Front...');

    % initilize counter for determining # of pareto points per function
    % call metric
    num_function_calls = 0;

    for run = 1:num_runs
    %---------------------------- TNK PROBLEM-------------------------------

        nvars = 2;
        lb = [0, 0];
        ub = [pi, pi];
        
        options = optimoptions('ga');
        options = optimoptions(options,'MaxGenerations', num_generations);
        options = optimoptions(options,'CreationFcn', @gacreationuniform);
        options = optimoptions(options,'CrossoverFcn', @crossoverscattered);
        options = optimoptions(options,'EliteCount', ceil(0.85*population_size))'
        options = optimoptions(options,'MutationFcn', {  @mutationadaptfeasible [] });
        options = optimoptions(options,'Display', 'iter');
        options = optimoptions(options,'MaxStallGenerations', 40);
        %options = optimoptions(options, 'PlotFcn', @gaplotbestf);
        options = optimoptions(options,'Vectorized', 'on')
        options = optimoptions(options,'PopulationSize', population_size);
    
        gen = 0;
       
        % call the GA for the required test problem
        [x,fval,exitflag,output,population,score] = ga(@GA_Fitness_Func_TNK_MORO,nvars,[],[],[],[],lb,ub,[],options);

        % Extract the number of function evaluations from the output structure
        num_function_calls = num_function_calls + output.funccount;

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
    
            F1 = x1; % Min
            F2 = x2;  %Min
        
            % update fittness vector
            objective_func_value_storage(ix,1) = F1;
            objective_func_value_storage(ix,2) = F2;
        end

        % CONSTRAINT HANDELING
        % define empty array for storing constrain values:
        constrained_fitness = zeros(size(population,1),2);
    
        for ix = 1:size(population,1)
        
            % pluck indiovidual dsign out of the population array
            x = population(ix,:);
        
            x1 = x(1);
            x2 = x(2);
    
            C = [zeros(2,1)];
            C(1) = -1*(x1^2 + x2^2 -1 - 0.1*cos(16*atan(x1/x2)));
            C(2) = (x1 - 0.5)^2 + (x2 - 0.5)^2 -0.5;
    
            Ceq = [];
        
             % initilize constraint violation value = 0
            total_violation = 0;
        
            for z = 1:length(C)
        
                if C(z) > 0
        
                    total_violation = total_violation + C(z);

                elseif isnan(C(z))

                    total_violation = total_violation + 1000;
       
                end 
        
            end
    
            constrained_fitness(ix,1) = objective_func_value_storage(ix,1) + (total_violation * 1000);
            constrained_fitness(ix,2) = objective_func_value_storage(ix,2) + (total_violation * 1000);
        end

        population_storage = [population_storage; constrained_fitness];
        %--------------------------------------------------------
        
        A = 2;
        B = 1;
        % Define the function to be maximized
        fun = @(P) (A^2 + B^2 -1 - 0.1*cos(16*atan(A/B))   - 0.2*sin(P(1))*cos(P(2)));

        % Define the bounds on the variables
        lb = [-1, -1];
        ub = [3, 3];
        NumDesign = size(population,1);
        for i = 1:NumDesign
            A = population(i, 1);
            B = population(i, 2);
            % Call fmincon to find the maximum value of the function
            P0 = [1, 1]; % starting point
            [x, ~] = fmincon(fun, P0, [], [], [], [], lb, ub);
            Ps(i, 1) = x(1);
            Ps(i, 2) = x(2);
            G(i, 1) = -(A^2 + B^2 -1 - 0.1*cos(16*atan(A/B))   - 0.2*sin(x(1))*cos(x(2)));
        end
        [max_value, max_index] = max(G);
        P1 = Ps(max_index, 1);
        P2 = Ps(max_index, 2);

         % Update the waitbar
        progress = run / num_runs;
        waitbar(progress, h, sprintf('GA Run Number: %d/%d  |  Progress: %.1f%%', run, num_runs, progress * 100));

    end
    
    % close the progress bar:
    close(h);

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

    % remove duplicate points from the pareto front array
    overall_rank_1_population = unique(overall_rank_1_population,'rows');

    % plot the final pareto front for the simulated number of GA runs
    figure('Name','Pareto Front');
    scatter(overall_rank_1_population(:,1),  overall_rank_1_population(:,2), 15, ...
         'MarkerEdgeColor',[0.8, .1 .1],...
         'MarkerFaceColor',[0.8 .1 .1],...
         'LineWidth',0.75)
    title('RMOGA TNK Problem Pareto Front')
    xlabel('Objective 1') 
    ylabel('Objective 2') 

    % plot pareto additons for each sucessive GA run:
    % Calculate the number of points per group
    points_per_group = size(overall_rank_1_population, 1) / num_runs;
    
    % Set up a figure
    figure('Name','Pareto Front By GA Run');
    
    % Create a colormap
    colors = jet(num_runs);
    
    % Initialize the legend entries
    legend_entries = cell(num_runs, 1);
    
    % Plot the points with different colors
    hold on;
    for i = 1:num_runs
        % Calculate the indices for the current group
        start_idx = (i - 1) * points_per_group + 1;
        end_idx = i * points_per_group;
        
        % Extract the current group of points
        group = overall_rank_1_population(start_idx:end_idx, :);
        
        % Plot the current group with its corresponding color
        plot(group(:, 1), group(:, 2), '.', 'Color', colors(i, :), 'MarkerSize', 15);
        
        % Update the legend entry for the current group
        legend_entries{i} = sprintf('GA run %d', i);
    end
    
    % Customize the plot (optional)
    title('Pareto Front Additions by GA Run Instance');
    xlabel('Objective 1');
    ylabel('Objective');
    legend(legend_entries);
    grid on;
    
    % Display the plot
    hold off;

     %% calculate the qaulity metrics

    % Pareto Spread
    pareto_spread = Pareto_Spread(overall_rank_1_population);
    
    % cluster metric
    clus = cluster(overall_rank_1_population, 200);

    % number of function calls per pareto point
    calls_per_pareto =  ceil(num_function_calls / length(overall_rank_1_population)); 

    % Initialize an array to store the distances
    distances = zeros(size(overall_rank_1_population, 1), 1);
    
    % Loop through each point and calculate the distance
    for i = 1:size(overall_rank_1_population, 1)
        distances(i) = norm(overall_rank_1_population(i, :) - [-300 0]);
    end
    
    % Calculate the mean and standard deviation of the distances
    mean_distance = mean(distances);
    std_distance = std(distances);
    
    % Print out the results
    fprintf('Mean distance: %.2f\n', mean_distance);
    fprintf('Standard deviation of distances: %.2f\n', std_distance);

     table_data = {
                    
                 'Number of Pareto Points', length(overall_rank_1_population);
                 'Pareto Spread', pareto_spread;
                 ' cluster metric', clus
                 'function calls per pareto point', calls_per_pareto
        
                 }

    % Create a figure
    fig = figure('Name', 'Problem Data');

    % Create a table in the figure
    uitable(fig, 'Data', table_data);
end
%----------------------------------------------------------------------------

%---------------------------------------------------------------------------
function RUN_OSY_Obj_First(num_runs, population_size, num_generations)
    
    % define global generation tracker (for plotting purposes)
    global gen
    %declare global valriable for storing all individual objective function
    %value - used for determining pareto front

    % define first rank (pareto front) storage vector:
    population_storage = [];

    % Create the waitbar
    h = waitbar(0, 'Determining Pareto Front...');

    %create figure for stochastic element plotting
    figure;

    % initilize counter for determining # of pareto points per function
    % call metric
    num_function_calls = 0;

    %initizlize quality metric storage arrays
    % these arrays will store each GA run's quality metrics for future
    % analysis
    pareto_spread_storage = zeros(num_runs,1);
    cluster_storage = zeros(num_runs,1);

    for run = 1:num_runs
    %---------------------------- OSY PROBLEM-------------------------------
    
        nvars = 6;
        lb = [0, 0, 1, 0, 1, 0];
        ub = [10,10, 5, 6, 5, 10];
        
        options = optimoptions('ga');
        options = optimoptions(options,'MaxGenerations', num_generations);
        options = optimoptions(options,'CreationFcn', @gacreationuniform);
        options = optimoptions(options,'CrossoverFcn', @crossoverscattered);
        options = optimoptions(options,'EliteCount', ceil(0.85*population_size));
        options = optimoptions(options,'MutationFcn', {  @mutationadaptfeasible [] });
        options = optimoptions(options,'Display', 'iter');
        options = optimoptions(options,'MaxStallGenerations', 40);
        %options = optimoptions(options, 'PlotFcn', @gaplotbestf);
        options = optimoptions(options,'Vectorized', 'on')
        options = optimoptions(options,'PopulationSize', population_size);
    
        gen = 0;
       
        % call the GA for the required test problem
        [x,fval,exitflag,output,population,score] = ga(@GA_Fitness_Func_OSY_Obj_First,nvars,[],[],[],[],lb,ub,[],options);

        % Extract the number of function evaluations from the output structure
        num_function_calls = num_function_calls + output.funccount;

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

        % CONSTRAINT HANDELING
        % define empty array for storing constrain values:
        constrained_fitness = zeros(size(population,1),2);
    
        for ix = 1:size(population,1)
        
            % pluck indiovidual dsign out of the population array
            x = population(ix,:);
        
            x1 = x(1);
            x2 = x(2);
            x3 = x(3);
            x4 = x(4);
            x5 = x(5);
            x6 = x(6);
            
            C = [zeros(6,1)];
            C(1) = 1 - (x1+x2)/2;
            C(2) = ((x1 + x2)/6) - 1;
            C(3) =(x2-x1)/2 - 1;
            C(4) = (x1 - 3*x2)/2 -1;
            C(5) =(((x3-3)^2 + x4)/4) -1;
            C(6) = 1 - ((x5 - 3)^2 + x6)/4;
            Ceq = [];

             % initilize constraint violation value = 0
            total_violation = 0;
        
            for z = 1:length(C)
        
                if C(z) > 0
        
                    total_violation = total_violation + C(z);

                elseif isnan(C(z))

                    total_violation = total_violation + 100000;
       
                end 
        
            end
    
            constrained_fitness(ix,1) = objective_func_value_storage(ix,1) + (total_violation * 1000);
            constrained_fitness(ix,2) = objective_func_value_storage(ix,2) + (total_violation * 1000);
        end

        population_storage = [population_storage; constrained_fitness];

        %*****************************************************************************************
        %% PLOTS THE FIRST FRONT FOR EACH RUN - HIGHLIGHTS STOCHASTIC EFFECTS
        % determines ranks and picks out the indexes of the first rank
        % individuals
        ranks = non_dominated_sort(constrained_fitness)
        rank_1_indexes_overall = find(ranks == 1);
    
         % storage variable for OVERALL (for all runs) "first rank" solutions
        overall_rank_1_population = zeros(length(rank_1_indexes_overall), 2);
        
        % loops through each index and adds the objective function values to
        % the above storage array - which will be plotted
        for j = 1:length(rank_1_indexes_overall)
            
            index = rank_1_indexes_overall(j);
        
            overall_rank_1_population(j,1) = constrained_fitness(index,1);
            overall_rank_1_population(j,2) = constrained_fitness(index,2);
        
        end

        %% calculate the quality metrics for this instance (GA run) first
        % front non-dominated set
        % Pareto Spread

        normalization_factor = 13384;

        pareto_spread_storage(run,1) = Pareto_Spread(overall_rank_1_population)/normalization_factor;
    
        % cluster metric
        cluster_storage(run,1) = cluster(overall_rank_1_population, 200);
    
        %% Plot the GA-Run's Non-Dominated Set
    
         % Plot the points
        plot(overall_rank_1_population(:,1),  overall_rank_1_population(:,2), '*');
    
        % Keep the current plot active
        hold on;
        %***************************************************************************************

       % Update the waitbar
        progress = run / num_runs;
        waitbar(progress, h, sprintf('GA Run Number: %d/%d  |  Progress: %.1f%%', run, num_runs, progress * 100));
    
    end


    % Close the waitbar
    close(h);
    

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

    % remove duplicate points from the pareto front array
    overall_rank_1_population = unique(overall_rank_1_population,'rows');

    %% ADD THE FINAL PARETO SET TO THE PLOT OF ALL THE DIFFERENT DOMINANT SETS
    % Turn off the hold to stop adding new plots to the current figure
    scatter(overall_rank_1_population(:,1),  overall_rank_1_population(:,2), 20, ...
         'MarkerFaceColor',[0.5 ,.8, 0.2],...
         'MarkerEdgeColor',[0.5, 0.8, 0.2],...
         'LineWidth',0.75)

    % Add labels and title (optional)
    xlabel('Objective 1');
    ylabel('Objective 2');
    title('Dominant Solution Set From Each GA Run');
    
    % Display the legend (optional)
    legend_str = arrayfun(@(i) sprintf('GA Run %d', i), 1:num_runs, 'UniformOutput', false);
    final_element = 'Pareto Set';
    legend_str = [legend_str, final_element];
    legend(legend_str);

    hold off;
    %% Plot the Final Pareto Set
    % plot the final pareto front for the simulated number of GA runs
    figure('Name','Pareto Front');
    scatter(overall_rank_1_population(:,1),  overall_rank_1_population(:,2), 15, ...
         'MarkerEdgeColor',[0 .5 .5],...
         'MarkerFaceColor',[0 .7 .7],...
         'LineWidth',0.75)
    title('OSY Problem Pareto Front')
    xlabel('Objective 1') 
    ylabel('Objective 2') 

    % plot pareto additons for each sucessive GA run:
    % Calculate the number of points per group
    points_per_group = size(overall_rank_1_population, 1) / num_runs;
    
    % Set up a figure
    figure('Name','Pareto Front By GA Run');
    
    % Create a colormap
    colors = jet(num_runs);
    
    % Initialize the legend entries
    legend_entries = cell(num_runs, 1);
    
    % Plot the points with different colors
    hold on;
    for i = 1:num_runs
        % Calculate the indices for the current group
        start_idx = (i - 1) * points_per_group + 1;
        end_idx = i * points_per_group;
        
        % Extract the current group of points
        group = overall_rank_1_population(start_idx:end_idx, :);
        
        % Plot the current group with its corresponding color
        plot(group(:, 1), group(:, 2), '.', 'Color', colors(i, :), 'MarkerSize', 15);
        
        % Update the legend entry for the current group
        legend_entries{i} = sprintf('GA run %d', i);
    end
    
    % Customize the plot (optional)
    title('Pareto Front Additions by GA Run Instance');
    xlabel('Objective 1');
    ylabel('Objective');
    legend(legend_entries);
    grid on;
    
    % Display the plot
    hold off;

    %% Plot the statistics for the independent GA run quality metrics

    figure('Name', 'Quality Metric Box and Whiskers Plot');
    % Create a box and whiskers plot using the grouping variable
    boxplot([pareto_spread_storage,cluster_storage],'Notch','on','Labels',{'Pareto Spread','Cluster'})
    
    % Add labels and a title
    xlabel('Groups');
    ylabel('Values');
    title('Box and Whiskers Plot');

    %% calculate the qaulity metrics for the final Pareto front

    % Pareto Spread
    pareto_spread = Pareto_Spread(overall_rank_1_population);
    
    % cluster metric
    clus = cluster(overall_rank_1_population, 200);

    % number of function calls per pareto point
    calls_per_pareto =  ceil(num_function_calls / length(overall_rank_1_population)); 

    % Initialize an array to store the distances
    distances = zeros(size(overall_rank_1_population, 1), 1);
    
    % Loop through each point and calculate the distance
    for i = 1:size(overall_rank_1_population, 1)
        distances(i) = norm(overall_rank_1_population(i, :) - [-300 0]);
    end
    
    % Calculate the mean and standard deviation of the distances
    mean_distance = mean(distances);
    std_distance = std(distances);
    
    % Print out the results
    fprintf('Mean distance: %.2f\n', mean_distance);
    fprintf('Standard deviation of distances: %.2f\n', std_distance);

     table_data = {
                    
                 'Number of Pareto Points', length(overall_rank_1_population);
                 'Pareto Spread', pareto_spread;
                 ' cluster metric', clus
                 'function calls per pareto point', calls_per_pareto
        
                 }

    % Create a figure
    fig = figure('Name', 'Problem Data');

    % Create a table in the figure
    uitable(fig, 'Data', table_data);

end
%----------------------------------------------------------------------------