clearvars
notebook = 970;
page = 103;

data = loadExperiment(notebook, page, 1);

%%
%clearvars -except data
close all

fn = fieldnames(data);

allRobust = {};

% For as many files/doses/whatever, run analysis 
% (see helper fxn at the end of the script)
for i = 1
    
    % Check for intracellulars <3
    if isfield(data, 'PD')
        [spikesPD, onPD, activityPD] = detect(data.PD{i});
    end

    if isfield(data, 'PY')
        [spikesPY, onPY, activityPY] = detect(data.PY{i});
    end

    if isfield(data, 'LP')
        [spikesLP, onLP, activityLP] = detect(data.LP{i});
    end

    
    % Check for extracellulars with only one neuron <3

    if ~exist('spikesPD','var') && isfield(data, 'pdn')

        [spikesPD, onPD, activityPD] = detect(data.pdn{i});
    end

    if ~exist('spikesLP','var') && isfield(data, 'lpn')

        [spikesLP, onLP, activityLP] = detect(data.lpn{i}, spikesPD);
    end

    % Now, check for extracellulars with multiple neurons and hope you can
    % use prior data to sort them </3

    % Use LP spikes to sort PY on pyn
    if ~exist('spikesPY','var') && exist('spikesLP','var') && isfield(data, 'pyn')
        [spikesPY, onPY, activityPY] = detect(data.pyn{i}, spikesLP);
    end

    % Use PY spikes to sort LP on pyn
    if ~exist('spikesLP','var') && exist('spikesPY','var') && isfield(data, 'pyn')
        [spikesLP, onLP, activityLP] = detect(data.pyn{i}, spikesPY);
    end


    % If there's anything left, try using lvn 
    if ~exist('spikesLP','var') && exist('spikesPY','var') && exist('spikesPD','var')&& isfield(data, 'lvn')
        [spikesLP, onLP, activityLP] = detect(data.pyn{i}, spikesPY);
    end
    
    testTriphasic
    robust = analyze(activityLP, activityPY, activityPD, triphasicAccuracy);
    

    
    allRobust{i} = robust;

end

%%
% Make figures based on how properties change over dose
figure

metadataMaster
notebook = 970;
page = 107;
names = metadata(notebook, page).dose_names;
spikevar = getProperty(allRobust, "variance", "spikes", "LP");

t = table();
t.spikevar = spikevar';
t.names = names;

scatter(t,"names","spikevar","filled")

%%



%% FUNCTIONSSS
%% Robustness measure for the file (ASSUMING BURSTING)

function [robust] = analyze(activityLP, activityPY, activityPD, triphasicAccuracy)
        
    % Variance in activity measures
    varLPOn = std(activityLP.dutyCycle);
    varPYOn = std(activityPY.dutyCycle);
    varPDOn = std(activityPD.dutyCycle);
    
    varLPSpikes = std(activityLP.spikesPer);
    varPYSpikes = std(activityPY.spikesPer);
    varPDSpikes = std(activityPD.spikesPer);
    
    varLPburstPeriod = std(diff(activityLP.burstStarts));
    varPYburstPeriod = std(diff(activityPY.burstStarts));
    varPDburstPeriod = std(diff(activityPD.burstStarts));
    
    % Failure rates for the neurons (when interburst > 1.5x average burst interval among all neurons)
    burstIntervals = [diff(activityLP.burstStarts) diff(activityPY.burstStarts) diff(activityPD.burstStarts)];
    upperLimit = mean(burstIntervals) * 1.5;
    lowerLimit = mean(burstIntervals) / 1.5;
    
    failsLP = sum(diff(activityLP.burstStarts) > upperLimit);
    failRateLP = failsLP / (length(activityLP.burstStarts) + failsLP);
    
    failsPY = sum(diff(activityPY.burstStarts) > upperLimit);
    failRatePY = failsPY / (length(activityPY.burstStarts) + failsPY);
    
    failsPD = sum(diff(activityPD.burstStarts) > upperLimit);
    failRatePD = failsPD / (length(activityPD.burstStarts) + failsPD);
    
    % Look for neurons that just keep yapping (likely multiple bursts / cycle)
    yapperLP = sum(diff(activityLP.burstStarts) < lowerLimit);
    yapperRateLP = yapperLP / (length(activityLP.burstStarts));
    
    yapperPY = sum(diff(activityPY.burstStarts) < lowerLimit);
    yapperRatePY = yapperPY / (length(activityPY.burstStarts));
    
    yapperPD = sum(diff(activityPD.burstStarts) < lowerLimit);
    yapperRatePD = yapperPD / (length(activityPD.burstStarts));
    
    
    
    % Wrap everything into a structure called robust. Higher values in any of
    % these signify Less robustness
    robust = struct;
    
    robust.variance.period.LP = varLPburstPeriod;
    robust.variance.period.PY = varPYburstPeriod;
    robust.variance.period.PD = varPDburstPeriod;
    robust.variance.dutyCycle.LP = varLPOn;
    robust.variance.dutyCycle.PY = varPYOn;
    robust.variance.dutyCycle.PD = varPDOn;
    robust.variance.spikes.LP = varLPSpikes;
    robust.variance.spikes.PY = varPYSpikes;
    robust.variance.spikes.PD = varPDSpikes;
    robust.probability.fail.LP = failRateLP;
    robust.probability.fail.PY = failRatePY;
    robust.probability.fail.PD = failRatePD;
    
    robust.probability.multiple.LP = yapperRateLP;
    robust.probability.multiple.PY = yapperRatePY;
    robust.probability.multiple.PD = yapperRatePD;
    
    robust.triphasic.accuracy = triphasicAccuracy;
    % robust.triphasic.fullAccuracy = triphasicAll;
    % robust.triphasic.coupling.LP-PD = triphasicLP-PD
    % robust.triphasic.coupling.PY-PD = triphasicPY-PD
    % robust.triphasic.coupling.LP-PY = triphasicLP-PY

end



%% Helper functions

% This will be called a lot to get different channels data
function [spikes, on, activity] = detect(v, varargin)
    % Assume data that is negative most of the time is probably
    % intracellular data

    if mean(v) < - 1
        spikes = getIntraSpikes(v);
    elseif nargin == 1
        spikes = getExtraSpikes(v);
    % use another neuron's spikes to filter this one
    elseif nargin == 2
        spikes = getExtraSpikes(v, varargin{1});
    end

    [on, activity] = findBursts(spikes, v);
   
end


function [series] = getProperty(a, cat1, cat2, varargin)
    series = [];
    for i = 1:length(a)
        if cat1 == "probability" || cat1 == "triphasic"
            series(i) = a{i}.(cat1).(cat2);
        elseif cat1 == "variance"
            series(i) = a{i}.(cat1).(cat2).(varargin{1});   
        end

    end

end







