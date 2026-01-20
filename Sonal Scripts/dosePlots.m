clearvars
nb = 970;

pageHot = [107 109 112 114 117 135]; % 135 not sorted yet
pageCold = [110 115 106 108 113 116 ]; % 110 115 106 108 113 116 
pageControl = [103 105 127 128 129];
metadata = metadataMaster;


ALLCOND = {'Baseline','CCAP 1nM', 'CCAP 3nM', 'CCAP 10nM', 'CCAP 30nM', ...
        'CCAP 100nM', 'CCAP 300nM', 'CCAP 1μM', 'Washout', 'Baseline','CCAP 1nM', 'CCAP 3nM', 'CCAP 10nM', 'CCAP 30nM', ...
        'CCAP 100nM', 'CCAP 300nM', 'CCAP 1μM', 'Washout'};
%% PHASE SHIFT
acclimation = pageControl;

store = NaN(length(acclimation), 18);
storePD = [];
storeLP = [];
storePY = [];

for p = 1:length(acclimation)

    page = acclimation(p);
    metadata = metadataMaster;
    filename = "/Volumes/marder-lab/skedia/KAS_sorted/" + nb + "_" + page + "_bursts_allcells.mat";
    load(filename);
    allbursts = all_burst_data;
    clear all_burst_data
    
    % Set which files to do analysis on 
    files = metadata(nb, page).files - 1;
    files = files(2:end);
    files = [files (metadata(nb, page).files(end) + 1) ];
    c = [metadata(nb, page).dose_names metadata(nb, page).dose_names];
    
    numConditions = length(files) / 2;
    
    
    PD = allbursts.PD.burst_data;
    LP = allbursts.LP.burst_data;
    PY = allbursts.PY.burst_data;
    windows = allbursts.PD.file_lengths;


    
    % Set windows to look for burst starts from 
    for i = 1:length(files)
        file = files(i);
        wStart = sum(windows(1:file));
        wEnd = sum(windows(1:file + 1));
    
        burstStarts = PD.firstSp > wStart & PD.firstSp < wEnd;
        
        % Get 
        time = struct();
        time.pdStart = PD.firstSp(burstStarts);
        time.pdEnd = PD.lastSp(burstStarts);
        time.lpStart = NaN(length(time.pdStart) - 1, 1);
        time.lpEnd = NaN(length(time.pdStart) - 1, 1);
        time.pyStart = NaN(length(time.pdStart) - 1, 1);
        time.pyEnd = NaN(length(time.pdStart) - 1, 1);

        % Iterate over every new PD cycle to find corresponding LP and PY
        for k = 1:length(time.pdStart) - 1
            idxLP = find(LP.firstSp > time.pdStart(k) & LP.firstSp < time.pdStart(k+1), 1);
            if ~isempty(idxLP)
                time.lpStart(k) = LP.firstSp(idxLP);
                time.lpEnd(k) = LP.lastSp(idxLP);
            end
            
            idxPY = find(PY.firstSp > time.pdStart(k) & PY.firstSp < time.pdStart(k+1), 1);
            if ~isempty(idxPY)
                time.pyStart(k) = PY.firstSp(idxPY);
                time.pyEnd(k) = PY.lastSp(idxPY);
            end

        end
        
        time.cycleEnd = time.pdStart(2:end);
        % Convert this to time time
        time.pdStart = time.pdStart(1:end-1);
        time.pdEnd = time.pdEnd(1:end-1);
        phase = time;

        fn = fieldnames(time);
        for f = 1:length(fn)
            
            name = fn{f};
            phase.(name) = (time.(name) - time.pdStart) ./ (time.cycleEnd - time.pdStart);
        end
    

        j = i;
        while ~strcmp(c{i}, ALLCOND{j})
            j = j + 1;
        end

        
        % Specifically store things for a box plot for phase range
        % Slightly annoying, you just store 6 points to create the correct
        % box plot. smh. 
        range = 6 * (p-1) + 1: 6*(p-1) + 6;

        storePD(range, j) = [0 0 0 mean(phase.pdEnd) mean(phase.pdEnd) (mean(phase.pdEnd) + std(phase.pdEnd))]; 

        storePY(range, j) = [ (mean(phase.pyStart) - std(phase.pyStart)) mean(phase.pyStart) mean(phase.pyStart)...
                mean(phase.pyEnd) mean(phase.pyEnd) (mean(phase.pyEnd) + std(phase.pyEnd))]; 
        
        storeLP(range, j) = [ (mean(phase.lpStart) - std(phase.lpStart)) mean(phase.lpStart) mean(phase.lpStart)...
                mean(phase.lpEnd) mean(phase.lpEnd) (mean(phase.lpEnd) + std(phase.lpEnd))]; 


%         freq = PD.BuFreq(burstStarts);
%         meanFreq = mean(freq);
%         store(p, j) = meanFreq;
        
