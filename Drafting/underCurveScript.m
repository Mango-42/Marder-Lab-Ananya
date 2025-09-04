%% Sample script for using plotOverview.m
% Run section - quick check to make sure pathing is all correct:

% set directories for different people/rigs raw data folders
kathleen_dir = "/Volumes/marder-lab/kjacquerie/_raw data";
% kathleen_dir = "/Users/kathleen/Documents/PostDoc/2025-IK";
ani_dir = "/Volumes/marder-lab/apoghosyan/raw data";

% quick test
directory_name = kathleen_dir;
targetNotebook = 988;
targetPage = 78;
googleSheet = 'Real';
saveOn = 0;
range = 153;

% returns 3 tables containing original data, cleaned data, and
% downsampled cleaned data that gets plotted
[d, d_c, d_d] = plotOverview(directory_name, targetPage, targetNotebook, googleSheet, saveOn, range);

%% get Vm1
d_c.Properties.VariableNames
Vm1 = d_d.Vm1_d;
Vm2 = d_d.Vm1_d;
time = d_d.t_d;
Pulse = d_d.Pulse_d;
temp = d_d.Temp_d;

%%
figure
subplot(2, 1, 2)
plot(time, Vm2)
ylim([-80, -77])
subplot(2, 1, 1)
plot(time, temp)


%% Plot time vs Vm1
figure()
plot(time, Vm1)
%% Find start and ending of pulses 
figure()
plot(time, Pulse)
hold on
% find rough area of pulses
smooth = movmean(Pulse,2000);
idx = find(smooth() > .01);
pulseArea = zeros([1 length(time)]);
pulseArea(idx) = 1; % boolean array - where is there a pulse?
plot(time, smooth)
plot(time, pulseArea)

pulseChanges = ischange(pulseArea); % boolean array, where do the pulses start and end
plot(time, pulseChanges)
vrests = [];

for i = 1:length(time)
    
    if pulseChanges(i) == 1;
        vrest = mean(Vm1(i-100:i));
        vrests = [vrests, vrest];
    end

end

wherePulseChanges = find(pulseChanges == 1);
wherePulseChanges = [wherePulseChanges, length(Vm1)];
%%

i = 1;

t = tiledlayout("flow");
title(t,'Burst plot')
xlabel(t,'Vm')
ylabel(t,'Time segments')
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

    nexttile
    % figure with that burst
    
    % plot(time(startPulse:endIntegrate), Vm1(startPulse:endIntegrate), "k-")
    hold on
    a = area(time(startPulse:endIntegrate), Vm1(startPulse:endIntegrate), vrests(i));
    a.FaceColor = "#71BBB2";
    a.LineStyle = "none";
    upperBound = -55;
    if max(Vm1(startPulse:endIntegrate)) > upperBound
        ylim([(vrests(i) -1), max(Vm1(startPulse:endPulse)) ])
    
    end
    % calculate area under curve
    x = time(startPulse:endIntegrate);
    y = Vm1(startPulse:endIntegrate) - vrests(i);
    auc = trapz(x, y);
    i = i + 2; % go to next pair of pulse start/end
end

% area(time(1:10000),Vm1(1:10000), vrests(1))
% area(time(20000:30000),Vm1(20000:30000), vrests(2))
% area(time(40000:50000),Vm1(40000:50000), vrests(3))

%% next steps!!
% alright so currently: you have detected full areas of pulses and their
% starts. you can take the area of 
figure()
plot(time, Vm1)
%%
matObj = matfile('myFile.mat')
m = matfile('myFile.mat','Writable',true);

%%
kathleen_dir = "/Volumes/marder-lab/kjacquerie/_raw data";
% kathleen_dir = "/Users/kathleen/Documents/PostDoc/2025-IK";
ani_dir = "/Volumes/marder-lab/apoghosyan/raw data";

% quick test
directoryName = kathleen_dir;
targetNotebook = 988;
targetPage = 116;
googleSheet = 'Real';
saveOn = 0;
range = 153;

[m] = burstArea(directoryName, targetPage, targetNotebook, googleSheet)
%%
m.activityTemp = conditions;
m.areas = areas;

%% Access Area Object and plot it correctly!

a = areaInfo.("Area Object")(1)
rest = a.BaseValue;
figure()
hold on
aFix = copyobj(a,gca);
aFix.BaseValue = rest;
aFix.FaceColor = "#71BBB2";
aFix.LineStyle = "none";

a = areaInfo.("Area Object")(1)
rest = a.BaseValue;
figure()
hold on
aFix = copyobj(a,gca);
aFix.BaseValue = rest;
aFix.FaceColor = "#71BBB2";
aFix.LineStyle = "none";
%%

googleSheet = 'Real';
datasheet = importRealSheet(googleSheet);

% Find rows where the 'page' column matches 'targetPage'
row = strcmp(datasheet.page, targetPage) & strcmp(datasheet.notebook, targetNotebook) ; % can switch to contains


%%
 %god ok so the next steps will probably be create a mat object to store
 %data 