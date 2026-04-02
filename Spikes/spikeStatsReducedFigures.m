%% Statistics for triphasic indicator - acclimation
pvals = [];
hFull = [];

rawDataHot(2, 1:9) = 1;
for i = 1:18
    cold = rawDataCold(:, i);
    hot = rawDataHot(:, i);

    [h,p] = kstest2(cold, hot);
    
    pvals(i) = p;
    hFull(i) = h;

end


%% Statistics for diff temp significance
% Hot
pvals = [];
hFull = [];
for i = 1:9
    deg10 = rawDataHot(:, i);
    deg20 = rawDataHot(:, i + 9);

    [h,p] = kstest2(deg10, deg20);
    
    pvals(i) = p;
    hFull(i) = h;

end

%% Statistics for diff temp significance
% Cold
pvals = [];
hFull = [];
for i = 1:9
    deg10 = rawDataCold(:, i);
    deg20 = rawDataCold(:, i + 9);

    [h,p] = kstest2(deg10, deg20);
    
    pvals(i) = p;
    hFull(i) = h;

end


%% Reducing data for triphasicness

y = tsne(tritableBig);
tritableBig = cat(1, tritableC, tritableH);

%% Create different filters

% Filter by acclimation group
gAcc = [ones([1 length(tritableC)]) 2 * ones([1 length(tritableH)])]';
figure
gscatter(y(:, 1), y(:, 2), gAcc)
title("TSNE Acclimation")

% Filter by dose
test = repmat([1 2 3 4 5 6 7 8 9], length(tritableBig) / 9);
gDose = test(1, :);
figure
gscatter(y(:, 1), y(:, 2), gDose, flipud(colors_p))
title("TSNE Dose")


% Filter by temperature
test = cat(2, ones([1 9]), 2 * ones([1 9]));
gTemp = repmat(test, 1, length(tritableBig) / 18);

% Filter by temperature
figure
gscatter(y(:, 1), y(:, 2), gTemp)
title("TSNE Temperature (not accurate yet)")


