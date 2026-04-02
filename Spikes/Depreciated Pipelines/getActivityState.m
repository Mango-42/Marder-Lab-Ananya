function [state, on] = getActivityState(activity, t)

    %% Description: characterizes activity and robustness for a bursting spike train 
        
    % Characterizes what state a neuron is in based on its activity
    % patterns (quantified by burstAnalysis.m)

    % Output:
        % state: 
            % 0: silent
            % 1: bursting
            % 2: bursting (weak,  0 - 1 spikes)
        % on: 1 through the duty cycle of a neuron + for aberrant spikes

    fs = 10000;
    burstStarts = activity.burstStartTimes;
    burstEnds = activity.burstEndTimes;
    spikesPer = activity.spikesPer;

    state = zeros([1 length(t)]);
    on = zeros([1 length(t)]);

    % fill in a vector showing in areas a neuron was firing 
    for i = 1:length(burstEnds)
        bs = burstStarts(i);
        be = burstEnds(i);

        % only one spike (duty cycle is kind of meaningless)
        if bs == be
            on(bs) = 2;
        else
        % through the duty cycle, the neuron should be marked as on
        on(int64(bs * fs):int64(be * fs)) = 1;
        end


     
    end