function shared_fitness = fitness_calc(fval, ranks)
n = size(fval, 1); 
sigma = .75; epsilon = .25; alpha = 1;
M = max(ranks);
niche_count = zeros(n, 1);
shared_fitness = zeros(n, 1);
distance = zeros(n, 1);


for j = 1:M
    number = [];
    indexes = [];
    k = 1;
    for i = 1:n
        if ranks(i) == j
            number(k, :) = fval(i,:);
            indexes(k) = i;
        end
        
        for l = indexes
            distance = 0;
            for p = 1:length(indexes)
                if p ~= l
                    distance(l) = distance(l) + norm(number(l,:) - number(p,:));
                end
            end
        end
    end
    
end

shared_fitness = distance
% shared_fitness = Fitness./nc;
end
