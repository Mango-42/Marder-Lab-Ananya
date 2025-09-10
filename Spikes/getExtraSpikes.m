function [spikes] = getExtraSpikes(v, varargin)
    %% Detect extracellular spikes, and optionally use another neuron's spike times as a filter
   
    % getExtraSpikes(v)
    % getExtraSpikes(v, filterSpikes)

    % Inputs:
        % v (double []) - the voltage signal
        % filterSpikes - spike times of another neuron on v. dont return spikes
        % near these ones

    % Outputs:
        % spikes (double []) - detected spike times
    %%
    Fs = 10^4;
    
    time = 1/Fs * (0:length(v) - 1);

    title("All peaks detected")
    [pks,locs,~,p] = findpeaks(v, time, "MinPeakDistance", .01, "MinPeakProminence",0.01);
    
    % If nothing detected, return early
    if isempty(pks)
        spikes = [];
        return
    end

    % Remove high spikes from rig noise
    pks = pks(pks < 5);
    locs = locs(pks < 5);
    p = p(pks < 5);

    % Remove spikes overlapping from another neuron
    if nargin == 2
        filterSpikes = varargin{1};

        for i = filterSpikes
            locs(locs > i - 0.02 & locs< i + 0.02) = 0;
        end
    
        idx = find(locs);
        locs= locs(idx);
        pks = pks(idx);
        p = p(idx);

    end 

    % Cluster the data using peak height and prominence
    inputClustering = [];
    inputClustering(:, 1) = pks;
    %inputClustering(:, 2) = p;

    % Make outliers another category (probably legit peaks, just few of them)
    %e = clusterDBSCAN.estimateEpsilon(inputClustering, 5,length(inputClustering))

%     labels = dbscan(inputClustering, .0025, 5);
%     numCats = max(labels);
%     labels(labels == -1) = numCats + 1;

    rng(1);
    eva = evalclusters(inputClustering,'kmeans','silhouette','KList',1:6);
    k = eva.OptimalK;
    [labels, C] = kmeans(inputClustering, k);
    %numCats = max(labels);
    %labels(labels == -1) = numCats + 1;

    % Find the cluster with the least peak height and treat this as your
    % baseline. Start with the set of all peaks, and remove cluster with 
    % least peak height and any points that are not significantly higher
    % than your baseline
     %C = splitapply(@mean,inputClustering,labels)
    
    
     [~, noiseCluster] = min(C);

     pks = pks(labels ~= noiseCluster);
     locs = locs(labels ~= noiseCluster);
     labels = labels(labels ~= noiseCluster);
     peak = pks;
     spikes = locs;

    % Finally, make sure to just remove any low peaks below std
% 
    stdev = std(peak);
    avg = mean(peak);

    idx = peak > avg - 3 * stdev;
    peak = peak(idx);
    spikes = spikes(idx);

    figure
    hold on
    plot(time, v);
    scatter(spikes, peak);
    title(length(peak) + " peaks detected")
    







    

