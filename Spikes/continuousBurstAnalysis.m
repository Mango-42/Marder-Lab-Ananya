nb = 998;
page = 35;
data = loadExperiment(nb, page, "continuousRamp");
%% Detect and sort spikes by labeling detected clusters
close all
spikes = {};

% Run this in parallel to split up work on your cpu
for i = 1:4 % your number of CONTINUOUS files.. technically not correct rn
    [spikeGroups] = sortSpikes(data.lvn{i});
    spikes{i} = spikeGroups;
end


% Label the neurons
for i = 1:4
    
    prompt = "type neuron and its group number, i.e. LP 2: ";
    figure(i)
    x = input(prompt, "s");
    x = split(x);
    spikeGroups = spikes{i};

    % Replace the name of the field with the neuron name
    spikeGroups.(x{1}) = spikeGroups.("spikeTimes" + x{2});
    spikeGroups = rmfield(spikeGroups,"spikeTimes" + x{2});
    
    spikes{i} = spikeGroups;
end
spikeTimes = struct();

% Reorganize spikeTimes so its in the same format as data 
fn = "LP";
for i = 1:length(spikes)
    for name = fn
        spikeTimes.(name){i} = spikes{i}.(name);

    end
end

% Make your spikes continuous across files
[cdata, cspikes] = makeContinuous(data, spikeTimes);

% Detect bursts
[~, burstInfo] = detectBursts(cspikes.LP);

%% Wrap temperature data and and condition (saline, mod) metadata in
Fs = 10^4;
burstInfo.temp = cdata.temp(int64(burstInfo.burstStarts * Fs));


