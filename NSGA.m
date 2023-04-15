function [dist, rank, niche] = NSGA(x, fvals)
rank = non_dominated_sort(fvals);
[dist, niche] = calc_rank_distances(x, fvals, rank, .75, 1);
end