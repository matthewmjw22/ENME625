% generate a set of random function evaluations
fvals = [1 14; 5 5; 6 2; 4 15; 2 20;3 22; ];
rank_test = [1; 1; 1; 2; 2; 3;];
x = [3 4 5; 5 6 7; 8 9 0; 1 2 4; 1 3 4; 3 4 6;];

Max = [max(fvals(:,1)); max(fvals(:,2));]
Min = [min(fvals(:,1)); min(fvals(:,2));]
sqrt(sum(((fvals(4,:) - fvals(5,:))./transpose(Max - Min)).^2))
% compute the non-dominated ranks of the points
% rank = non_dominated_sort(fvals);
% 
% % display the ranks
% disp(rank);
% 
% dist = calc_rank_distances(x, fvals, rank)

[dist, rank, niche] = NSGA(x, fvals)