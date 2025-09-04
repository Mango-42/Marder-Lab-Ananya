function [] = tiledExperiment(targetNotebook, targetPage, win, saveOn)

    %% Description: plots a tiled version of an experiment
    % Works for data in "Intact" only!!! Relies on temperature conditions
    % metadata that is in that sheet only at the moment. 
    % Can plot Vm_1 - 3 and In_5 and In_6

    % Known issues: Tile spacing is buggy on versions before 2024b
    % Needs one channel to Always plot, so for now it is In_6. This should
    % be fixed later by storing all data in a table and iterating through
    % the rows rather than creating separate variables for each channel. 

    % Inputs:
        % targetNotebook (int) - page of notebook
        % targetPage (int) - page of experiment
        % win (int) - window to plot, ie, 1 sec, 5 secs
        % saveOn (bool) - whether to save figure at the end. 
            % recommended to manually save as svg instead because figures 
            % are so big sometimes that they override the svg formatting

    % Dependencies
        % plotOverview.m
        % import_googlesheet.m

    % Last edited: Ananya Dalal July 8

%% Get voltage traces from the experiment

googleSheet = 'Intact';
datasheet = import_googlesheet(googleSheet);

range = "roi"; 

[d, d_c, data] = plotOverview("auto", targetPage, targetNotebook, googleSheet, saveOn, range);

targetNotebook = string(targetNotebook);
targetPage = string(targetPage);
fixedPage = sprintf('%03d',str2num(targetPage));

% Find rows where the 'page' column matches 'targetPage'
row = strcmp(datasheet.page, targetPage) & strcmp(datasheet.notebook, targetNotebook);

%% get identifying information about an experiment
electrodeName = datasheet.electrodes{row};
tempValues = datasheet.temperature_values{row};
files = datasheet.files{row}; 
conditions = datasheet.conditions{row};
starts = datasheet.start_conditions{row};
starts = starts(2:end);
inputsName = datasheet.extra{row};

% traces and timed data 
Vm1 = data.Vm1_d; % trace of Vm1
Vm2 = data.Vm2_d; % trace of Vm1
Vm3 = data.Vm3_d; % trace of Vm3
time = data.t_d; % time
Vin = data.Pulse_d; % input current / pulses
In5 = data.In5_d;
In6 = data.In6_d;
abfnum = data.abfNum_d;
% find starting points of new abf files
changes = [1, find(ischange(abfnum))];

%% Get a listing of associated conditions, by file
conditionByFiles = {};
c = 1;
for i = 1:length(files)

    if c+1 <= length(conditions) & starts(c+1) <= files(i)
        c = c + 1;
    end
    conditionByFiles{i} = conditions{c}; 
end

%% 

%  detect electrodes that were actually not recording or flagged as NA
valid1 = mean(Vm1) ~= 0 && electrodeName{1} ~= "NA";
valid2 = mean(Vm2) ~= 0 && electrodeName{2} ~= "NA";
valid3 = mean(Vm3) ~= 0 && electrodeName{3} ~= "NA";
validIn5 = mean(In5) ~= 0 && inputsName{1} ~= "NA";
validIn6 = mean(In6) ~= 0 && inputsName{2} ~= "NA";

window = 10 * win; % leave x wiggle room in plotting
% so that you can move around the site of an electrode popping out or smth

dt = 0.001;

f = figure(100);
% number of rows is number of channels + 1 (for scalebar!)
t = tiledlayout((validIn5 + validIn6 + valid1 + valid2 + valid3 + 1), length(files));

% this kind of tile spacing wont work well on older versions
if isMATLABReleaseOlderThan("R2024b") == false
    t.TileSpacing = 'tight';
    t.Padding = 'compact';
    disp("uhhhhhh")
end
%ylabel(t, 'Voltage (mV)', 'FontName', 'Arial', 'FontSize', 17)
figName = "Experiment Regions: " + targetNotebook + "_" + targetPage + " Window = " + win + " seconds";
title(t, figName, 'FontName', 'Arial', 'FontSize', 17, 'Interpreter', 'none')


i = 1;
localTime = time(changes(i)+10 : (changes(i)+floor(window/ dt)) );

