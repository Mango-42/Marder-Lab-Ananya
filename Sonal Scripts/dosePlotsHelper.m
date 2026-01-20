function [vals, err, rawData, varargout] = dosePlotsHelper(pages, varargin)

%% Description: Gathers data for dosePlots.m in existing burst analysis
% see burst data files for formatting, i.e., at
% skedia/KAS_sorted/970_109_bursts_allcells.mat


% Can also call for triphasic analysis. 

% Inputs:
    % pages (double []): pages for experiment (nb assumed to be 970)

    % nerve (string): "LP", "PY", or "PD" 
    % analysis (string): see options below 
        % SpikesPerBurst
        % BurstFreq
        % nBursts - number of bursts
        % totalSpikes - total spikes for neuron in an abf file 
        % Triphasic (no nerve arg for this)

% Outputs: 
    % vals (double []): values averaged by page for all conditions 
    % err (double []): stdev of values
    % rawData (double []) mean value for each page across all conditions
        % size is conditions x num pages


if nargin == 3 
    nerve = varargin{1};
    analysis = varargin{2};
end
if strcmp(analysis, "Triphasic")
    nerve = "PD"; %  just to avoid throwing errors
    analysis = "Triphasic";
end


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
tritable = [];
k = 0;

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
        k = k + 1;
        file = files(i);
        wStart = sum(windows(1:file));
        wEnd = sum(windows(1:file + 1));
    
        if strcmp(analysis, "BuFreq") || strcmp(analysis, "nSp")
            burstStarts = neuron.firstSp > wStart & neuron.firstSp < wEnd;
            items = neuron.(analysis)(burstStarts);

        elseif strcmp(analysis, "nBursts")
            burstStarts = neuron.firstSp > wStart & neuron.firstSp < wEnd;
            items = sum(burstStarts);

        elseif strcmp(analysis, "totalSpikes")
            burstStarts = neuron.firstSp > wStart & neuron.firstSp < wEnd;
            items = sum(neuron.nSp(burstStarts)) / 2;
        elseif strcmp(analysis, "Triphasic")

            LP = allbursts.LP.burst_data;
            PY = allbursts.PY.burst_data;
            PD = allbursts.PD.burst_data;

            lp = LP.firstSp(find(LP.firstSp > wStart & LP.firstSp < wEnd));
            py = PY.firstSp(find(PY.firstSp > wStart & PY.firstSp < wEnd));
            pd = PD.firstSp(find(PD.firstSp > wStart & PD.firstSp < wEnd));

            [items, t] = testTriphasic(lp, py, pd);

            t = table2array(t);
            t = t(:)';
            tritable(k, 1:9) = t;

        end

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
varargout{1} = tritable;
