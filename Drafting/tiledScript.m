% ONLY DO THIS WITH INFINITE TRUST I STG
googleSheet = 'Intact';
datasheet = import_googlesheet(googleSheet);
%%
% quick test
targetNotebook = 992;
targetPage = 50;

saveOn = 0; % change to 1 if you want to save plot
range = "roi"; 

% get voltage traces from the experiment
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

% traces and timed data 
Vm1 = data.Vm1_d; % trace of Vm1
Vm2 = data.Vm2_d; % trace of Vm1
Vm3 = data.Vm3_d; % trace of Vm3
time = data.t_d; % time
Vin = data.Pulse_d; % input current / pulses
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

%  detect electrodes that were actually not recording (not just NA) by mean value
valid1 = mean(Vm1) ~= 0;
valid2 = mean(Vm2) ~= 0;
valid3 = mean(Vm3) ~= 0;

win = 2; % actual parameter
window = 3 * win; % leave wiggle room in plotting
% so that you can move around the site of an electrode popping out or smth

dt = 0.001;

f = figure(100);
t = tiledlayout((valid1 + valid2 + valid3 + 1), length(files));
xlabel(t, 'Time (s)', 'FontName', 'Arial', 'FontSize', 13)
ylabel(t, 'Voltage (mV)', 'FontName', 'Arial', 'FontSize', 13)
figName = "Experiment Regions: " + targetNotebook + "_" + targetPage + " Window = " + win + " seconds";
title(t, figName, 'FontName', 'Arial', 'FontSize', 15, 'Interpreter', 'none')

i = 1;
localTime = time(changes(i)+1 : (changes(i)+floor(window/ dt)) );

% each file will be a new column
for i = 1:length(files)
    disp(i)
    curr = i; % curr keeps track of what tile to plot on   
    if valid1
        nexttile(t, curr)
        
        localRange = Vm1(changes(i)+1:changes(i)+round(window/ dt));
        plot(localTime, localRange)
        xlim([0 win])
        columnTitle = tempValues{i} +  " °C " + conditionByFiles{i};
        
        % set row title for only the first column
        if i == 1
            ylabel(gca, electrodeName{1}, Rotation=0, FontSize=13);
            set(gca,'xticklabel',[])
            ax = gca;
            ax.XColor = 'w';
            
        else
            axis off ;
            set(gca,'xticklabel',[])
            set(gca,'yticklabel',[])
        end
        title(columnTitle)
        curr = curr + length(files);
        
    end

    if valid2
        nexttile(t, curr)
        localRange = Vm2(changes(i)+1:changes(i)+round(window/ dt));
        plot(localTime, localRange)
        xlim([0 win])
        if i == 1
            set(gca,'xticklabel',[])
            ylabel(gca, electrodeName{2}, Rotation=0, FontSize=13);
            ax = gca;
            ax.XColor = 'w';
        else
            axis off
            set(gca,'xticklabel',[])
            set(gca,'yticklabel',[])
        end
        curr = curr + length(files);
    end

    if valid3
        nexttile(t, curr)
        localRange = Vm3(changes(i)+1:changes(i)+round(window/ dt));
        plot(localTime, localRange)
        xlim([0 win])
        
        if i == 1
            set(gca,'xticklabel',[])
            ylabel(gca, electrodeName{3}, Rotation=0, FontSize=13);
            ax = gca;
            ax.XColor = 'w';
        else
            axis off
            set(gca,'xticklabel',[])
            set(gca,'yticklabel',[])
        end
        curr = curr + length(files);
    end
    
    % Input current, you should always plot this one
    nexttile(t, curr)
    localRange = Vin(changes(i)+1:changes(i)+round(window/ dt));
    plot(localTime, localRange)
    xlim([0 win])
    
    if i == 1
        ylabel(gca, "lvn", Rotation=0, FontSize=13);
        set(gca,'xticklabel',[])
        ax = gca;
        ax.XColor = 'w';
    else
        axis off
        set(gca,'xticklabel',[])
        set(gca,'yticklabel',[])
    end

end

% lovely lovely formatting
set(findall(gcf,'-property','fontname'),'fontname','arial')
set(findall(gcf,'-property','box'),'box','off')
t.TileSpacing = 'compact';
t.Padding = 'compact';

%% Link y axes of tiles along a row, so scale bar matches
allAxes = findall(gcf,'type','axes');
totalRows = valid1 + valid2 + valid3 + 1;
figNums = 1:length(files)*totalRows;

% link y axes along rows
for i = 1:totalRows
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
% %% Link all y axes of rows, except the last one
% 
% idx = figNums(1: totalRows : end);
% ran = 1:totalRows*length(files)
% ran(idx) = 0
% ran = find(ran)
% linkaxes(allAxes(ran), 'y')

%% Wait for user adjustment to x ranges on plots
prompt = "Y range: Zoom in on any plots! Don't zoom in on x.Hit enter when done. ";
x = input(prompt);

%% Get range of y axes on all graphs except last, and make scaling consistent by biggest range
maxRange = 0

% find the max range between all the rows
% last row on axes is input, which we can just ignore -- this is the first
% row in allAxes
for i = 2:totalRows
    lims = get(allAxes(i),'YLim')
    yRange = lims(2) - lims(1)
    if yRange > maxRange
        maxRange = yRange
    end
end

% now apply max range to non-input current rows
% by modifying first entry, you modify the whole row bc axes are linked
for i = 2:totalRows
    lims = get(allAxes(i),'YLim')
    yRange = lims(2) - lims(1)
    diff = (maxRange - yRange) / 2

    allAxes(i).YLim = [(lims(1) - diff) (lims(2) + diff)]
end

% %% Add a time scale bar
% allAxes(2)
% 
% s = scalebar
% s.Border = 'LL'
% s.XLen = 1
% s.YLen = 0
% s.XUnit = "se2"
