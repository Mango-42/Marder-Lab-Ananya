function [vals, err, rawData] = dosePlotsHelper(pages, nerve, analysis)


ALLCOND = {'Baseline','CCAP 1nM', 'CCAP 3nM', 'CCAP 10nM', 'CCAP 30nM', ...
        'CCAP 100nM', 'CCAP 300nM', 'CCAP 1μM', 'Washout', 'Baseline','CCAP 1nM', 'CCAP 3nM', 'CCAP 10nM', 'CCAP 30nM', ...
        'CCAP 100nM', 'CCAP 300nM', 'CCAP 1μM', 'Washout'};

if strcmp(analysis, "SpikesPerBurst")
    analysis = "nSp";
elseif strcmp(analysis, "BurstFreq")
    analysis = "BuFreq";
end


acclimation = pages;

nb = 970;
store = nan([length(acclimation) 18]);

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
    
    
    neuron = allbursts.(nerve).burst_data;
    windows = allbursts.(nerve).file_lengths;
 
    for i = 1:length(files)
        file = files(i);
        wStart = sum(windows(1:file));
        wEnd = sum(windows(1:file + 1));
    
        burstStarts = neuron.firstSp > wStart & neuron.firstSp < wEnd;
        items = neuron.(analysis)(burstStarts)
        meanItems = mean(items);
        if isnan(meanItems)
            meanItems = 0;
        end
        
        j = i;
        while ~strcmp(c{i}, ALLCOND{j})
            j = j + 1;
        end

        store(p, j) = meanItems;
        
    end

    % Reorganize so that 10 deg data is before
    if metadata(nb, page).cond{1} == "20°C"
        temp = store(p, 1:numConditions);
        store(p, 1:numConditions) = store(p, numConditions+1:end);
        store(p, numConditions+1:end) = temp;

    end

end


% Average out data
vals = mean(store, "omitnan");
err = std(store, "omitnan");
rawData = store;