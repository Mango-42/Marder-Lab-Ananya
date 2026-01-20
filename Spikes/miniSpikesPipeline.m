%clearvars
nb = 998;
page = 129;
data = loadExperiment(nb, page, "roi"); %accordingly do ROI or all files
metadata = metadataMaster;

%% OPT 1: Sort spikes
spikes = {};
for i = 1:length(data.lvn)
    spikeGroups = sortSpikes(data.lvn{i});
    spikes{i} = spikeGroups;
end

%% OPT 2: if you already have sorted spike times from crabsort...
files = metadata(nb, page).files;
spikes = {};
for i = 1:length(data.lvn)
    spikeTimes = getSpikeTimes("auto", nb, page, files(i));
    spikes{i}.LP = (spikeTimes.LP{i})';
end

%% OPT 3 unfinished: You just have ALL spike times + sorted because you alr condensed them
files = 0:metadata(nb, page).files(end);
filename = '/Volumes/marder-lab/skedia/KAS_sorted/' + nb + '_' + page + '_KAS_sorted.mat';
spikeTimes = load(filename);

Fs = 10^4;
for i = 1:length(data.lvn)
    lower = i - 1;
    upper = length(data.lvn{i}) / 10^4;

    spikes{i}.LP = spikeTimes.LP( find(spikeTimes.LP > lower & spikeTimes.LP < upper) );
end


%% Get file number

for i = 1:length(data.lvn)
    spikes{i}.fileNum = metadata(nb, page).files(i);
end


% Write spikes to file

filename = "/Volumes/marder-lab/adalal/MatFiles/" + nb + "_" + page + "_spikes.mat";
spikeTimes = matfile(filename,'Writable',true);

spikeTimes.spikes = spikes;


spikes = load(filename, 'spikes');
spikes = spikes.spikes;


% Detect bursts and store info
bursts = {};

for i = 1:length(data.lvn)
    if isfield(spikes{i}, "LP")
        [~, activity] = detectBursts(spikes{i}.LP);

        bursts{i}.burstLP = activity;
    end
end

% Get file number for each burst

for i = 1:length(bursts)
    if isfield(bursts{i}, "burstLP")
        bursts{i}.burstLP.fileNum = metadata(nb, page).files(i) * ones([1 length(bursts{i}.burstLP.burstStarts)]);
    end
    
end


% Get temperature data for each burst
Fs = 10^4;
for i = 1:length(bursts)
    if isfield(bursts{i}, "burstLP")
        
        bursts{i}.burstLP.temp = data.temp{i}(int64(bursts{i}.burstLP.burstStarts *Fs));
        
    end
end



% Make burst data look more continuous even if it is discontinous data, for
% ease of access
f = fieldnames(bursts{end}.burstLP);

burstsCont = struct();

for i = 1:length(f)
    name = f{i};
    burstsCont.LP.(name) = [];
end

for i = 1:length(bursts)
    for j = 1:length(f)
        name = f{j};
        if isfield(bursts{i}, "burstLP")
            burstsCont.LP.(name) = [burstsCont.LP.(name) bursts{i}.burstLP.(name)];
        end
    end
end

% Add condition data
burstsCont.LP.condition = getCondition(nb, page, burstsCont.LP.fileNum);


% Write to file

bursts = burstsCont;
filename = "/Volumes/marder-lab/adalal/MatFiles/" + nb + "_" + page + "_burst.mat";
burstInfo = matfile(filename,'Writable',true);

burstInfo.bursts = bursts;


burstInfo = load(filename);