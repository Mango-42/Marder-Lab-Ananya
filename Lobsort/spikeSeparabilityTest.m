% Measure separability of spikes based on assigned label vs actual label
% (just LP)

nb = 998;
page = 128;
spikesFile = "/Volumes/marder-lab/adalal/MatFiles/" + nb + "_" + page + "_spikes.mat";
ratesFile = "/Volumes/marder-lab/adalal/MatFiles/sort/" + nb + "_" + page + "_ratesShape.mat";

spikes = load(spikesFile);
spikes = spikes.spikes;

allTp = [];
allFp = [];
allTn = [];
allFn = [];
accuracy = [];
ratio = [];

for i=1:length(spikes)
    s = spikes{i};
    if isfield(spikes{i}, 'LP')
        fileNum = spikes{i}.fileNum;
        lpSpikes = spikes{i}.LP;
        data = loadExperiment(nb, page, fileNum);
        [spikeGroups, ~] = sortSpikesByShape(-data.lvn{1});

        [tp, fp, tn, fn, a, r] = separability(lpSpikes, spikeGroups);
        disp("Accuracy:" + a)
        allTp = [allTp tp];
        allFp = [allFp fp];
        allTn = [allTn tn];
        allFn = [allFn fn];
        accuracy = [accuracy a];
        ratio = [ratio r];

        figure
        cdata = makeContinuous(data);
        plot(cdata.t, cdata.lvn);
        hold on
        plot(lpSpikes, cdata.lvn(int64(lpSpikes * 10^4) + 1), 'o')
        hold on
        sg = spikeGroups.spikeTimes2;
        plot(sg, cdata.lvn(int64(sg * 10^4) + 1), 'o')
        title("debugging baby")
        %plot(spikeGroups.spikeTimes4 + .0001, ones([length(spikeGroups.spikeTimes4), 1]), 'o')
    end
end
    rates = matfile(ratesFile,'Writable',true);
    rates.tp = allTp;
    rates.fp = allFp;
    rates.tn = allTn;
    rates.fn = allFn;
    rates.accuracy = accuracy;
    rates.ratio = ratio;

function [tp, fp, tn, fn, accuracy, ratio] = separability(realLP, spikeGroups)


% treating true positive as is LP and marked as LP
% false positive as not LP but marked as LP
    markedAsTrue = [];
    markedAsFalse = [];
    allSpikes = [];
    fields = fieldnames(spikeGroups);
    for k = 1:length(fields)

        group = spikeGroups.(fields{k}) + .0001;
        groupLength = length(group);
        allSpikes = [allSpikes, group];
        
        intx = intersect(realLP, group);
        disp(length(intx))
        if length(intx) > .5 * groupLength
            markedAsTrue = [markedAsTrue group];
        else
            markedAsFalse = [markedAsFalse group];
        end

    end
    
    if(length(intersect(allSpikes, realLP)) < 100)
        warning("uhm?? are you sure these are the same spikes")
    end
    realPD = setdiff(allSpikes, realLP); % Making the assumption of binary classification
    
    tp = length(intersect(markedAsTrue, realLP));
    fp = length(intersect(markedAsTrue, realPD));
    tn = length(intersect(markedAsFalse, realPD));
    fn = length(intersect(markedAsFalse, realLP));
    accuracy = (tp + tn) / length(allSpikes);
    ratio = length(realLP) / length(allSpikes); % what proportion of the spikes are LP? don't want to bother using all LP spike files

end


