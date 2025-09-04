function [similarity] = isiDistCompare(dist1, dist2)
    
    % take the difference of two distributions by comparing percentiles of
    % isi values
    % this is the same as the Cramer-con Mises criterion, which 
    % is kinda like the kolmogorov smirnov test but summing difference 
    % across the whole distribution rather than finding max difference 
    % between the distributions
    
    % maybe consider removing outliers from the distribution before 
    % maybe rescale by the median value so 50% of data happens before .5
    % and 50% is between .5 and 1. wait that doesnt work. lmao/ 


    % Remove outliers  
    cutoff1 = mean(dist1) + 3 * std(dist1);
    cutoff2 = mean(dist2) + 3 * std(dist2);

    idx1 = find(dist1 < cutoff1);
    idx2 = find(dist2 < cutoff2);

    dist1 = dist1(idx1);
    dist2 = dist2(idx2);
    
    p = 0:.01:100;

    % Get percentiles
    percentiles1 = prctile(dist1, p, "all");
    percentiles2 = prctile(dist2, p, "all");


    figure
    subplot(2, 1, 1)
    hold on
    plot(percentiles1, p)
    plot(percentiles2, p)

    subplot(2, 1, 2)
    %% TODO: check that this is actually the difference you're looking for ??
    % i dont think this is 

    % get maximum value of the whole set and append to the one that doesn't
    % have it so you're integrating over the same range for both
    % distributions

    % kind of annoying bc you need squared difference to account for
    % everything but these arent continuous functions. idk how to do this
    m1 = max(dist1);
    m2 = max(dist2);

    if m1 > m2
        dist2 = [dist2; m1];
    else
        dist1 = [dist1; m2];
    end

    difference = (percentiles1 - percentiles2).^2;
    plot(difference, 0:.01:100)
    similarity = trapz(difference);
    
    allAxes = findall(gcf,'type','axes');
    linkaxes(allAxes, 'x')
