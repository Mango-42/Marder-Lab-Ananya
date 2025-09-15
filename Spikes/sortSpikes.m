function [newLabels] = sortSpikes(v, varargin)
    %%
    % can either give v (which will request ALL spikes) vs spike times and
    % v, which you can do if you're pre-filtering the data (ie, on lvn, you
    % filter out PD with pdn and then send in PY + LP spikes to be sorted)

    Fs = 10^4;

    if nargin == 2
        spikeTimes = varargin{1};
    else
        [spikeTimes] = getExtraSpikes(v);
    end

    [~, ~, spikeInfo] = findBursts(spikeTimes, v);

    idxSpikes = int64(spikeTimes * Fs) + 1001;
    oldV = v; % make a copy of v and add buffer around the sides so you can get window

    v = [ zeros([1 1000]) v zeros([1 1000]) ];


    % This function sorts spikes by clustering them by the following properties

        % Amplitude of this spike (1 value)
            % Average amplitude of the spikes in the burst (if > 5 spikes in a
            % burst, use the 5 nearest ones)
            % Shape (1000 + 1 + 1000 values)
            % Average shape of the spikes in the burst (if > 5 spikes in a
            % burst, use the 5 nearest ones)
        % Stdev of amplitude of spikes in burst (sometimes it varies a lot
        % vs more consistent!)
        % Isi
        % Average isi in the burst
        % Stdev of isi

        % This creates a dataset with 4005 dimensions to be reduced before
        % clustering 

   amp = v(idxSpikes);
   disp((idxSpikes + 1000))
   shape = [];

   for i = 1:length(idxSpikes)

        shape(i, :) = v( (idxSpikes(i) - 1000):(idxSpikes(i) + 1000) );
   end
   
   neighborShape = zeros([length(spikeTimes) 2001]);
   neighborAmp = [];
   neighborStd = [];
   burstNums = [];

   for i = 1:length(spikeTimes)
       % aberrant spikes
       if spikeInfo.burstNum(i) == -1
           simWave = shape(i);
           simAmp = amp(i);
           simStdAmp = 0;

       % when there are few spikes, probably all in the same neuron burst
       elseif sum(spikeInfo.burstNum == spikeInfo.burstNum(i)) < 5
           % find spikes that belong to the same burst
           idx = find(spikeInfo.burstNum == spikeInfo.burstNum(i));
           simWave = mean(shape(idx, :));
           simAmp = mean(amp(idx));
           simStdAmp = std(amp(idx));

       % otherwise find the 5 nearest spikes in the same burst 
       else
            
            idx = find(spikeInfo.burstNum == spikeInfo.burstNum(i));
            distance = abs(spikeInfo.spikeTimes(idx) - spikeInfo.spikeTimes(i));
            [~, idxMin] = sort(distance);
            idx = idx(idxMin <= 5);

            simWave = mean(shape(idx, :));
            simAmp = mean(amp(idx));
            simStdAmp = std(amp(idx));

       end
       neighborShape(i, :) = simWave;
       neighborAmp(i) = simAmp;
       neighborStd(i) = simStdAmp;
       
   end
   
    % Assemble collected spike info and mean info of spikes in the same burst
    % into a set for dim reduction
   data  = zeros([length(spikeTimes), 4006]);
   data(:, 1) = amp;
   data(:, 2) = simAmp;
   data(:, 3:2001 + 2) = shape;
   data(:, 2004:4004) = neighborShape;
   data(:, 4005) = neighborStd;

   % Cluster on dimensionality reduced data bc it doesn't make sense to
   % use euclidean distance on like 1000 + factors when things like
   % amplitude alone can cleanly sort spikes sometimes. 

   reduced = tsne(data);
    
   labels = kmeans(reduced, 2);



% Clean up our predictions based on the fact that we know spikes in a burst
% should come from the same neuron. Since burst detection still isn't
% great, we'll just assign each spike the most likely identity based on the
% nearby spikes

disp(labels)
newLabels = [];

   for i = 1:length(labels)

       % aberrant spikes, use five nearest spikes to classify
       if spikeInfo.burstNum(i) == -1
            idx = 1:length(labels);
            distance = abs(spikeInfo.spikeTimes - spikeInfo.spikeTimes(i));
            [~, idxMin] = sort(distance);
            idx = idx(idxMin <= 5);

            newLabel = mode(labels(idx));

       % find the 5 nearest spikes in the same burst 
       else
            
            idx = find(spikeInfo.burstNum == spikeInfo.burstNum(i));
            distance = abs(spikeInfo.spikeTimes(idx) - spikeInfo.spikeTimes(i));
            [~, idxMin] = sort(distance);
            idx = idx(idxMin <= 10);

            newLabel = mode(labels(idx));

       end
       disp(newLabel)
       newLabels(i) = newLabel;
       
    end

% Final figure
figure
v = oldV;
t = (0:length(v) - 1) / Fs;

gscatter(spikeTimes, amp, newLabels, [], [], 10)
hold on
plot(t, v, 'k-')


    


