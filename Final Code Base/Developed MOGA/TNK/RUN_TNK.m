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
    boxplot([pareto_spread_storage,cluster_storage],'Labels',{'Pareto Spread','Cluster'})
    
    % Add labels and a title
    xlabel('Quality Metrics');
    ylabel('Quality Metric Values');
    title('TNK Quality Metrics Box and Whiskers Plot');

    figure('Name', 'Quality Metric Box and Whiskers Plot');
    % Create a box and whiskers plot using the grouping variable
    boxplot([pareto_spread_storage],'Labels',{'Pareto Spread'})
    
    % Add labels and a title
    xlabel('Quality Metric');
    ylabel('Quality Metric Value');
    title('TNK Quality Metrics Box and Whiskers Plot');

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