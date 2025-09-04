function [areasActivity1, areasActivity2] = compareAreas(directoryName, targetNotebook, targetPage, activity1, activity2, smoothOn)
% 
% Compares and plots area under the curve for two different conditions, for
% one or multiple animals.
%
% Inputs:
    % directoryName (str): path of raw data folder. If you're on a mac and
    %   getting data from the server, you can leave this field as "auto" and
    %   the function will determine which directory based on the notebook #
    % targetNotebook (int or int array): target notebook of animal(s),
    %   paired with targetPages
    % targetPage (int or int array): target pages
    % activity1 and 2: things like "LG11_11" and "LG_11_21"
% Outputs:
    % areasActivity1 and 2 (double array): area under the curve for each 
    % animal at actvity1 and 2
    % Plots area under the curve over time for stacked conditions
    % Plots a bar graph showing avg total area under the curve for each condition

% This function uses the index conditions on the Real google sheet 
% to identify specific activities. It calls on burstArea to create a mat file 
% (or finds upon already existing one) that stores area data for different
% sections of a voltage trace. 
%

% Last edited: Ananya Dalal Mar 28
%%
areasActivity1 = [];
areasActivity2 = [];

% set up plot to hold area regions
f = figure(100);
t = tiledlayout(length(targetNotebook), 1);
xlabel(t, 'Time (s)', 'FontName', 'Arial', 'FontSize', 13)
ylabel(t, 'mV above Baseline', 'FontName', 'Arial', 'FontSize', 13)
figName = "Area under the curve for 11°C Real Activity at 11°C and 21°C";
title(t, figName, 'FontName', 'Arial', 'FontSize', 15)

% go through target notebook and pages given and plot area under the curve
for i = 1:length(targetNotebook)
    
    % matfiles should all be saved in ananya's folder in server
    fileName = "/Volumes/marder-lab/adalal/MatFiles/" + targetNotebook(i) + "_" + targetPage(i) + "_area.mat";
    
    % if you already have the area mat file in your directory, just load it
    % 
    if exist(fileName, "file")
        m = load(fileName);
        disp(m)
    else
        googleSheet = 'Real';
        % automatically set directory if on auto
        if strcmp(directoryName, "auto")
            if targetNotebook(i) == 988 || targetNotebook(i) == 985 || targetNotebook(i) == 992
                directoryName = "/Volumes/marder-lab/kjacquerie/_raw data";
            elseif targetNotebook(i) == 991
                directoryName = "/Volumes/marder-lab/jzeng/Sen Project/raw data";
            elseif targetNotebook(i) == 943
                directoryName = "/Volumes/marder-lab/apoghosyan/raw data";
            else % just assume it's kathleen's folder
                directoryName = "/Volumes/marder-lab/kjacquerie/_raw data";
            disp("Unknown directory or different pathing, searching in kathleen's folder by default...")
            end
        end
        
        % call on burstArea to make an area storing object
        burstArea(directoryName, targetPage(i), targetNotebook(i), googleSheet);
        m = load(fileName);
    end

    % now find the specific activities requested for the animal
    idx1 = find(ismember(m.activityTemp, activity1), 1, "first");
    % if you're asking for base condition activity second, then you want the
    % end one
    if activity2 == "LG11_11"    
        idx2 = find(ismember(m.activityTemp, activity2), 1, "last");
    else
        idx2 = find(ismember(m.activityTemp, activity2), 1, "first");
    end

    
    % can you find requested activities for the animal (no)
    if isempty(idx1) || isempty(idx2)
        
        disp("Requested animal does not have at least one of the activities. Skipping plot.")
    % you can find activity
    else
        
        areasActivity1 = [areasActivity1, m.areas(idx1)];
        areasActivity2 = [areasActivity2, m.areas(idx2)];
    
        v1 = m.voltages_s(idx1, :);
        v2 = m.voltages_s(idx2, :);
        
        t1 = m.time(idx1, :);
        t2 = m.time(idx2, :);
        


        figure(100); % open figure
        nexttile
        hold on
        if smoothOn == 1
            v1smooth = smoothdata(v1, "gaussian", 3000);
            v2smooth = smoothdata(v2, "gaussian", 3000);
            area(t1, v1smooth, "LineStyle","none", "FaceColor", "#808080");
            area(t2, v2smooth, "LineStyle","none", "FaceColor", "#C00000")        
        else
            area(t1, v1, "LineStyle","none", "FaceColor", "#808080")
            area(t2, v2, "LineStyle","none", "FaceColor", "#C00000")
        end


        legend({activity1, activity2}, 'Interpreter', 'none', 'FontName', 'Times', 'Location','eastoutside')
    
        figTitle = "Animal " + m.animal;
        title(figTitle, 'Interpreter', 'none', 'FontName', 'Arial')
        set(findall(gcf,'-property','fontname'),'fontname','arial')

        allAxes = findall(gcf,'type','axes');
        linkaxes(allAxes, 'x')

    end
end

%% Line plot of areas for diff conditions
figure()
hold on
% just short form of name for clarity
a1 = areasActivity1;
a2 = areasActivity2;

mean1 = mean(a1);
mean2 = mean(a2);

x1 = ones(length(a1), 1);
x2 = 2 * ones(length(a2), 1);

bar(1, mean1, 'FaceColor', "#808080")
bar(2, mean2, 'FaceColor', "#C00000")

scatter(x1, a1, "filled", "o", "MarkerFaceColor", "#000000")
scatter(x2, a2, "filled", "o", "MarkerFaceColor", "#000000")

% Plot pairwise lines from condition 1 to condition 2
for i = 1:length(a1)
    plot([x1(i), x2(i)], [a1(i), a2(i)], "k-")
end

% get standard error for both bars
err1 = std(a1) / sqrt(length(a1));
err2 = std(a2) / sqrt(length(a1));

err = [err1, err2];

er = errorbar([1, 2], [mean1, mean2], err, err);
er.Color = [0 0 0];                            
er.LineStyle = 'none'; 
er.LineWidth = 1.5;
ax = gca;
ax.XTick = [1, 2];
ax.XTickLabels = {activity1,activity2};
ax.TickLabelInterpreter = "none";
title("Area Under the Curve for Individual Animals", 'FontSize', 15)
xlabel("Condition", 'FontSize', 13)
ylabel("Area under the voltage curve (mV * s)", 'FontSize', 13)
set(findall(gcf,'-property','fontname'),'fontname','times')