% each file will be a new column
for i = 1:length(files)
    curr = i; % curr keeps track of what tile to plot on   
    
    % Input current on channel 6, always plot this one!
    nexttile(t, curr)
    localRange = In6(changes(i)+10:changes(i)+round(window/ dt));
    plot(localTime, localRange, 'k-', LineWidth=.5)
    xlim([0 win])

    % set row title for only the first column

    if i == 1
        ylabel(gca, inputsName{2}, Rotation=0, FontSize=15);
        set(gca,'xticklabel',[])
        set(gca,'yticklabel',[])
        ax = gca;
        ax.XColor = 'none';
        set(ax, 'color', 'none')
    else
        axis off
    end

    % always put the column title at the top
    columnTitle = tempValues(i) +  " °C " + conditionByFiles{i};
    title(columnTitle, FontSize=15)
    curr = curr + length(files);
    
    % sometimes you'll have an input 5 channel
    if validIn5
        nexttile(t, curr)
        localRange = In5(changes(i)+10:changes(i)+round(window/ dt));
        plot(localTime, localRange, 'k-', LineWidth=.5)
        xlim([0 win])

        if i == 1
            ylabel(gca, inputsName{1}, Rotation=0, FontSize=15);
            set(gca,'xticklabel',[])
            set(gca,'yticklabel',[])
            ax = gca;
            ax.XColor = 'none';
            set(ax, 'color', 'none')
            
        else
            axis off ;
        end

        curr = curr + length(files);

    end

    if valid1
        nexttile(t, curr)
        
        localRange = Vm1(changes(i)+10:changes(i)+round(window/ dt));
        plot(localTime, localRange, 'k-', LineWidth=1.5)
        xlim([0 win])

        if i == 1
            ylabel(gca, electrodeName{1}, Rotation=0, FontSize=15);
            b1 = min(localRange);
            set(gca,'xticklabel',[])
            ax = gca;
            ax.XColor = 'w';
            set(ax, 'color', 'none')
            
        else
            axis off ;
            set(gca,'xticklabel',[])
            set(gca,'yticklabel',[])
        end
        hold on;
        yticks(round(b1));
        plot(localTime, b1 * ones([1, length(localRange)]), 'k--')
        curr = curr + length(files);
        
    end


    if valid2
        nexttile(t, curr)
        localRange = Vm2(changes(i)+10:changes(i)+round(window/ dt));
        localRange = smoothdata(localRange, "gaussian", 50);
        plot(localTime, localRange, 'k-', LineWidth=1.5)
        xlim([0 win])
        if i == 1
            b2 = min(localRange);
            set(gca,'xticklabel',[])
            ylabel(gca, electrodeName{2}, Rotation=0, FontSize=15);
            ax = gca;
            ax.XColor = 'w';
            set(ax, 'color', 'none')
        else
            axis off
            set(gca,'xticklabel',[])
            set(gca,'yticklabel',[])
        end
        hold on;
        yticks(round(b2));
        plot(localTime, b2 * ones([1, length(localRange)]), 'k--')
        curr = curr + length(files);
    end

    if valid3
        nexttile(t, curr)
        localRange = Vm3(changes(i)+10:changes(i)+round(window/ dt));
        plot(localTime, localRange, 'k-', LineWidth=1.5)
        xlim([0 win])
        
        if i == 1
            b3 = min(localRange);
            set(gca,'xticklabel',[])
            ylabel(gca, electrodeName{3}, Rotation=0, FontSize=15);
            ax = gca;
            ax.XColor = 'w';
            set(ax, 'color', 'none')
        else
            axis off
            set(gca,'xticklabel',[])
            set(gca,'yticklabel',[])
        end
        hold on
        yticks(round(b3));
        plot(localTime, b3 * ones([1, length(localRange)]), 'k--')
        curr = curr + length(files);

    end

   % on the last ones, just turn off the axis and plot something not
   % visible so the axes get some bounds set. the first tile in this row
   % wil eventually get a scalebar

    nexttile(t, curr)
    localRange = ones(size(localTime)) * -1;
    plot(localTime, localRange, 'k-', LineWidth=1.5)
    
    xlim([0 win])
    
    set(gca,'xticklabel',[])
    ylabel(gca, electrodeName{3}, Rotation=0, FontSize=15);
    ax = gca;
    ax.XColor = 'w';
    ax.YColor = 'none';
    set(ax, 'color', 'none')


end

% lovely lovely formatting
set(findall(gcf,'-property','fontname'),'fontname','arial')
set(findall(gcf,'-property','box'),'box','off')
set(findall(gcf,'-property','fontsize'),'fontsize',17)

%% Link y axes of tiles along a row, so scale bar matches
allAxes = findall(gcf,'type','axes');
totalRows = valid1 + valid2 + valid3 + validIn5 + validIn6 + 1;
figNums = 1:length(files)*totalRows;

% link y axes along rows (skipping the last row, which for some reason is
% the first in axes... idk man)
for i = 2:totalRows
    idx = figNums(i: totalRows : end);
    linkaxes(allAxes(idx), 'y')

end

%% link x axes of tiles along a column
i = 1;
firstFig = i;
secondFig = totalRows;
% link x axes along columns
for i = 1:length(files)
    linkaxes(allAxes(firstFig:secondFig), 'x')
    firstFig = secondFig + 1;
    secondFig = secondFig + totalRows;
end

%% Wait for user adjustment to x ranges on plots
prompt = "Move x range on any plots to find nice regions! Hit enter when done.";
x = input(prompt);

%% Link y axes again to make sure limits are the same! 
figNums = 1:length(files)*totalRows;

% link y axes along rows
for i = 1:totalRows
    idx = figNums(i: totalRows : end);
    linkaxes(allAxes(idx), 'y')

end

%% Wait for user adjustment to x ranges on plots
prompt = "Y range: Zoom in on any plots! Don't zoom in on x. Hit enter when done.";
x = input(prompt);

%% Get range of y axes on all graphs except last, and make scaling consistent by biggest range
maxRange = 0;

% find the max range between all the rows
% last row on axes is input, which we can just ignore -- this is the first
% row in allAxes
for i = 1:totalRows - (validIn5 + validIn6)
    lims = get(allAxes(i),'YLim');
    yRange = lims(2) - lims(1);
    if yRange > maxRange
        maxRange = yRange;
    end
end

% now apply max range to non-input current rows
% by modifying first entry, you modify the whole row bc axes are linked
for i = 1:totalRows - (validIn5 + validIn6)
    lims = get(allAxes(i),'YLim');
    yRange = lims(2) - lims(1);
    diff = (maxRange - yRange) / 2;

    allAxes(i).YLim = [(lims(1) - diff) (lims(2) + diff)];
end

%% Add a scale bar on the left corner tile (blank row)

nexttile(t, curr - length(files) + 1)
scaleBarAxes = gca;
scaleBarAxes.YLim = [0 maxRange];
s = scalebar;
s.Border = 'LL';
s.XLen = 1;
s.YLen = 10;

%% 

if saveOn == 1
    disp("Figure completed! :D Saving figure as SVG to current working directory.")
    saveName = strcat(targetNotebook, '_', fixedPage, '_', "regions", ".svg")
    saveas(gcf, saveName)
end
