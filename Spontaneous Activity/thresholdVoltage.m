%% Script for finding threshold voltage for muscles
nb = 998;
page = 114;
muscleName = "cpv4";
fs = 10^4;

% Load force and recording files
filename = "/Volumes/marder-lab/adalal/MatFiles/" + nb + '_' + page + "_force.mat";

load(filename) % should add some variables to your workspace, including startTime

data = loadExperiment(nb, page, "continuousRamp"); 
    % different for 142 bc of missing file
%data = loadExperiment(nb, page, [66:78, 80:113]); 


data = makeContinuous(data);
muscle = data.(muscleName);
temp = data.temp;
time = data.t;

% Ignore areas where electrode fell out
validIdx = getUsableData(time, muscle, -20); % May take a min

validIdx = find(validIdx);
% Threshold Voltage
idx = int64(startTime* fs) + 1; % Convert time to indices

idx = intersect(idx, validIdx); % Only use valid indices

vThresh = muscle(idx);
vThreshTemp = temp(idx);


