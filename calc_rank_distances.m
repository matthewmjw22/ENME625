function [dist, niche] = calc_rank_distances(x, fvals, rank_test, sigma, alpha)
    Max = [max(fvals(:,1)); max(fvals(:,2));];
    Min = [min(fvals(:,1)); min(fvals(:,2));];
    M = max(rank_test);
    dist = zeros(length(rank_test), 1);
    niche = ones(size(fvals, 1), 1);
    rank_sum = zeros(size(fvals, 1), 1); % initialize rank_sum
    for j = 1:M
        rank_indices = find(rank_test == j);
        rank_fvals = fvals(rank_indices, :);
        n = length(rank_indices);
        % compute pairwise distances and sum them up
        for k = 1:n
            for l = k+1:n
                d = sqrt(sum(((rank_fvals(k,:) - rank_fvals(l,:))./transpose(Max - Min)).^2));
                if d > sigma
                    sh = 0;
                else
                    sh = 1 - (d/sigma).^(alpha);
                end
                niche(rank_indices(k)) = niche(rank_indices(k)) + sh;
                niche(rank_indices(l)) = niche(rank_indices(l)) + sh;
                rank_sum(rank_indices(k)) = rank_sum(rank_indices(k)) + d;
                rank_sum(rank_indices(l)) = rank_sum(rank_indices(l)) + d;
            end
        end
    end
    % copy rank sums to output array
    for i = 1:length(rank_test)
        dist(i) = rank_sum(i);
    end
end