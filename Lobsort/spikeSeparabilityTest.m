% Measure separability of spikes based on assigned label vs actual label
% (just LP)

nb = 992;
page = 96;
spikesFile = "/Volumes/marder-lab/adalal/MatFiles/" + nb + "_" + page + "_spikes.mat";

spikes = load(spikesFile);
spikes = spikes.spikes;

allTp = [];
allFp = [];
for i=1:length(spikes)
    s = spikes{i};
    if isfield(spikes{i}, 'LP')
        fileNum = spikes{i}.fileNum;
        lpSpikes = spikes{i}.LP;
        data = loadExperiment(nb, page, fileNum);
        [spikeGroups, ~] = sortSpikesByBurst(data.lvn{1});

        [tp, fp] = separability(lpSpikes, spikeGroups);
        disp("True Positive Rate:" + tp)
        disp("False Positive Rate:" + fp)
        allTp = [allTp tp];
        allFp = [allFp fp];


%         figure
%         plot(lpSpikes, ones([length(lpSpikes), 1]), 'o')
%         hold on
%         plot(spikeGroups.spikeTimes6 + .0001, ones([length(spikeGroups.spikeTimes6), 1]), 'o')
    end
end

function [tp, fp] = separability(realTimes, spikeGroups)
    
% treating true positive as is LP and marked as LP
% false positive as not LP but marked as LP
    markedAsTrue = [];
    markedAsFalse = [];
    fn = fieldnames(spikeGroups);
    for k = 1:length(fn)

        group = spikeGroups.(fn{k}) + .0001;
        groupLength = length(group);
        
        intx = intersect(realTimes, group);
        if length(intx) > .5 * groupLength
            markedAsTrue = [markedAsTrue group];
        else
            markedAsFalse = [markedAsFalse group];
        end

    end


    tp = length(intersect(markedAsTrue, realTimes)) / length(realTimes);
    fp = length(intersect(markedAsFalse, realTimes)) / length(realTimes);
end