function [] = tiledHeart(targetNotebook, targetPage, win)
%%
datasheet = import_googlesheet("FTHeart");

targetNB = string(targetNotebook);
targetP = string(targetPage);

% Find rows where the 'page' column matches 'targetPage'
row = strcmp(datasheet.page, targetP) & strcmp(datasheet.notebook, targetNB) ; % can switch to contains

% Display the rows where the page matches the target
notebook = str2double(targetNB); %str2double(datasheet.notebook{row});
page = str2double(targetP); 
files = datasheet.files{row};
tempValues = datasheet.temp_index{row};
condIndex = datasheet.condition_index{row};
conditions = datasheet.conditions{row};
cal = datasheet.Calibration(row);

figure(100)
t = tiledlayout(1, length(files));

if isMATLABReleaseOlderThan("R2024b") == false
    t.TileSpacing = 'tight';
    t.Padding = 'compact';
end
title(t, "FT Heart Temp Ramp NB " + targetNB + " page " + targetP)

for i = 1:length(files)
    [data, ~, ~] = plotOverview("auto", targetPage, targetNotebook, "FTHeart", 0, files(i));
    figure(100)
    nexttile
    
    % gives measure in N -- divide by calibration val 
    % and then by .001 kg * 9.8 m / s^2
    force = ((data.Vm1 - min(data.Vm1)) / cal) * (.001 * 9.8);
    plot(data.t, force, 'k-', LineWidth=1.5)
    xlim([0 win]) 
    xticks([])
    if i ~= 1
        axis off

    end

    columnTitle = tempValues(i) +  " °C " + conditions{condIndex(i) + 1};
    title(columnTitle) 
end

% show only two values for yticks on the first panel
nexttile(1)
yt = yticks;
yticks([0 yt(end)/2 yt(end)])
yticks('manual')
xlabel(win + " s")
ylabel("Force (N)")




allAxes = findall(gcf,'type','axes');
linkaxes(allAxes, 'y')

set(findall(gcf,'-property','fontname'),'fontname','arial')
set(findall(gcf,'-property','box'),'box','off')
set(findall(gcf,'-property','fontsize'),'fontsize',17)