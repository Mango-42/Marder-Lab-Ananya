function [] = sortSpikes(v)
    %%
    v = -wahoo.pyn{2};
    Fs = 10^4;

    [spikeTimes] = getExtraSpikes(v);
    [~, ~, spikeInfo] = findBursts(spikeTimes, v);

    idxSpikes = int64(spikeTimes * Fs) + 1000;
    oldV = v;
    v = [ zeros([1 1000]) v zeros([1 1000]) ];


    % This function sorts spikes by clustering them by the following properties
        % Amplitude of this spike (1 value)
        % Average amplitude of the spikes in the burst (if > 5 spikes in a
        % burst, use the 5 nearest ones)
        % Shape (1000 + 1 + 1000 values)
        % Average shape of the spikes in the burst (if > 5 spikes in a
        % burst, use the 5 nearest ones)

        % This creates a dataset with 4004 dimensions to be reduced before
        % clustering 

   amp = v(idxSpikes);
   disp((idxSpikes + 1000))
   shape = [];

   for i = 1:length(idxSpikes)

        shape(i, :) = v( (idxSpikes(i) - 1000):(idxSpikes(i) + 1000) );
   end
   
   neighborShape = [];
   neighborAmp = [];

   for i = 1:length(spikeTimes)
       % aberrant spikes
       if spikeInfo.burstNum(i) == -1
           simWave = shape(i);
           simAmp = amp(i);

       % when there are few spikes, probably all in the same neuron burst
       elseif sum(spikeInfo.burstNum == spikeInfo.burstNum(i)) < 5
           % find spikes that belong to the same burst
           idx = find(spikeInfo.burstNum == spikeInfo.burstNum(i));
           simWave = mean(shape(idx, :));
           simAmp = mean(amp(idx));
       % otherwise find the 5 nearest spikes in the same burst 
       else
            
            idx = find(spikeInfo.burstNum == spikeInfo.burstNum(i));
            distance = abs(spikeInfo.spikeTimes(idx) - spikeInfo.spikeTimes(i));
            [~, idxMin] = sort(distance);
            idx = idx(idxMin <= 5);

            simWave = mean(shape(idx, :));
            simAmp = mean(amp(idx));

       end
       neighborShape(i, :) = simWave;
       neighborAmp(i) = simAmp;
       
   end
   
    % Assemble collected spike info and mean info of spikes in the same burst
    % into a set for dim reduction
   data  = zeros([length(spikeTimes), 4004]);
   data(:, 1) = amp;
   data(:, 2) = simAmp;
   data(:, 3:length(shape) + 2) = shape;
   data(:, 2004:4004) = neighborShape;

   % Cluster on dimensionality reduced data bc it doesn't make sense to
   % use euclidean distance on like 1000 + factors when things like
   % amplitude alone can cleanly sort spikes sometimes. 

   reduced = tsne(data);
    
   labels = kmeans(reduced, 2);


figure
v = oldV;
t = (0:length(v) - 1) / Fs;

gscatter(spikeTimes, amp, labels, [], [], 10)
hold on
plot(t, v, 'k-')
   


    


   
   




   % 


    


