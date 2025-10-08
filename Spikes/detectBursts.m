function [burstInfo, activity] = detectBursts(spikeTimes)

% Inputs:
    % spikeTimes (double[])

% Output:
% Same kind of structure that burstAnalysis or findBursts outputs 
% This will hopefully be a cleaner method than either of them...
%%
burstInfo = struct();

% Raw spike times - get burst numbers
if(~isstruct(spikeTimes))

    burstNum = zeros([1 length(spikeTimes)]);
    changes = zeros([1 length(spikeTimes)]);
    isi = diff(spikeTimes);
    
    if ~isempty(spikeTimes)
    isi = [spikeTimes(1) isi ];
    end
    
    % Look for a cluster with the biggest isi-- likely starts
    eva = evalclusters(isi','kmeans','DaviesBouldin','KList',1:3);
    k = eva.OptimalK;
    
    [labels, C] = kmeans(isi', k);
    [~, idxMin] = min(C);

    changes(labels ~= idxMin) = 1;
    
    burstEnds = [(labels ~= idxMin)' 0];
    burstEnds = burstEnds(2:end);


    changes(burstEnds == 1) = 2;
    
    % Every start should have a matching end


    % Label bursts by ISI clustering
    currBurst = 0;
    for i = 1:length(spikeTimes)
        if changes(i) == 1
            currBurst = currBurst + 1;
        end
            burstNum(i) = currBurst;
    end

    
end


% Get avg burst analysis stats 
spikesPer = [];
burstFreq = [];
spikeFreq = [];
timeOn = [];
dCycle = [];
startTimes = [];
lastBurstStart = 0;

currSpikes = 0;

for i = 1:length(spikeTimes)
    % Burst start

    currSpikes = currSpikes + 1;

    if changes(i) == 1
        
        
        currSpikes = 1;
        if lastBurstStart ~= 0
            burstFreq = [burstFreq 1 ./ (spikeTimes(i) - lastBurstStart)];
        end
        lastBurstStart = spikeTimes(i);
   
    % Burst end   
    elseif changes(i) == 2 && lastBurstStart ~= 0
        
        startTimes = [startTimes lastBurstStart];
        timeOn = [timeOn spikeTimes(i) - lastBurstStart];
        
        try
            dCycle = [dCycle (timeOn(end) ./ (spikeTimes(i + 1) - lastBurstStart))];
        end
        spikesPer = [spikesPer currSpikes];
        spikeFreq = [spikeFreq ((currSpikes-1) ./ timeOn(end))];
    end

end

burstInfo.spikeTimes = spikeTimes;
burstInfo.burstNum = burstNum;

activity = struct();
% last burst isn't included by default bc not all these fields can be completed 
activity.burstNum = 1:max(burstNum) - 1;
activity.spikesPer = spikesPer;
activity.spikeFreq = spikeFreq;
activity.dCycle = dCycle;
activity.burstFreq = burstFreq;
activity.burstStarts = startTimes; % Indicator so you can match with other continuous data