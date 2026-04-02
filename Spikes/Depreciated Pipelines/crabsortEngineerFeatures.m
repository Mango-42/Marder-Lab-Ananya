function [features] = crabsortEngineerFeatures(spikeTimes)

%% Description: from a series of unsorted spike times extract burst characteristics
% engineered features to go into neural network so you can extract more
% than spike shape to predict neuron

% if i do clustering IN here of the features then we get an easy way to
% account for regional differences between different files and conditions
% :)))) this is so evil cool

% Input:
% spikeTimes: 


%% Initialize storage and frameworks for input

burstStartTimes = [];
intrabursts = [];
perBurst = [];
dCycle = [];
sus = [];

currSpikes = 0;

%%Interburst and intraburst frequency
isi = diff(spikeTimes);
lastValidSpike = 2;

% Go through the isis
for i = 2:length(isi)

    % Detecting the starts of bursts
    
    % assume interburst is at least 3x bigger and > .1 of next intraburst
    if 3 * isi(i) < spikeTimes(i) - spikeTimes(lastValidSpike) && isi(lastValidSpike) - isi(i) > .1 

        burstStartTimes = [burstStartTimes; spikeTimes.(i)];
        
        
        % duty cycle, once you have more than one burst start 
        if length(burstStartTimes) > 1
            burstLength = burstStartTimes(end) - burstStartTimes(end - 1);
            
            dCycle = [dCycle; (burstLength - (burstStartTimes(end) - spikeTimes.(nerve)(lastValidSpike))) / burstLength];

            if dCycle(end) < 0 
                disp((burstLength - isi(i-1)) / burstLength)
                disp(isi(i-1))
            end

        end
        lastValidSpike = i;
        
        % num spikes per burst rests when 
        perBurst = [perBurst; currSpikes];
        currSpikes = 1;

    % flag suspicious/aberrant spikes so you avoid them in intraburst calculations
    % these spikes 
    elseif isi(i) > .1 && isi(i-1) > .1
        sus = [sus; spikeTimes.(nerve)(i)];
        
    else
        intrabursts = [intrabursts; isi(i)];
        currSpikes = currSpikes + 1;
        lastValidSpike = i;
        

    end
end

% activity.inter = mean(1./diff(burstStartTimes));
% activity.intra = mean(1./intrabursts);
% activity.spikesPer = mean(perBurst);
% activity.dCycle = mean(dCycle);
% 
% robust.inter = std(1./diff(burstStartTimes));
% robust.intra = std(1./intrabursts);
% robust.spikesPer = std(perBurst);
% robust.dCycle = std(dCycle);

activity.inter = 1./diff(burstStartTimes);
activity.intra = 1./intrabursts;
activity.spikesPer = perBurst;
activity.dCycle = dCycle;