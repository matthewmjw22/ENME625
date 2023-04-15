function [dist, rank] = NSGA(x, fvals)
rank = non_dominated_sort(fvals);
dist = calc_rank_distances(x, fvals, rank);
end