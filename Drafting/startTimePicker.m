nb = 998;
page = 138;
range = "roi";
data = loadExperiment(nb, page, range);
metadata = metadataMaster;
files = metadata(nb, page).files;
temps = metadata(nb, page).tempValues;

fs = 10^4;
t = 0 : 1/fs : 90;
t= t(1:end - 1);

fileTimes = {};

for i=1:length(data.force)
    signal = data.force{i};

    timePicker
    
    fileTimes{i} = clicked_times;
end


filename = "/Volumes/marder-lab/adalal/MatFiles/delay/" + nb + '_' + page + "_delay2.mat";
delay = matfile(filename,'Writable',true);
delay.startTimeForce = fileTimes;
delay.files = files;
delay.temp = temps;
%%
nb = 998;
page = 114;

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

temp = data.temp;

nerveStarts = bursts.LP.burstStarts;
nerveFile = bursts.LP.fileNum;
nerveTemp = bursts.LP.temp;
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

% get temperature at muscle start times
for i = 1:length(delay.startTimeMuscle)
    

    f = files(i);
    muscleStarts = allMuscleStarts{i};
    temp = data.temp{i};
    temp = temp(int64(muscleStarts * 10^4));
    subNerveStarts = nerveStarts(nerveFile == f);
    %subTemp = nerveTemp(nerveFile == f);
    subForceStarts = allForceStarts{i};

    for j = 2:length(muscleStarts) - 1

        [nerveStart, idx] = max(subNerveStarts(subNerveStarts < muscleStarts(j) & subNerveStarts > muscleStarts(j-1)));
        
        [forceStart] = min(subForceStarts(subForceStarts > muscleStarts(j) & subForceStarts < muscleStarts(j+1)));
        
        % All points found
        if ~isempty(nerveStart) && ~isempty(forceStart)
            if muscleStarts(j) - nerveStart < .2 && forceStart - muscleStarts(j) < .5% ignore missed bursts lol
                realNerve = [realNerve, nerveStart];
                realMuscle = [realMuscle muscleStarts(j)];
                realTemp = [realTemp temp(j)];
                realForce = [realForce forceStart];
            end
        end



        % Partials (for when you lose nerve or lose contraction electrode)
        if ~isempty(nerveStart)
            if muscleStarts(j) - nerveStart < .2 % ignore missed bursts lol
                nerveD = [nerveD muscleStarts(j) - nerveStart];
                tempNerveD = [tempNerveD temp(j)];
            end
        end

        if ~isempty(forceStart)
            if forceStart - muscleStarts(j) < .5 % ignore missed bursts lol
                forceD = [forceD forceStart - muscleStarts(j)];
                tempForceD = [tempForceD temp(j)];
            end
        end


    end

      figure
      hold on
      plot(t, data.lvn{i})
      plot(subNerveStarts, data.lvn{i}(int64(subNerveStarts * 10^4 + 1)), 'o')


      figure
      hold on
      plot(t, data.cpv4{i})
      plot(muscleStarts + .0001, data.cpv4{i}(int64(muscleStarts * 10^4 + 1)), 'o')

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


% Store another way with larger set but unpaired values
figure
plot(tempForceD, forceD, 'o')
title("Force (all)")

figure
plot(tempNerveD, nerveD, 'o')
title("Nerve (all)")
%%

filename = "/Volumes/marder-lab/adalal/MatFiles/delay/" + nb + '_' + page + "_phase.mat";
delay = matfile(filename,'Writable',true);
delay.deltaNerveAll = nerveD;
delay.deltaContractionAll = forceD;
delay.tempNerveAll = tempNerveD;
delay.tempContractionAll = tempForceD;

% and if you want paired stats use the following
delay.tNerveMatched = realNerve;
delay.tMuscleMatched = realMuscle;
delay.tForceMatched = realForce;
delay.tTempMatched = realTemp;



%% Losing my mind, do I need to plot this??
figure
plot(t, data.lvn{1})
xlim([0 5])

figure
plot(t, data.cpv4{1})
xlim([0 5])


%%

load("/Volumes/marder-lab/adalal/MatFiles/" + nb + '_' + page + "_burst.mat")

figure
plot(subNerveStarts, 'o')
%plot(bursts.LP.temp, 1./(bursts.LP.burstEnds - bursts.LP.burstStarts), 'o')