function [activity] = burstAnalysis(spikeTimes, nerve, data)

    %% Description: characterizes activity and robustness for a bursting spike train 
        
    % Characterizes features that are only related to one nerve. Assumes
    % bursting and that you have at least 2 spikes/burst 
        % relies on changes in ISI

    % Something ELSE should characterize set dependent properties

        % ie, like % of time that neurons are active at the same time
        % or average number of times per a regular bursting neuron that
        % this neuron fires during an active cycle of 

    % Inputs:
        % spikeTimes (structure OR double []) - for multiple or single 
            % nerves sorted / experiment
            % As a structure: spike times on different nerves. 
            %   Field names should be things like "LP", "PD", etc
            % As a double [] - spikes for only a single nerve
        
        % nerve (str) - "LP", "PD", etc
        % data (structure OR double []) - for multiple or single 
            % nerves sorted / experiment. use loadExperiment.m for multiple
            % loading 
            
    % Outputs:

        % CHARACTERISTICS OF ACTIVITY

        % activity (structure) - containing
            % inter (double) - interburst intervals
            % intra (double) - intraburst intervals
            % spikesPer (double) - number of spikes per burst
            % dCycle (double) - % of time of a burst spent on
            % sus (double []) - times of spikes that are marked as
                % suspicious-- may be on a diff neuron or aberrant or
                % gastric mill rhythm 

        % CHARACTERISTICS OF VARIABILITY AND ROBUSTNESS


    % Last edited: Ananya Dalal July 7

%% Initialization

activity = struct;
robust = struct;
fs = .0001;

if nerve == "LP"
    %if isfield(data, 'lvn')
        source = "lvn";
    %elseif isfield(data, 'lpn')
        %source = "lpn";
    %end
elseif nerve == "PD"
    source = "pdn";
elseif nerve == "PY"
    source = "pyn";
elseif nerve == "LG"
    source = "lgn";
end

% Filter out likely outlier spikes (ie from touching the rig)
% spikeAmps = data.(source)(int64(spikeTimes.(nerve) / fs));
% upper = mean(spikeAmps) + 3 * std(spikeAmps);
% lower = mean(spikeAmps) - 3 * std(spikeAmps);
% 
% idx = find(spikeAmps > lower & spikeAmps < upper);
% spikeTimes.(nerve) = spikeTimes.(nerve)(idx);



%% Initialize storage and frameworks for input

burstStartTimes = [];
intrabursts = [];
perBurst = [];
dCycle = [];
sus = [];

currSpikes = 0;

% Turn single channel data into the same structure as multichannel data 
if isstruct(spikeTimes) == 0
    tempStruct = struct();
    tempStruct.(nerve) = spikeTimes;
    spikeTimes = tempStruct;
end

if isstruct(data) == 0
    tempStruct = struct();
    tempStruct.(source) = data;
    tempStruct.t = .0001 * (0:length(tempStruct.(source)) - 1);

    data = tempStruct;
end

% different detection criteria for different neurons
function bool = isLPburstStart
    
    % this is for starts of bursts
    bool = 5 * isi(i) < spikeTimes.(nerve)(i) - spikeTimes.(nerve)(lastValidSpike) && isi(lastValidSpike) - isi(i) > .1; 
    % this is to also count single spikes 
    bool = bool || isi(i) > .3 && isi(i-1) > .3;
end


function bool = isLGburstStart
    % either start of a burst so bigggg isi followed by small 
    bool = spikeTimes.(nerve)(i) - spikeTimes.(nerve)(lastValidSpike) > 1 && ...
        isi(i) < 1; 
end
function bool = isLPSus

    bool = isi(i) > .1 && isi(i-1) > .1;

end

function bool = isLGSus

    bool = isi(i) > 1 && isi(i-1) > 1;

end


%%Interburst and intraburst frequency
isi = diff(spikeTimes.(nerve));
lastValidSpike = 2;

% Go through the isis
for i = 2:length(isi)

    % Detecting the starts of bursts
    
    % assume interburst is at least 5x bigger and > .1 of next intraburst
    if (isLPburstStart && nerve == "LP") || (isLGburstStart && nerve == "LG")

        burstStartTimes = [burstStartTimes; spikeTimes.(nerve)(i)];
        
        
        % duty cycle, once you have more than one burst start 
        if length(burstStartTimes) > 1
            burstLength = burstStartTimes(end) - burstStartTimes(end - 1);
            
            dCycle = [dCycle; (burstLength - (burstStartTimes(end) - spikeTimes.(nerve)(lastValidSpike))) / burstLength];

            burstEndTimes = [burstStartTimes; spikeTimes.(nerve)(lastValidSpike)];

        end
        lastValidSpike = i;
        
        % num spikes per burst rests when 
        perBurst = [perBurst; currSpikes];
        currSpikes = 1;

    % flag suspicious/aberrant spikes so you avoid them in intraburst calculations
    % these spikes 

    elseif (isLPSus && nerve == "LP") || (isLGSus && nerve == "LG") 
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
activity.burstStartTimes = burstStartTimes(1:end - 1);


%% Plot burst starts as a sanity check

figure
%title("NB: " + targetNotebook + " page " + targetPage + " " + nerve)
plot(data.t, data.(source))
hold on
scatter(spikeTimes.(nerve), data.(source)(int64(spikeTimes.(nerve) / fs)))
scatter(burstStartTimes, data.(source)(int64(burstStartTimes / fs)), "k*")
scatter(sus, data.(source)(int64(sus / fs)))
legend({nerve, "spikes", "burst starts", "sus?"})

% title("NB: " + targetNotebook + " page " + targetPage + " " + nerve)

end