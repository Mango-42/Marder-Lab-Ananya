function [triphasicAccuracy, t] = testTriphasic(lp, py, pd)

% Description: a measure of triphasic-ness, counts transitions that
% are at least partially triphasic (LP -> PY, PY -> PD, PD -> LP)

% Inputs:
    % lp (double[]): lp burst starts for a region
    % py (double[]): py burst starts for same region
    % pd (double[]): pd burst starts for same region

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

if total == 0
    triphasicAccuracy = 0;
else
triphasicAccuracy = triphasic/total;
end
disp("Count of transitions from which neuron is on")
disp(t)
disp(triphasicAccuracy * 100 + "% of transitions were partially or wholly triphasic");

% clear m LP PY PD lp py pd total triphasic nextLP nextPY nextPD next neurons ...
%     first nextStarts idx lowerLimit upperLimit

