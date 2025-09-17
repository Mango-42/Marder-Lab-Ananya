function [on, activity, spikeInfo] = findBursts(spikeTimes, v)
%%
Fs = 10000;

t = (0:length(v) - 1) / Fs;
locs = spikeTimes;

if isempty(spikeTimes)
    
    on = zeros([1 length(t)]);
    activity = struct();
    activity.burstStarts = [];
    activity.burstEnds = [];
    activity.dutyCycle = [];
    activity.spikesPer = [];
    return
end


peaks = v(int64(spikeTimes * Fs + 1));


%%
isi = diff(locs);
% approx the isi at the start and end
isi = [locs(1) isi (120 - locs(end))];
isiBefore = isi(1:end - 1);
isiAfter = isi(2:end);
% peaks = peaks(2:end-1);
% locs = locs(2:end-1);

inputIsi = [];
inputIsi(:, 1) = isiBefore;
inputIsi(:, 2) = isiAfter;
inputIsi(:, 3) = isiBefore - isiAfter;
%inputIsi(:, 4) = (isiBefore ./ isiAfter) > 5;

inputIsi = normalize(inputIsi, 1);


rng(1)
eva = evalclusters(inputIsi,'kmeans','DaviesBouldin','KList',1:6);
k = eva.OptimalK;
[labels, centroids] = kmeans(inputIsi, k);

%     labels = dbscan(inputIsi, .5, 5);

%     inputIsi = inputIsi(labels ~= -1, :);
%     locs = locs(labels ~= -1);
%     peaks = peaks(labels ~= -1);
%     labels = labels(labels ~= -1);

%     labels(labels == -1) = max(labels) + 1;
% 
%     disp(size(labels))
%     disp(size(inputIsi))
%     centroids = splitapply(@mean,inputIsi,labels);



types = {};
k = length(centroids(:, 1));

for i = 1:k

    % Testing avg point of the clusters: is there a big diff between isi Before
    % and after?
    if centroids(i, 3) > .2
        types{i} = "Start";
    elseif centroids(i, 3) < -.2
        types{i} = "End";
    % Interspike ones should occur with some frequency
    elseif sum(labels == i) / sum(labels) > 0.05
        types{i} = "Inside";
    else
        types{i} = "Suspicious";
    end
    
end

% Look for other possible suspicious spikes -- this whole thing is not
% working LMAO
% (multiple starts, multiple ends next to each other)

types{k+1} = "Suspicious";

foundStart = 0;

for i = 1:length(labels)
    
    if types{labels(i)} == "Start" && foundStart == 0
        lastStart = i;
        foundStart = 1;
    % multiple starts without an end between them
    elseif types{labels(i)} == "Start" 
        labels(lastStart) = k+1;
        foundStart = 1;
    
    % ends without a start 
    elseif types{labels(i)} == "End" && foundStart == 0
        foundStart = 0;
        labels(i) = k+1;
    elseif types{labels(i)} == "End" 
        foundStart = 0;

    end

end

% Look for things that may be deidentified as bursts 
% and flag the first / last non sus spike as a start and end!
% TODO
%% Check that peaks plot correctly
figure

gscatter(locs, peaks, labels, [], [], 10)
hold on
plot(t, v, 'k-')


legend(types)

%% Calculate duty cycles given the starts and ends
burstStarts = [];
burstEnds = [];
spikesPer = [];

countInnerSpikes = 0;
currSpikesPer = 0;

for i = 1:length(labels)

    if types{labels(i)} == "Start" 
        burstStarts = [burstStarts, locs(i)];
        countInnerSpikes = 1;
        currSpikesPer = 1;

    elseif types{labels(i)} == "Inside" 
        currSpikesPer = currSpikesPer + 1;

    elseif types{labels(i)} == "End" 
        burstEnds = [burstEnds, locs(i)];
        countInnerSpikes = 0;
        currSpikesPer = currSpikesPer + 1;
        spikesPer = [spikesPer currSpikesPer];
    end

end

% if burst isn't finished at the end, trim off the last value
burstStarts = burstStarts(1:length(burstEnds));
spikesPer = spikesPer(1:length(burstEnds));
dutyCycle = burstEnds - burstStarts;


on = zeros([1 length(t)]);
% make a vector that shows when the neuron is firing 
for i = 1:length(burstStarts)
    on(int64(burstStarts(i) * Fs):int64(burstEnds(i) * Fs)) = 1;
end

activity = struct();
activity.burstStarts = burstStarts;
activity.burstEnds = burstEnds;
activity.dutyCycle = dutyCycle;
activity.spikesPer = spikesPer;
%% Get info about each spike (in a burst, new burst, or suspicious)
spikeInfo = struct();

spikeInfo.spikeTimes = locs;
burstNum = [];
currNum = 0;
for i = 1:length(locs)

    if types{labels(i)} == "Start" 
        currNum = currNum + 1;
        burstNum = [burstNum, currNum];
    elseif types{labels(i)} == "Inside" || types{labels(i)} == "End"
        burstNum = [burstNum, currNum];
    elseif types{labels(i)} == "Suspicious"
        burstNum = [burstNum, -1];
    end
end

spikeInfo.burstNum = burstNum;