% Run spikes pipeline before this, so you have the following variables in
% your workspace:
    % activityLP, activityPY, activityPD
    % onLP, onPY, onPD


figure

plot(data.lpn{1})
hold on
plot(data.PD{1})
plot(data.pdn{1})

% scatter(int64(activityLP.burstStarts * 10000), data.lpn{5}(int64(activityLP.burstStarts * 10000)))



%% Run through starts of bursts and count transitions 


% clearvars -except activityLP activityPD activityPY onLP onPY onPD ...
%     spikesLP spikesPY spikesPD data

lp = activityLP.burstStarts;
py = activityPY.burstStarts;
pd = activityPD.burstEnds;


LP = [0 0 0]';
PY = [0 0 0]';
PD = [0 0 0]';


% transition matrix (structure)
% # of transitions (input row, output column)
t = table(LP, PY, PD, 'RowNames',["LP" "PY" "PD"]);


neurons = ["LP", "PY", "PD"];

m = 0;
while ~isempty(lp) || ~isempty(py) || ~isempty(pd)

    if ~isempty(lp)
        nextLP = lp(1);

    else
        nextLP = 1000000;
    end

    if ~isempty(py)
        nextPY = py(1);
    else
        nextPY = 1000000;
    end

    if ~isempty(pd)
        nextPD = pd(1);
    else
        nextPD = 1000000;
    end
    
    nextStarts = [nextLP nextPY nextPD];
    [m, idx] = min(nextStarts);


    % Remove value
    if idx == 1
        lp = lp(2:end);
    elseif idx == 2
        py = py(2:end);
    else
        pd = pd(2:end);
    end
    

    % first time you go through loop
    if ~exist("first", "var")
        first = idx;
        continue
    elseif exist("next", "var")
        first = next;
    end

    next = idx;   

    t{neurons(first), neurons(next)} = t{neurons(first), neurons(next)} + 1;
 
end

% Fraction of triphasic LP -> PY -> PD transitions
triphasic = sum([t{"LP", "PY"}, t{"PY", "PD"}, t{"PD", "LP"}]);
total = sum(table2array(t), "all");
triphasicAccuracy = triphasic/total;

disp("Count of transitions from which neuron is on")
disp(t)
disp(triphasicAccuracy * 100 + "% of transitions were partially or wholly triphasic");

% clear m LP PY PD lp py pd total triphasic nextLP nextPY nextPD next neurons ...
%     first nextStarts idx lowerLimit upperLimit


