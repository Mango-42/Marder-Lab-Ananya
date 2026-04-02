function [nerves] = loadBurstStats(targetNotebook, targetPage, range)
% Description: loads burst stats separated by abf file

% Inputs:
    % targetNotebook (int) - notebook
    % targetPage (int) - page
    % metadata (structure) - run metadataMaster and ensure it has metadata
    % for the requested notebook and page 

% Outputs: 
    % data (structure) - has the following structure (lol), with lvn, pdn,
    % and pyn fields as are present in the nerve recordings / spikes

 
    % data--|_lvn: { } x number of abf files that are sorted
    %       |_ pdn: { } x number of abf files that are sorted
    %       |_ pyn: { } x number of abf files that are sorted
    %       |_ all: { } x number of abf files that are sorted

    % Each cell for lvn, pdn, and pyn contains a structure activity which
    % stores (for that file) all...
            % interburst frequencies (1 / interburst intervals)
            % intraburst frequencies (1 / intraburst intervals)
            % duty cycles of that neuron
            % spikes per burst 
            
    % Each cell for the 'all' field holds robustness data (to be
    % implemented)

%%
filename = "/Volumes/marder-lab/adalal/MatFiles/" + targetNotebook + "_" ...
    + targetPage + "_burst.mat";


% if you already have analysis, just load it 
if exist(filename, "file")
    load(filename, 'nerves');

% otherwise call on burstAnalysis.m to get stats per abf file 
else
    metadataMaster
    analysis = matfile(filename,'Writable',true);
    temps = metadata(targetNotebook, targetPage).tempValues;

    % set which files you want to get
    if isequal(range, "roi")
        files = metadata(targetNotebook, targetPage).tempFiles;
    elseif isequal(range, "crash")
        [~, idxMax] = max(metadata(targetNotebook, targetPage).tempValues);
        fileCrash = metadata(targetNotebook, targetPage).tempFiles(idxMax);
        fileBefore = fileCrash - 2;
        files = fileBefore:fileCrash;
    end

    disp(files)

    % sometimes abf files on experiments aren't reset to 0 hhhhhhh
    if ~isempty(metadata(targetNotebook, targetPage).abfOffset)
        files = files - metadata(targetNotebook, targetPage).abfOffset;
    end

    disp(files)
    spikes = getSpikeTimes("auto", targetNotebook, targetPage, range);
    data = loadExperiment(targetNotebook, targetPage, range);

    % double check that temperatures are close enough to expected values!!
    if isequal(range, "roi")
        for i = 1:length(files)
    
            if mean(data.temp{i}) > 1 + temps(i) || ...
                mean(data.temp{i}) < temps(i) - 1
    
                warning("file " + files(i) + " does not appear to match expected " + ...
                    "temp of " + temps(i))  
            end
    
        end
    end

    nerves = struct;
    
    for i = 1:length(files)

        % Get activity data from that file
        % Assume you're not sorting multiple nerves on lvn or something 
        if isfield(spikes, 'LP') && isfield(data, 'lvn')
            [activity] = burstAnalysis(spikes.LP{i}, "LP", data.lvn{i});

            nerves.lvn{i} = activity;
        end

        if isfield(spikes, 'PD') && isfield(data, 'pdn')
            [activity] = burstAnalysis(spikes.PD{i}, "LP", data.pdn{i});

            nerves.pdn{i} = activity;
        end 

        if isfield(spikes, 'PY') && isfield(data, 'pyn')
            [activity] = burstAnalysis(spikes.PY{i}, "PY", data.pyn{i});

            nerves.pyn{i} = activity;
        end 

        if isfield(spikes, 'LG') && isfield(data, 'lgn')
            [activity] = burstAnalysis(spikes.LG{i}, "LG", data.lgn{i});

            nerves.lgn{i} = activity;
        end 

        % Get robustness data from that file 
        % [robustness] = getRobustness(spikes, data)
        % nerves.all{i+1} = robustness
    end

    analysis.nerves = nerves;

    load(filename, 'nerves')
end