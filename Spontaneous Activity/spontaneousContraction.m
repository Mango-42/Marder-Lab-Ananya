%% Script for loading spontaneous contraction peaks
nb = 998;
page = 24;
fs = 10^4;

% Load force and recording files
filename = "/Volumes/marder-lab/adalal/MatFiles/" + nb + '_' + page + "_force.mat";
load(filename)

% Find files that are on the upramp
metadata = metadataMaster;
tempVals = metadata(nb, page).tempValues;
tempFiles = metadata(nb, page).files;


d = [diff(tempVals)];
validIdx = d > 0;
validFiles = [];

for i=1:length(validIdx)

    if validIdx(i) == 1
        validFiles = [validFiles tempFiles(i):tempFiles(i + 1)];

    end
end

validFiles = unique(validFiles);


% Only use data from the upramp

figure
plot(temp, amp, 'o')
title("Before Filtering")
xlabel("Temperature")
ylabel("Amplitude")

idxValid = ismember(file, validFiles);
file = file(idxValid);
amp = amp(idxValid); % in volts
peaks = peaks(idxValid);
force = force(idxValid); % in newtons
condition = condition(idxValid);
base = base(idxValid);
temp = temp(idxValid);
startTime = startTime(idxValid);
time = time(idxValid);

% Only use data in saline
idxValid = find(condition == "saline");

file = file(idxValid);
amp = amp(idxValid); % in volts
peaks = peaks(idxValid);
force = force(idxValid); % in newtons
condition = condition(idxValid);
base = base(idxValid);
temp = temp(idxValid);
startTime = startTime(idxValid);
time = time(idxValid);

figure
plot(temp, amp, 'o')
title("After filtering")


%% 

muscle = "cpv4";

data = loadExperiment(nb, page, "continuousRamp"); % "continuousRamp"
data = makeContinuous(data);
% Make force start time into idx
startTimeIdx = int64(startTime * fs) + 1;

% Only use valid EJP area
% If you have a muscle recording, ignore areas where electrode fell out
idxValidMuscle = getUsableData(time, data.(muscle), -20); % May take a min

idxValidMuscle = find(idxValidMuscle);

[idxFinal, idxInForce] = intersect(startTimeIdx, idxValidMuscle); % Only use valid indices
% Use idx in force to get other force related values for that contraction
%% Plot vThresh
vThresh = data.(muscle)(idxFinal);

vTemp = data.temp(idxFinal);
%%
figure
plot(vThresh, 'o')
title("vThresh")

figure
plot(vTemp, vThresh, 'o')
title("vThresh vs Temp")


%% DEBUGGING - does everything look ok???
timeIdx = int64(time * fs) + 1;
figure
hold on
plot(data.t, data.force)
plot(startTime, data.force(startTimeIdx), 'o')
plot(time, data.force(timeIdx), 'o')

%%

% [peaks, locs] = findpeaks(smooth(data.force, .0005),'MinPeakProminence', .0005, 'MinPeakDistance', 0.4 * fs );
% figure
% hold on
% plot(data.force{1})
% plot(locs, data.force{1}(locs), 'o')

%% write to a file

filename = "/Volumes/marder-lab/adalal/MatFiles/" + nb + "_" + page + "_thresh.mat";
thresh = matfile(filename,'Writable',true);

thresh.temp = vTemp;
thresh.vthresh = vThresh;
thresh.time = double(1/fs) * double(idxFinal);

%%
nb = 998;
page = 46;
filename = "/Volumes/marder-lab/adalal/MatFiles/" + nb + "_" + page + "_thresh.mat";
load(filename)

figure
plot(vthresh, 'o')
title("vThresh")

figure
plot(temp, vthresh, 'o')
title("vThresh vs Temp")


%% Cluster to only get above baseline values

x(:, 1) = vthresh;
x(:, 2) = temp;


[idx, c] = kmeans(x, 3);
figure
gscatter(temp, vthresh, idx, [], [], 10)
%%
vals = find(idx == 2 | idx == 3 | idx == 5);

newvthresh = vthresh(vals);
newtemp = temp(vals);
newtime = time(vals);


%%
figure
plot(newvthresh, 'o')
title("vThresh")

figure
plot(newtemp, newvthresh, 'o')
title("vThresh vs Temp")




%%
filename = "/Volumes/marder-lab/adalal/MatFiles/" + nb + "_" + page + "_thresh-filtered.mat";
thresh = matfile(filename,'Writable',true);

thresh.temp = newtemp;
thresh.vthresh = newvthresh;
thresh.time = newtime;


%% Adjust start times based on when they go over the base at that start time for more than the next .1 secs

for i=1:length(startTimes)
    b = base(i);
    for j = startTimeIdx(i):startTimeIdx(i) + 5000
        section = data.force(startTimeIdx(i):startTimeIdx(i)+1000);
        m = min(section);

    end
end





