function [spikeGroups, data] = sortSpikes(v, varargin)

    %% Description: Sorts spikes from two neurons given raw trace

    % Inputs:
        % v (double []): your recorded nerve trace

    % Optional args (paired):
        % spikeTimes (double[]): see below field
        % !
        % keep (bool): - 0 (filter above out) vs 1 (use these spikes)

        % sortOn (bool): 0 (don't sort, I only need the features) vs 1 (default)
        % !
        % livelabel (bool): - 0 (default) vs 1 (show and let me label my spike
            % groups in miniSpikesPipeline.m)
 

       % Valid signatures include
        % sortSpikes(v)
        % sortSpikes(v, spikeTimes, keep), 
        % sortSpikes(v, sortOn, livelabel), 
        % sortSpikes(v, spikeTimes, keep, sortOn, livelabel)

    % Outputs:
        % spikeGroups - use miniSpikesPipeline to label sequentially

        % data (2D double []): if you want access to the raw features for the spikes

    % Note these spike groups do not have names as there is no expected
    % neuron type. 

    % Method:

    % This function can run through getExtraSpikes.m to detect spikes first.

    % It sorts spikes by clustering them by the following properties:
    
    % Amplitude: spike amp, avg amp of the burst, stdev of amp in burst
    % Isi: spike isi, average isi in the burst, stdev of isi in burst

    % Waveform shape: v through 3 ms before/after the spike 
    % Waveform shape: Average shape of the spikes in the burst

    % Length of burst and number of spikes in the burst TBA

    % Previously, sorting was done in crabsort just using spike waveform
    % shape. 


%% Get spike times and changes
    close all
 

    Fs = 10^4;
    win = 3*10^-3; % Use a window size for shape of 3 ms;
    shapeSize = 2 * (win * Fs) + 1; % +1 for the spike itself 
    
    sortOn = 1;
    livelabel = 0;
    
    if nargin == 1
        [spikeTimes] = getExtraSpikes(v); 
    
    % give spike times to filter by (keep on or off)
    elseif nargin >= 3 && length(varargin{1}) > 1 && varargin{2} == 0
        [spikeTimes] = getExtraSpikes(v, varargin{1});

    % give spike times to use
    elseif nargin >= 3 && length(varargin{1}) > 1 && varargin{2} == 1
        spikeTimes = varargin{1};
    end

    if nargin > 1 && length(varargin{1}) == 1
      [spikeTimes] = getExtraSpikes(v); 
      sortOn = varargin{1};
      livelabel = varargin{2};
    end

    if nargin > 3
      sortOn = varargin{3};
      livelabel = varargin{4};
    end



    

    [spikeInfo] = findSpikeChanges(v, spikeTimes);
    if isempty(spikeTimes) || isempty(spikeInfo.burstNum)
        spikeTimes1 = [];
        spikeTimes2 = [];
        return
    end
    
%% Get spike and burst features
    oldV = v; % Make a copy of v
    
    % Add buffer around the sides so you can get window up to 10 ms
    v = [ zeros([1 1000]) v zeros([1 1000]) ];

    idxSpikes = int64(spikeTimes * Fs) + 1001;
    

   amp = v(idxSpikes);
   shape = [];
   isiSmaller = [];

   % Get shape of each spike and negative peak
   for i = 1:length(idxSpikes)
        shape(i, :) = v( (idxSpikes(i) - win*Fs ):(idxSpikes(i) + win*Fs) );
   end

    tempV = [ zeros([1 1000]) v zeros([1 1000]) ];
    for i = 1:length(idxSpikes)
        shape(i, :) = tempV( (idxSpikes(i) - win*Fs ):(idxSpikes(i) + win*Fs) );
    end
    
    negAmp = min(shape, [], 2);


   % Get isi; expand to have an "isi" for first and last spike
   isi = diff(spikeTimes);
   
   if ~isempty(spikeTimes)
    isi = [spikeTimes(1) isi length(v)/ Fs - spikeTimes(end)];
   end

   % Makes sure you're only using spike freq, not burst freq
   for i = 1:length(spikeTimes)
        beforeIsi = isi(i);
        afterIsi = isi(i + 1);       
        isiSmaller(i) = min([beforeIsi afterIsi]);
   end


   neighborShape = zeros([length(spikeTimes) shapeSize]);
   neighborAmp = [];
   neighborStd = [];
   neighborIsi = [];
   neighborStdIsi = [];
   numSpikes = [];

    % Gather relevant stats for each spike
   for i = 1:length(spikeTimes)

       % Aberrant spikes
       if spikeInfo.burstNum(i) == -1
           simWave = shape(i);
           simAmp = amp(i);
           simStdAmp = 0;
           simIsi = isiSmaller(i);
           simStdIsi = 0;


       % Find the 5 nearest spikes in the same burst (to account for
       % occasional poor burst detection pre-sorting)
       else
            
            idx = find(spikeInfo.burstNum == spikeInfo.burstNum(i));
            distance = abs(spikeInfo.spikeTimes(idx) - spikeInfo.spikeTimes(i));
            [~, idxMin] = sort(distance);
            idx = idx(idxMin <= 5);
            
            numSpikes = [numSpikes length(idx)];
            simWave = mean(shape(idx, :));
            simAmp = median(amp(idx));
            simStdAmp = std(amp(idx));
            simIsi = median(isiSmaller(idx));
            simStdIsi = std(isiSmaller(idx));

       end
       neighborShape(i, :) = simWave;
       neighborAmp(i) = simAmp;
       neighborStd(i) = simStdAmp;
       neighborIsi(i) = simIsi;
       neighborStdIsi(i) = simStdIsi;
    
   end
   
    % Assemble collected spike info and mean info of spikes in the same burst
    % into a set for dim reduction
    data  = zeros([length(spikeTimes), 8 ]);%shapeSize*2 + 6]);
    
    data(:, 1) = numSpikes;
    data(:, 2) = simAmp;
    data(:, 3) = neighborStd;
    data(:, 4) = isiSmaller;
    data(:, 5) = neighborIsi;
    data(:, 6) = neighborStdIsi;
    data(:, 7) = amp;
    data(:, 8) = negAmp;
    