%         j = i;
%         while ~strcmp(c{i}, ALLCOND{j})
%             j = j + 1;
%         end
% 
%         store(p, j) = meanFreq;
        
    end

    % Reorganize so that 10 deg data is before
    if metadata(nb, page).cond{1} == "20°C"
%         temp = store(p, 1:numConditions);
%         store(p, 1:numConditions) = store(p, numConditions+1:end);
%         store(p, numConditions+1:end) = temp;

        % phase data kms
        temp = storeLP(range, 1:numConditions);
        storeLP(range, 1:numConditions) = storeLP(range, numConditions + 1:end);
        storeLP(range, numConditions + 1:end) = temp;

        temp = storePY(range, 1:numConditions);
        storePY(range, 1:numConditions) = storePY(range, numConditions + 1:end);
        storePY(range, numConditions + 1:end) = temp;


        temp = storePD(range, 1:numConditions);
        storePD(range, 1:numConditions) = storePD(range, numConditions + 1:end);
        storePD(range, numConditions + 1:end) = temp;

    end

end

% Average out data
% storeMeans = mean(store, "omitnan");

%% Phase shift plot
% Get mean points for each of the 6 points needed for making the boxes

pdBars = [];
lpBars = [];
pyBars = [];
for i = 1:6
    pdBars(i, :) = mean(storePD(i:6:end, :), 'omitnan');
    lpBars(i, :) = mean(storeLP(i:6:end, :), 'omitnan');

    pyBars(i, :) = mean(storePY(i:6:end, :), 'omitnan');
end


% 10 DEG COLD ANIMALS
figure
hold on
boxplot(pdBars(:, 1:8), "Widths", 1, "Orientation","horizontal", 'BoxStyle','filled', 'Positions', [24 23 22 21 20 19 18 17], 'Colors', colors)
boxplot(lpBars(:, 1:8), "Widths", 1, "Orientation","horizontal", 'BoxStyle','filled', 'Positions', [16 15 14 13 12 11 10 9], 'Colors', colors)
boxplot(pyBars(:, 1:8), "Widths", 1, "Orientation","horizontal", 'BoxStyle','filled', 'Positions', [8 7 6 5 4 3 2 1], 'Colors', colors)


h = findobj(gca,'Tag','Median');
set(h,'Visible','off');
title("Phase Shift for Dose Response at 10°C (control animals)")
xlabel("Phase")
xticks([0 0.2 0.4 0.6 0.8 1])
yticks([])

set(findall(gcf,'-property','fontname'),'fontname','arial')
set(findall(gcf,'-property','box'),'box','off')
set(findall(gcf,'-property','fontsize'),'fontsize',17)

% 20 DEG COLD ANIMALS
figure
hold on
boxplot(pdBars(:, 10:17), "Orientation","horizontal", 'BoxStyle','filled', 'Positions', [24 23 22 21 20 19 18 17], 'Colors', colors)
boxplot(lpBars(:, 10:17), "Orientation","horizontal", 'BoxStyle','filled', 'Positions', [16 15 14 13 12 11 10 9], 'Colors', colors)
boxplot(pyBars(:, 10:17), "Orientation","horizontal", 'BoxStyle','filled', 'Positions', [8 7 6 5 4 3 2 1], 'Colors', colors)


h = findobj(gca,'Tag','Median');
set(h,'Visible','off');
title("Phase Shift for Dose Response at 20°C (control animals)")
xlabel("Phase")
xticks([0 0.2 0.4 0.6 0.8 1])
yticks([])

set(findall(gcf,'-property','fontname'),'fontname','arial')
set(findall(gcf,'-property','box'),'box','off')
set(findall(gcf,'-property','fontsize'),'fontsize',17)





%% Dose Plots Standard Routine
nerve = "LP";
analysis = "totalSpikes";


[storeMeansHot, errHot, rawDataHot, tritableH] = dosePlotsHelper(pageHot, nerve, analysis);
[storeMeansCold, errCold, rawDataCold, tritableC] = dosePlotsHelper(pageCold, nerve, analysis);
[storeMeansControl, errControl, rawDataControl, tritableN] = dosePlotsHelper(pageControl, nerve, analysis);


% % Any corrections to apply + get ready for plotting
if analysis == "BurstFreq"
   analysis = "Burst Frequency";

   % Fix for 110 and 115
   rawDataCold(1, 1:4) = 0;
   if nerve == "PD"
    rawDataCold(2, [1:5, 10:18]) = 0;
   end


   storeMeansCold = mean(rawDataCold, "omitnan");
   errCold = std(rawDataCold, "omitnan");

elseif analysis == "Triphasic"
    analysis = "% Triphasic Transitions";

    % Fix for 109, it's fully triphasic at 10 deg but interrupted by gastric
    rawDataHot(2, 1:9) = 1;
    storeMeansHot = mean(rawDataHot, "omitnan");
    errHot = std(rawDataHot, "omitnan");

