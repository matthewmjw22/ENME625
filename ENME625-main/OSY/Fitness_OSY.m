function Fitness = Fitness_OSY(x)
fvals = objective_functionRunMOGA_OSY(x);
rank = non_dominated_sort(fvals);
[dist, niche, Fi] = calc_rank_distances(x, fvals, rank, .75, 1, .25);
constraints = nonlinear_constraintsRunMOGA_OSY(x);
Fitness = -Fi + sum(1000000000000*constraints(constraints>0));