%     data(:, 7:7 + shapeSize - 1) = shape;
%     data(:, 7+shapeSize:end) = neighborShape;


%% If you're not sorting, terminate early

if sortOn == 0
    spikeGroups = 0;
    return
end

    
 %% Cluster on dimensionality reduced data
   rng(1);
   reduced = tsne(data, 'Standardize', 1);
%    eva = evalclusters(reduced,'kmeans','DaviesBouldin','KList',1:3);
%    k = eva.OptimalK;
% 
%    labels = kmeans(reduced, k + 1, 'Replicates', 5);


    labels = clusterdata(reduced, MaxClust = 6);




%% Create a structure to hold spike times of different groups
spikeGroups = struct();
for i = 1:max(labels)
    spikeGroups.("spikeTimes" + i) = spikeTimes(labels == i);
    
end

% Final figure
figure
v = oldV;
t = (0:length(v) - 1) / Fs;

gscatter(spikeTimes, amp, labels, [], [], 10)
hold on
plot(t, v, 'k-')

% Projection, for debugging purposes

% figure
% gscatter(reduced(:, 1), reduced(:, 2), labels)


%% Give option to label each burst by max spike label (sometimes gets rid of noise)

if livelabel == 0
    return
end
prompt = "Label each burst by max label? Y/N";
x = input(prompt, "s");

if x == "Y"

    %Label such that each burst has spikes of most common type
       for i = 1:length(labels)
                
                idx = find(spikeInfo.burstNum == spikeInfo.burstNum(i));
                %distance = abs(spikeInfo.spikeTimes(idx) - spikeInfo.spikeTimes(i));
                %[~, idxMin] = sort(distance);
                %idx = idx(idxMin <= 5);
    
                newLabel = mode(labels(idx));
    
     %      end
           newLabels(i) = newLabel;
           
       end
    
       labels = newLabels;

       gscatter(spikeTimes, amp, labels, [], [], 10)

end



%% Label groups 
prompt = "type neuron and its group number, i.e. LP 2: ";
x = "";

while x ~= "exit"

    x = input(prompt, "s");
    x = split(x);


    if x == "exit"
        break
    end
    
    allSpikes = [];
    for i = 2:length(x)
        allSpikes = [allSpikes spikeGroups.("spikeTimes" + x{i})];
        spikeGroups = rmfield(spikeGroups,"spikeTimes" + x{i});
        allSpikes = sort(allSpikes);
    end
    spikeGroups.(x{1}) = allSpikes;
end   






