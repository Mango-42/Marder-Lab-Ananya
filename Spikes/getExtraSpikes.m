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
    Fs = .0001;
    
    time = Fs * (0:length(v) - 1);
    %figure
    %findpeaks(v, time, "MinPeakDistance", .01, "MinPeakProminence",0.01, "MinPeakHeight", mean(v));
    title("All peaks detected")
    [pks,locs,~,p] = findpeaks(v, time, "MinPeakDistance", .01, "MinPeakProminence",0.01, "MinPeakHeight", mean(v));
    
    if isempty(pks)
        spikes = [];
        return
    end

    % Remove spikes from rig noise
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
    inputClustering(:, 2) = p;
    % avg peak height of neighbors
    %inputClustering(:, 3) = movmean(pks, 10);

%     eva = evalclusters(inputClustering,'kmeans','silhouette','KList',1:2);
%     k = eva.OptimalK;
%     
%     % Nice spike detection, only one cluster
%     if k == 1
%         spikes = locs;
%         % If your "spikes" are too close together then you're probably
%         % just detecting baseline. 
% 
%         % threshold if min frequency (max isi) is greater than 5Hz
%         if 1 / max(diff(spikes)) > 5
%             spikes = [];
%         end
% 
%         return
% 
%     end
%     
%     % Otherwise, you might need to remove some spikes
%     [labels, C] = kmeans(inputClustering, k);

    labels = dbscan(inputClustering, .01, 5);

     % if num clusters < 2 recheck epsilon

 
     inputClustering = inputClustering(labels ~= -1, :);
     pks = pks(labels ~= -1);
     locs = locs(labels ~= -1);
     labels = labels(labels ~= -1);
%      
%      % if you only have one cluster assume it's everything
%      if max(labels) == 1
%          spikes = locs;
%          peak = pks;
% 
%      % Merge centroids down to two clusters for intracellulars. one noise,
%      % one spikes. only look at peak height here
%      else
%         C = splitapply(@mean,inputClustering,labels);
%         
% 
%      
% 
%         [labelsK] = kmeans(C(:, 1), 2);
%         newlabels = zeros([length(labels) 1]);
%     
%         for i = 1:length(labelsK)
%             newlabels(labels == i) = labelsK(i);
%         end
%     
%         labels = newlabels;
%         
%         % Fix to new centroids
%         C = splitapply(@mean,inputClustering,labels);
%     
%     %%
%     
%         cluster1 = struct;
%         cluster1.peak = C(1, 1);
%         cluster1.prom = C(1, 2);
%     
%         cluster2 = struct;
%         cluster2.peak = C(2, 1);
%         cluster2.prom = C(2, 2);
%        
% 
% 
% 
%     % See if both clusters have similarly high peaks, or one is
%     % just low level oscillations. Only return the clusters that have true
%     % spikes
% 
%     if cluster1.peak > mean(v) + 3 * std(v) && cluster2.peak > mean(v) + 3 * std(v)
%         % cluster one has higher peaks
% 
%         spikes = locs;
%         peak = pks;
% 
%     elseif cluster1.peak > mean(v) + 3 * std(v) && cluster1.prom > cluster2.prom
%         % cluster two has higher peaks
%         spikes = locs(labels == 1);
%         peak = pks(labels == 1);
% 
%     elseif cluster2.peak > mean(v) + 3 * std(v) && cluster2.prom > cluster1.prom
%         spikes = locs(labels == 2);
%         peak = pks(labels == 2);
%     else
%         spikes = [];
%         peak = [];
%     end

%% thought of something kinda cursed. but there will always be way more noise level points
% than any actual spikes so as long as they cluster differently you should
% just remove the category with the most "spikes." LMAO?



     %end

     noiseCluster = mode(labels);
    disp(unique(labels))
     pks = pks(labels ~= noiseCluster);
     locs = locs(labels ~= noiseCluster);
     labels = labels(labels ~= noiseCluster);
     peak = pks;
     spikes = locs;

    % Finally, make sure to just remove any low peaks below std

    stdev = std(peak);
    avg = mean(peak);

    idx = peak > avg - 4 * stdev;
    peak = peak(idx);
    spikes = spikes(idx);

    figure
    hold on
    plot(time, v);
    scatter(spikes, peak);
    title(length(peak) + " peaks detected")
    







    