elseif analysis == "SpikesPerBurst" || analysis == "totalSpikes"
    if analysis== "SpikesPerBurst"
        analysis = "Spikes per Burst";
    else
        analysis = "Total Spikes";
    end
    % Fix for 110 and 115
   rawDataCold(1, 1:4) = 0;
   if nerve == "PD"
    rawDataCold(2, [1:5, 10:18]) = 0;
   end
   storeMeansCold = mean(rawDataCold, "omitnan");
   errCold = std(rawDataCold, "omitnan");

elseif analysis == "nBursts"
    analysis = "# of Bursts";
    % Fix for 110 and 115
   rawDataCold(1, 1:4) = 0;
   
   %rawDataCold(2, 1:14) = 0; % Not bursting 
   storeMeansCold = mean(rawDataCold, "omitnan");
   errCold = std(rawDataCold, "omitnan");


end



dn = {'Baseline','CCAP 1nM', 'CCAP 3nM', 'CCAP 10nM', 'CCAP 30nM', ...
        'CCAP 100nM', 'CCAP 300nM', 'CCAP 1μM'};

x = categorical(dn);
x = reordercats(x, dn);


valsHot = [storeMeansHot(1, 1:9); storeMeansHot(1, 10:end)];
valsCold = [storeMeansCold(1, 1:9); storeMeansCold(1, 10:end)];

% Make a figure for 10 deg hot and cold animals
figure
title(nerve + " " + analysis + " at 10°C")
ylabel(nerve + " " + analysis)
hold on
%ylim([0 .7])

plot(x, valsCold(1,1:end-1), "-o", "LineWidth", 2);
plot(x, valsHot(1,1:end-1), "-o", "LineWidth", 2);

shadedErrorBar(1:8, valsCold(1,1:8), errCold(1:8), 'lineprops', '-b')
shadedErrorBar(1:8, valsHot(1,1:8), errHot(1:8), 'lineprops', '-r')


l = legend({"4°C Acclimation", "18°C Acclimation"}, 'AutoUpdate','off');
l.Location = "eastoutside";

% for i = 1:length(acclimation)
%     scatter(x, store(i, 1:9), "blue")
%     scatter(x, store(i, 10:18), "red")
% end

% lovely lovely formatting
set(findall(gcf,'-property','fontname'),'fontname','arial')
set(findall(gcf,'-property','box'),'box','off')
set(findall(gcf,'-property','fontsize'),'fontsize',17)
ylim([0 inf])

% Make a figure for 20 deg hot and cold animals 
figure
title(nerve + " " + analysis + " at 20°C")
ylabel(nerve + " " + analysis)
hold on
ylim([0 inf])

plot(x, valsCold(2,1:end-1), "-o", "LineWidth", 2);
plot(x, valsHot(2,1:end-1), "-o", "LineWidth", 2);

shadedErrorBar(1:8, valsCold(2,1:8), errCold(10:end-1), 'lineprops', '-b')
shadedErrorBar(1:8, valsHot(2,1:8), errHot(10:end-1), 'lineprops', '-r')


l = legend({"4°C Acclimation", "18°C Acclimation"}, 'AutoUpdate','off');
l.Location = "eastoutside";

% for i = 1:length(acclimation)
%     scatter(x, store(i, 1:9), "blue")
%     scatter(x, store(i, 10:18), "red")
% end

% lovely lovely formatting
set(findall(gcf,'-property','fontname'),'fontname','arial')
set(findall(gcf,'-property','box'),'box','off')
set(findall(gcf,'-property','fontsize'),'fontsize',17)

%% Save mat files
filename = "/Volumes/marder-lab/adalal/MatFiles/" + "DR_" + nerve + "_" + analysis + ".mat";
DR = matfile(filename,'Writable',true);
DR.meansHot = rawDataHot;
DR.meansCold = rawDataCold;
DR.meansControl = rawDataControl;
DR.pagesHot = pageHot;
DR.pagesCold = pageCold;
DR.pagesControl = pageControl;
DR.doses = ALLCOND;

load(filename)



%%

colorMapLength = 9;
red = [26, 51, 0]/255;
pink = [230, 255, 230]/255;
colors_p = [linspace(red(1),pink(1),colorMapLength)', linspace(red(2),pink(2),colorMapLength)', linspace(red(3),pink(3),colorMapLength)'];

colors = [];
colors(8, :) = [223, 223, 222]/255;
colors(7, :) = [179, 218, 174]/255;
colors(6, :) = [159, 202, 154]/255;
colors(5, :) = [128, 178, 123]/255;
colors(4, :) = [119, 165, 117]/255;
colors(3, :) = [112, 154, 112]/255;
colors(2, :) = [107, 145, 108]/255;
colors(1, :) = [101, 134, 102]/255;