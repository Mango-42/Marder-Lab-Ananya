function [group] = findSpikeChanges(v)
%% Look for changes in spike patterns
% Nonspecific detection of burst starts, ends, and changes in amplitude and
% spike density -- functions as a vague burst detector bc it is hard to be
% specific sometimes

% Does not account for concurrent bursts (i.e. LG at the same time as
% triphasic), so you'll have to rely on other factors in sortSpikes for
% that
%%
Fs = 10^4;

spikeTimes = getExtraSpikes(v);

changes = zeros([1 length(spikeTimes)]);

% First look for potential burst starts and ends by long ISIs
isi = diff(spikeTimes);

if ~isempty(spikeTimes)
isi = [spikeTimes(1) isi length(v)/ Fs - spikeTimes(end)];
end

% Look for a cluster with the biggest isi-- likely starts and ends
eva = evalclusters(isi','kmeans','DaviesBouldin','KList',2:3);
k = eva.OptimalK;

[labels, C] = kmeans(isi', k);
[~, idxMax] = max(C);
[~, idxMin] = min(C);

% Changes in isi (label as 1)
changes(labels == idxMax) = 1;
isChangeInISI = changes;

% % Look for lasting changes in spike density
% [~, idxMin] = min(C);
% 
% range = 3 * isi(labels == idxMin);
% 
% 
% for i = 1:length(spikeTimes)
%     
% end


% Look for changes in amplitude (helpful for back-to-back transitions)
idxSpikes = int64(spikeTimes * Fs) + 1;
amp = v(idxSpikes);

% Set range of how many neighbors to look at on each side
% If the left and right side amplitudes are more different than the spike
% to its right or left AND the l - r is a large difference on its own then
% probsa transition

thresh = mean(abs(diff(amp))) + 1 * (std(abs(diff(amp))));
neighbors = 2;


for i = neighbors + 1:length(spikeTimes) - 1 - neighbors
    l = mean(amp(i - neighbors: i - 1));
    r = mean(amp(i + 1: i + neighbors));
    % abs(l - r) > max([abs(amp(i) - l) abs(amp(i) - r)])
    if abs(l - r) > thresh        
        changes(i) = 2;
    end

end


% do the same on spike density

% thresh = mean(isi(labels == idxMin)) + 1 * std(isi(labels == idxMin));
% 
% for i = neighbors + 1:length(spikeTimes) - 1 - neighbors
%     l = mean(isi(i - neighbors: i - 1));
%     r = mean(isi(i + 1: i + neighbors));
%     % abs(l - r) > max([abs(amp(i) - l) abs(amp(i) - r)])
%     
% % this makes no sense you need to think of a better measure
%     if abs(l - r) > thresh        
%         changes(i) = 3;
%     end
% end


% movStd = movstd(amp, 3);
% 
% [~, idx] = findpeaks(movStd, "MinPeakHeight", mean(movStd));
% 
% 
% 
% 
% % Changes in amplitude (label as 2)
% changes(idx) = 2;


changes(changes ~= 0) = 1;

trueChanges = zeros([1 length(spikeTimes)]);

% Find where changes start (0 -> 1 on changes)
changeStarts = zeros([1 length(spikeTimes)]);
for i = 1:length(changes) - 1

    if changes(i) == 0 && changes(i + 1) == 1
        changeStarts(i + 1) = 1;
    end   

end
% Group spikes that are changes in a row and find a separating point
% ie, spikes from this point on are more similar to the following ones 
idxChanges = find(changeStarts);
for i = 1:length(idxChanges)

    currIdx = idxChanges(i);
    spikesToSplit = idxChanges(i);
    endGroup = 0;

    currIdx = currIdx + 1;
    while endGroup == 0
        if changes(currIdx) == 1
            spikesToSplit = [spikesToSplit currIdx];
            currIdx = currIdx + 1;
        else
            endGroup = 1;
        end
    end

    % Now that you have a group of spikes to split, look at their nearby
    % ones and find where is the strongest transition 

    % If there is one time transition, then mark that as the only valid
    % transition
    if sum(isChangeInISI(spikesToSplit)) == 1

        trueChanges(spikesToSplit(1):spikesToSplit(end)) = isChangeInISI(spikesToSplit);
    
    % Else find the biggest amplitude change from the left side
    else
    
        ampDiff = [];
        % if length(spikeTimes) >=2 ...? 
        for j = 1:length(spikesToSplit)
            try
                l = abs(amp(spikesToSplit(j)) - amp(spikesToSplit(j) - 1));
            catch
                l = 0;
            end
            ampDiff = [ampDiff l];
        end
    
        [~, idxMaxAmpChange] = max(ampDiff);
        ampDiff = 0 * ampDiff;
        ampDiff(idxMaxAmpChange) = 1;
        trueChanges(spikesToSplit(1):spikesToSplit(end)) = ampDiff;
    end


end



figure()
gscatter(spikeTimes, amp, trueChanges, [], [], 10)
hold on
t = (0:length(v) - 1) / Fs;
plot(t, v, 'k-')



    