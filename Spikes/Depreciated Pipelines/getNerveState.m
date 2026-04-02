function [activity] = getNerveState(spikeTimes, v, nerve)

    % Description: returns state of a nerve along a time recording 

    % Known issues: Needs to be refined to have correct transition
    % boundaries. Currently data is chunked up in 10 s intervals 

    % Inputs:
        % spikeTimes (structure) - contains fields storing arrays with
            % spike times on different nerves. Field names should be things
            % like "LP", "PD", etc
        % v (double []) - voltage trace for the relevant nerve
        % nerve (str) - "LP", "PD", etc
            
    % Outputs:
        % activity (double []) - the state of nerve v along time t
            % 0 - silent
            % 1 - bursting
                % determined by if there's a bimodal distribution
                % of isi in that 10s block 
            % 2 - irregular (spikes but not bursting)

    % Last edited: Ananya Dalal July 7

%% Break up states into 10 s windows

fs = .0001;
activity = zeros([length(v) 1]);

% Break up time into 10 second windows 
for i = 0:(length(v) * fs / 10)
    t1 = i * 10;
    t2 = t1 + 10;

    times = intersect(spikeTimes.(nerve)(spikeTimes.(nerve) > i*10), spikeTimes.(nerve)(spikeTimes.(nerve) < i*10 + 10));
    isiLocal = diff(times);
    
    % use bimodality test to determine if neuron is likely bursting 
    bursting = bimodalitycoeff(isiLocal);

    if bursting
        activity((1 + t1/fs) : (t2/fs)) = 1;
    % spikes, but not bursting = irregular 
    elseif isempty(isiLocal) == 0
        activity((1 + t1/fs) : (t2/fs)) = 2;
    end

end

%% Refine windows and transition points

% Refine boundaries on silent areas
% spikes = zeros([length(v) 1]);
% 
% spikes(int64(spikeTimes.(nerve) * 1/fs)) = 1;
% state = movsum(spikes, 1/fs * 10);
% activity(state == 0) = 0;


% figure
% plot(data.t, activity)
% 
% figure
% plot(data.t, data.In6)
% hold on 
% scatter(spikeTimes.PD, data.In6(int64(spikeTimes.PD * 10000)))

