function Fitness = Fitness_TNK(x)
fvals = objective_functionRunMOGA_TNK(x);
rank = non_dominated_sort(fvals);
[dist, niche, Fi] = calc_rank_distances(x, fvals, rank, .75, 1, .25);
constraints = nonlinear_constraintsRunMOGA_TNK(x);
Fitness = -Fi + sum(1000000000000*constraints(constraints>0));