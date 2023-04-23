function cluster = cluster(fval, num_grid)


    n = size(fval, 1);
    % Determine the minimum and maximum values for each dimension
    x = fval(:,1);
    y = fval(:,2);

    x_range = max(x) - min(x);
    y_range = max(y) - min(y);

    bucket_size_x = x_range/num_grid;
    bucket_size_y = y_range/num_grid;
    
    x = x - min(x);
    y = y - min(y);

    array = zeros(num_grid);
    
    if (num_grid < x_range) && (num_grid < y_range)

        for i = 1:n
            x_new = ceil(x(i)/bucket_size_x);
            y_new = ceil(y(i)/bucket_size_y);
            array(x_new, y_new) = array(x_new, y_new) + 1;    
        end

        unique = nnz(array);
        cluster = unique/n;
        
    else 
        for i = 1:n
            x_new = ceil(floor(x(i)*num_grid) / max(x) +.0001);
            y_new = ceil(floor(y(i)*num_grid) / max(y) +.0001);
            array(x_new, y_new) = array(x_new, y_new) + 1;  
        end
        
        unique = nnz(array);
        cluster = unique/n;
    end

end
