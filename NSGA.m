function [dist, rank, niche, Fi] = NSGA(x, fvals)
rank = non_dominated_sort(fvals);
[dist, niche, Fi] = calc_rank_distances(x, fvals, rank, .75, 1, .25);
end