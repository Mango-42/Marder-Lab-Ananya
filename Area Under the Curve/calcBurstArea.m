function [totalArea, vStandard] = calcBurstArea(time, Pulse, Vm1, figureTitle)
%
% This helper function for burstArea.m separates a given file by pulses, and
% calculates the area of each pulse separately from the others by
% calculating a new baseline (Vm right before the pulse, instead of avg baseline)
% It also returns a mV above baseline version of Vm1 -- vStandard, so you can cleanly
% draw the area under the curve of multiple stacked conditions. The
% baseline in this is set to 0, so regions of the curve are shifted up by
% 65-70ish mV. 

% Last edited: Ananya Dalal Mar 28

%% Find start and ending of pulses 

% find rough area of pulses
smooth = movmean(Pulse,2000);
idx = find(smooth() > .01);
pulseArea = zeros([1 length(time)]);
pulseArea(idx) = 1; % boolean array - where is there a pulse?

pulseChanges = ischange(pulseArea); % boolean array, where do the pulses start and end
vrests = [];

for i = 1:length(time)
    
    if pulseChanges(i) == 1
        vrest = mean(Vm1(i-100:i));
        vrests = [vrests, vrest];
    end

end

wherePulseChanges = find(pulseChanges == 1);
wherePulseChanges = [wherePulseChanges, length(Vm1)];

%% Calculate area for individual bursts and sum together; uncomment regions to plot individual bursts
i = 1;
totalArea = 0;

% figure()
% t = tiledlayout("flow");
% title(t, figureTitle, 'Interpreter', 'none', 'FontName', 'Times')
% xlabel(t,'Time segments', 'FontName', 'Times')
% ylabel(t,'Voltage (mV)', 'FontName', 'Times')

while i < length(wherePulseChanges) - 1
    startPulse = wherePulseChanges(i) + 1000; % actually where pulse starts
    endPulse = wherePulseChanges(i+1) - 500; % pulse ends at -1000, but to give some buffer I made it -500

    % we want to find where the voltage goes back to rest after pulse ends
    vReturn = find(Vm1 < vrests(i)); % all indices for Vm less than v rest
    idx = find(vReturn > endPulse, 1, 'first'); % find first time it goes below
    endIntegrate = vReturn(idx);
    % make sure you stop integrating before next pulse as long
    if endIntegrate > wherePulseChanges(i+2)
        endIntegrate = wherePulseChanges(i+2);
    end
    if isempty(endIntegrate) % in the case it never goes below, just set end integrate to end pulse
        endIntegrate = endPulse;
    end

    % % figure with that burst
    % nexttile
    % 
    % hold on
    % a = area(time(startPulse:endIntegrate), Vm1(startPulse:endIntegrate), vrests(i));
    % a.FaceColor = "#71BBB2";
    % a.LineStyle = "none";
    

    % calculate area under curve
    x = time(startPulse:endIntegrate);
    y = Vm1(startPulse:endIntegrate) - vrests(i);
    auc = trapz(x, y);
    totalArea = totalArea + auc;

    i = i + 2; % go to next pair of pulse start/end
end
    set(findall(gcf,'-property','fontname'),'fontname','times')

%% Standardize the baseline voltage so all bursts they have the same baseline (area preserved)
vStandard = Vm1;
avgBaseline = mean(vrests);
i = 1;
vInitial = mean(Vm1(1:100));
% until the first p
vStandard(1: wherePulseChanges(i) + 999) = vStandard(1: wherePulseChanges(i) + 999) - vInitial;

i = 1;

% from start pulse to start pulse, move the baseline up to 0
while i < length(wherePulseChanges) - 1
    startPulse = wherePulseChanges(i) + 1000; % actually where pulse starts

    % if there is no next start 
    length(wherePulseChanges)

    if i + 3 > length(wherePulseChanges)
        nextStartPulse = length(Vm1);
    else
        nextStartPulse = wherePulseChanges(i + 2) + 999;
    end

    if nextStartPulse > length(Vm1)
        nextStartPulse = length(Vm1);
    end
   
    vStandard(startPulse:nextStartPulse) = vStandard(startPulse:nextStartPulse) - vrests(i);

    i = i + 2; % go to next pair of pulse start/end
end
    set(findall(gcf,'-property','fontname'),'fontname','times')

