nb = 998;
page = 142;
%%
fs = 10^4;
t = 0 : 1/fs : 90;
t= t(1:end - 1);

filename = "/Volumes/marder-lab/adalal/MatFiles/delay/" + nb + '_' + page + "_delay.mat";
delay = load(filename);
metadata = metadataMaster;
files = metadata(nb, page).files;

filename = "/Volumes/marder-lab/adalal/MatFiles/" + nb + '_' + page + "_burst.mat";
load(filename);

filename = "/Volumes/marder-lab/adalal/MatFiles/delay/" + nb + '_' + page + "_delay2.mat";
force = load(filename);


data = loadExperiment(nb, page, "roi");

nerveStarts = bursts.LP.burstStarts;
nerveFile = bursts.LP.fileNum;
realNerve = [];
realMuscle = [];
realTemp = [];
realForce = [];

nerveD = [];
forceD = [];
tempNerveD = [];
tempForceD = [];

allMuscleStarts = delay.startTimeMuscle;
allForceStarts = force.startTimeForce;
allTemp = bursts.LP.temp;

% get temperature at muscle start times
for i = 1:length(delay.startTimeMuscle)
    

    f = files(i);
    muscleStarts = allMuscleStarts{i};
    subNerveStarts = nerveStarts(nerveFile == f);
    temp = allTemp(nerveFile == f);
    subForceStarts = allForceStarts{i};

    for j = 2:length(subNerveStarts) - 1

        [muscleStart] = min(muscleStarts(muscleStarts > subNerveStarts(j) & muscleStarts < subNerveStarts(j+1)));
        [forceStart] = min(subForceStarts(subForceStarts > subNerveStarts(j)));
        
        realNerve = [realNerve, subNerveStarts(j)];
        realTemp = [realTemp temp(j)];
        
        if muscleStart - subNerveStarts(j) < .2 
            realMuscle = [realMuscle muscleStart];
        else
            realMuscle = [realMuscle NaN];
        end

        if forceStart - subNerveStarts(j) < 1
            realForce = [realForce forceStart];
        else
            realForce = [realForce NaN];
        end

    end

%       figure
%       hold on
%       plot(t, data.lvn{i})
%       plot(subNerveStarts, data.lvn{i}(int64(subNerveStarts * 10^4 + 1)), 'o')
% 
% 
%       figure
%       hold on
%       plot(t, data.cpv4{i})
%       plot(muscleStarts + .0001, data.cpv4{i}(int64(muscleStarts * 10^4 + 1)), 'o')

      figure
      hold on
      plot(t, data.force{i})
      plot(subForceStarts, data.force{i}(int64(subForceStarts * 10^4 + 1)), 'o')


end

[realMuscle, idx]  = sort(realMuscle);
realNerve = realNerve(idx);
realForce = realForce(idx);
realTemp = realTemp(idx);
% Store one way with paired values
figure
plot(realTemp, realMuscle - realNerve, 'o')
title("Nerve Delay")

figure
plot(realTemp, realForce - realMuscle, 'o')
title("Contraction Delay")

%%
filename = "/Volumes/marder-lab/adalal/MatFiles/delay/" + nb + '_' + page + "_phase2.mat";
delay = matfile(filename,'Writable',true);
% delay.deltaNerveAll = nerveD;
% delay.deltaContractionAll = forceD;
% delay.tempNerveAll = tempNerveD;
% delay.tempContractionAll = tempForceD;

% and if you want paired stats use the following
delay.tNerveMatched = realNerve;
delay.tMuscleMatched = realMuscle;
delay.tForceMatched = realForce;
delay.tTempMatched = realTemp;



% %% Losing my mind, do I need to plot this??
% figure
% plot(t, data.lvn{1})
% xlim([0 5])
% 
% figure
% plot(t, data.force{1})
% xlim([0 5])
% 
% 
% %%
% 
% load("/Volumes/marder-lab/adalal/MatFiles/" + nb + '_' + page + "_burst.mat")
% 
% figure
% plot(subNerveStarts, 'o')
% %plot(bursts.LP.temp, 1./(bursts.LP.burstEnds - bursts.LP.burstStarts), 'o')