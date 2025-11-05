clearvars
nb = 970;

pageHot = [107 109 112 114 117]; %111 and 135 not sorted yet
pageCold = [106 108 110 113 115 116];
pageControl = [103 105 127 128 129];
metadata = metadataMaster;


ALLCOND = {'Baseline','CCAP 1nM', 'CCAP 3nM', 'CCAP 10nM', 'CCAP 30nM', ...
        'CCAP 100nM', 'CCAP 300nM', 'CCAP 1μM', 'Washout', 'Baseline','CCAP 1nM', 'CCAP 3nM', 'CCAP 10nM', 'CCAP 30nM', ...
        'CCAP 100nM', 'CCAP 300nM', 'CCAP 1μM', 'Washout'};
%%
acclimation = pageCold;

store = NaN(length(acclimation), 18);

for p = 1:length(acclimation)

    page = acclimation(p);
    metadata = metadataMaster;
    filename = "/Volumes/marder-lab/skedia/KAS_sorted/" + nb + "_" + page + "_bursts_allcells.mat";
    load(filename);
    allbursts = all_burst_data;
    clear all_burst_data
    
    % Set which files to do analysis on 
    files = metadata(nb, page).files - 1;
    files = files(2:end);
    files = [files (metadata(nb, page).files(end) + 1) ];
    c = [metadata(nb, page).dose_names metadata(nb, page).dose_names];
    
    numConditions = length(files) / 2;
    
    
    PD = allbursts.PD.burst_data;
    windows = allbursts.PD.file_lengths;
    
    % Set windows to look for burst starts from 
    for i = 1:length(files)
        file = files(i);
        wStart = sum(windows(1:file));
        wEnd = sum(windows(1:file + 1));
    
        burstStarts = PD.firstSp > wStart & PD.firstSp < wEnd;
        freq = PD.BuFreq(burstStarts);
        meanFreq = mean(freq);
        stErrFreq = std(freq) / sqrt(length(freq));
        
        j = i;
        while ~strcmp(c{i}, ALLCOND{j})
            j = j + 1;
        end

        store(p, j) = meanFreq;
        
    end

    % Reorganize so that 10 deg data is before
    if metadata(nb, page).cond{1} == "20°C"
        temp = store(p, 1:numConditions);
        store(p, 1:numConditions) = store(p, numConditions+1:end);
        store(p, numConditions+1:end) = temp;

    end

end

% Average out data
storeMeans = mean(store, "omitnan");
%%

[storeMeansHot, errHot] = dosePlotsHelper(pageHot);
[storeMeansCold, errCold] = dosePlotsHelper(pageCold);



dn = metadata(nb, 105).dose_names;
x = categorical(dn);
x = reordercats(x, dn);


valsHot = [storeMeansHot(1, 1:9); storeMeansHot(1, 10:end)];
valsCold = [storeMeansCold(1, 1:9); storeMeansCold(1, 10:end)];

% Make a figure for 10 deg hot and cold animals
figure
title("PD Burst Frequency at 10°C")
ylabel("PD Burst Frequency (Hz)")
hold on

%plot(x, vals, "-o", "LineWidth", 2);

shadedErrorBar(1:9, valsCold(1,:), errCold(1:9), 'lineprops', '-b')
shadedErrorBar(1:9, valsHot(1,:), errHot(1:9), 'lineprops', '-r')


l = legend({"4°C Acclimation", "18°C Acclimation"}, 'AutoUpdate','off');
l.Location = "eastoutside";

% for i = 1:length(acclimation)
%     scatter(x, store(i, 1:9), "blue")
%     scatter(x, store(i, 10:18), "red")
% end

% lovely lovely formatting
set(findall(gcf,'-property','fontname'),'fontname','arial')
set(findall(gcf,'-property','box'),'box','off')
set(findall(gcf,'-property','fontsize'),'fontsize',17)
