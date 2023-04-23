function rank = non_dominated_sort(fvals)
% fvals is an NxM matrix where N is the number of points and M is the number of objectives
% rank is an N-element vector containing the rank of each point
n = size(fvals, 1); % number of points
rank = zeros(n, 1);
S = cell(n, 1); % S{i} is the set of solutions that dominate i
N = zeros(n, 1); % N(i) is the number of solutions that i dominates
for i = 1:n
    for j = 1:n
        if i ~= j
            % compare points i and j
            if all(fvals(i,:) <= fvals(j,:)) && any(fvals(i,:) < fvals(j,:))
                % i dominates j
                S{i} = [S{i} j];
            elseif all(fvals(j,:) <= fvals(i,:)) && any(fvals(j,:) < fvals(i,:))
                % j dominates i
                N(i) = N(i) + 1;
            end
        end
    end
    if N(i) == 0
        rank(i) = 1; % i belongs to the first front
    end
end
front = 1;
while ~all(rank > 0)
    Q = []; % set of points whose rank is currently being computed
    for i = 1:n
        if rank(i) == front
            Q = [Q i];
        end
    end
    for i = 1:numel(Q)
        p = Q(i);
        for j = 1:numel(S{p})
            q = S{p}(j);
            N(q) = N(q) - 1;
            if N(q) == 0
                rank(q) = front + 1; % q belongs to the next front
            end
        end
    end
    front = front + 1;
end
end