%% Script for finding threshold voltage for muscles
nb = 998;
page = 114;
muscleName = "cpv4";
fs = 10^4;

% Load force and recording files
filename = "/Volumes/marder-lab/adalal/MatFiles/" + nb + '_' + page + "_force.mat";

ft = load(filename); % should add some variables to your workspace, including startTime

data = loadExperiment(nb, page, "continuousRamp"); 
    % different for 142 bc of missing file
%data = loadExperiment(nb, page, [66:78, 80:113]); 


% Find files that are on the upramp
metadata = metadataMaster;
tempVals = metadata(nb, page).tempValues;
tempFiles = metadata(nb, page).files;
[~, idxMax] = max(tempVals);


contRampFiles = tempFiles(1):tempFiles(end);
meanFileTemps = [];
for i = 1:length(data.temp)
    meanFileTemp = mean(data.temp{i});
    meanFileTemps = [meanFileTemps meanFileTemp];
end
% Get difference in temp across files
d = [1 diff(meanFileTemps)]; % always use the first file
validFiles = contRampFiles(d > .5); % use files that have a higher temp by > .5C than their neighbor

% Make data continuous for indexing
data = makeContinuous(data);

temp = data.temp;
time = data.t;
fileNum = data.fileNums;



% Threshold Start times

muscle = data.(muscleName);
idx = int64(ft.startTime* fs) + 1; % Convert time to indices
% If you have a muscle recording, ignore areas where electrode fell out
validIdx = getUsableData(time, muscle, -20); % May take a min

validIdx = find(validIdx);

[idx, ia, ~] = intersect(idx, validIdx); % Only use valid indices

%%
% Select areas that are on upramp section

myFiles = ft.file(ia);

Lia = ismember(myFiles, validFiles);
idx2 = find(Lia);

idx = idx(idx2);


vThresh = muscle(idx);
vThreshTemp = temp(idx);


figure
plot(vThresh, 'o')

%% Store force analysis


vThresh126 = vThresh;
vThreshTemp126 = vThreshTemp;


%%

figure
tiledlayout(2, 1)

nexttile()
plot(data.cpv4)
nexttile()
plot(data.force)

allAxes = findall(gcf,'type','axes');

linkaxes(allAxes, 'x')

%%

%% Threshold voltage (only on exp with muscle)
muscle = "cpv4";

data = loadExperiment(nb, page, "continuousRamp"); 
data = makeContinuous(data);
%%
% Make force start time into idx
startTimeIdx = int64(startTime * fs) + 1;

% Only use valid EJP area
% If you have a muscle recording, ignore areas where electrode fell out
idxValidMuscle = getUsableData(time, data.(muscle), -20); % May take a min

idxValidMuscle = find(idxValidMuscle);

[idxFinal, idxInForce] = intersect(startTimeIdx, idxValidMuscle); % Only use valid indices
% Use idx in force to get other force related values for that contraction

vThresh = data.(muscle)(idxFinal);
%%
vTemp = data.temp(idxFinal);

figure
plot(vThresh, 'o')

figure
plot(vTemp, vThresh, 'o')


%% DEBUGGING - does everything look ok???
figure
hold on
plot(data.t, data.force)
plot(startTime, data.force(startTimeIdx), 'o')



