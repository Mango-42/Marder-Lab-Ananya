function [spikeGroups, reduced] = sortSpikes(v, varargin)

    %% Description: Sorts spikes from two neurons given raw trace

    % Inputs:
        % v (double []): your recorded nerve trace

    % Optional args:
        % spikeTimes (double[]): have you pre-filtered some spikes (i.e.,
        % removed PD using PDN, and now you just need to sort PY and LP on
        % lvn?). Put these spike times here so they get ignored!

    % Outputs:
        % spikeTimes (group 1)
        % spikeTimes (group 2)

    % Note these spike groups are unlabeled as there is no expected
    % neuron type. 


    % Method:

    % This function runs through getExtraSpikes.m to detect spikes first.

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
    

    if nargin == 2
        [spikeTimes] = getExtraSpikes(v, varargin{1});
    else
        [spikeTimes] = getExtraSpikes(v); 
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

   % Get shape of each spike
   for i = 1:length(idxSpikes)
        shape(i, :) = v( (idxSpikes(i) - win*Fs ):(idxSpikes(i) + win*Fs) );
   end

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
    data  = zeros([length(spikeTimes), shapeSize*2 + 6]);
    
    data(:, 1) = numSpikes;
    data(:, 2) = simAmp;
    data(:, 3) = neighborStd;
    data(:, 4) = isiSmaller;
    data(:, 5) = neighborIsi;
    data(:, 6) = neighborStdIsi;
    
    data(:, 7:7 + shapeSize - 1) = shape;
    data(:, 7+shapeSize:end) = neighborShape;
    
 %% Cluster on dimensionality reduced data
   rng(1);
   reduced = tsne(data, 'Standardize', 1);
%    eva = evalclusters(reduced,'kmeans','DaviesBouldin','KList',1:3);
%    k = eva.OptimalK;
% 
%    labels = kmeans(reduced, k + 1, 'Replicates', 5);


    labels = clusterdata(reduced, MaxClust = 4);


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

figure
gscatter(reduced(:, 1), reduced(:, 2), labels)


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


