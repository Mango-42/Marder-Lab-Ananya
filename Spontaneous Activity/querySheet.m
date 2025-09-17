function [] = querySheet(googleSheet, acclimation, muscle, analysis, win)
    
    %% Description: runs and plots requested analysis on all animals for 
    % a certain muscle acclimation temp found on the google sheet. 

    % Inputs:
        % googleSheet (str) - name for import google sheet
            % 'EJP', 'EJC', 'Real' etc
        % acclimation (int) - acclimation temperature, ie 4, 11, 18, or
        % "all"
        % muscle (str) - muscle, ie "gm5b"
        % analysis (str) - as of now, you can run the following:  

            % "singleBurst" - single burst plotting at 11 and 21 C
                % sample figure at smb://research.brandeis.edu/marder-lab/adalal/Figures/gm5bRegional.svg
                
            % "peaks" - spontaneous activity peaks analysis
                % figures for temp vs frequency, amplitude, and vrest

            % "peaksBin" - spontaneous activity peaks analysis
                % figures for temp vs frequency, amplitude, and vrest
                % but as binned temperature

        % win (int) - only used for singleBurst analysis-- range to plot 
            % ie, 1 sec, 5 sec, etc

    % Dependencies
        % plotOverview.m
        % import_googlesheet.m
        % singleBurst.m (for analysis == "singleBurst")
        % expAnalysis.m (for analysis == "peaks")

    % Last edited: Ananya Dalal Jun 16

%% Find experiments with requested muscle and acclimation temp
close all
datasheet = import_googlesheet(googleSheet);

if isstring(acclimation) & acclimation == "all"
    accRows = 1:height(datasheet);
else
    accRows = transpose(find(datasheet.acclimation == string(acclimation)));

end
rows = [];
for i = accRows
    if sum(strcmp(datasheet.electrodes{i}, muscle)) >= 1
        rows = [rows, i];
    end
end

%% Get outline 

if analysis == "singleBurst"
    figure(100)
    
    t = tiledlayout(length(rows), 2);
    
    if muscle == "gm5b" || muscle == "gm6"
        win = 10;
    else
        win = 1.5;
    end
    
    title(t, ("Trace: " + muscle + " " + win + "s"), fontsize=17)
end

if analysis == "peaks" || analysis == "peaksBin"
    % make three separate figures for frequency, amplitude, and vrest
    figure(101)
    hold on
    xlim([10 inf])
    xlabel("Temperature (°C)")
    ylabel("Frequency (Hz)")
    title(muscle + " frequency vs temp")

    p = fill([21 35 35 21],[0 0 4 4], [.9 .9 .9]);

    ylim([0 4])
    xlim([10 35])
    p.EdgeColor = 'none';

    set(findall(gcf,'-property','fontname'),'fontname','times')
    set(findall(gcf,'-property','box'),'box','off')
    set(findall(gcf,'-property','fontsize'),'fontsize',20)

    figure(102)
    hold on
    
    xlabel("Temperature (°C)")
    ylabel("Amplitude (mV)")
    title(muscle + " amplitude")

    p = fill([21 35 35 21],[0 0 25 25], [.9 .9 .9]);

    ylim([0 25])
    xlim([10 35])
    p.EdgeColor = 'none';

    set(findall(gcf,'-property','fontname'),'fontname','times')
    set(findall(gcf,'-property','box'),'box','off')
    set(findall(gcf,'-property','fontsize'),'fontsize',20)

    figure(103)
    hold on
    xlim([10 inf])
    xlabel("Temperature (°C)")
    ylabel("V rest (mV)")
    title(muscle + " V rest")

    set(findall(gcf,'-property','fontname'),'fontname','arial')
    set(findall(gcf,'-property','box'),'box','off')
    set(findall(gcf,'-property','fontsize'),'fontsize',17)

end


idx11 = 0;
idx4 = 0;
idx18 = 0;

j = 0;
% for all matching animals with the muscle and acclimation...
for i = rows

    notebook = str2double(datasheet.notebook{i});
    page = str2double(datasheet.page{i});

    
    expName = "NB: " + notebook + " page " + page;
    
    % single burst plotting at 11 and 21
    if analysis == "singleBurst"
        [time, data11, data21] = singleBurst(datasheet, notebook, page, googleSheet, muscle);
        if time == -1
            continue
        end
        figure(100)
        nexttile
        plot(time, data11, 'k-', LineWidth=1.5)
        set(gca,'xticklabel',[])
        ax1 = gca;
        ax1.XColor = 'none';
        xlim([0, win])
        % fix this line below and then debug wtf is happening in first plot now
        ylabel("NB " + notebook + " page " + page, Rotation=0)
        
        nexttile
        plot(time, data21, 'k-', LineWidth=1.5)
        set(gca,'xticklabel',[])
        ax2 = gca;
        ax2.XColor = 'none';
        xlim([0, win])
    end

    % continuous peaks data (help to gauge what experiments are usable)
    if analysis == "peaks"
        % get data
        files = datasheet.files{i};
        [~, idxMaxTemp] = max(datasheet.temperature_values{i});
        [data] = expAnalysis(notebook, page, googleSheet, muscle, 3, -35, files(1):files(idxMaxTemp));
        
        % Make plotting by acclimation temp 
        % diff shapes for 11 deg and diff shades for acclimated 
        shapes = {'o', '+', '*', 'square', 'diamond', '^'};
        if datasheet.acclimation{i} == "11"
            colors = {'#100c08', '#3b3c36' '#483c32', '#333333', '#232b2b'};
            idx11 = idx11 + 1;
            color = colors{idx11};
        elseif datasheet.acclimation{i} == "4"
            colors = {'#add8e6', '#6495ed' '#003153', '#006994'};
            idx4 = idx4 + 1;
            color = colors{idx4};
        elseif  datasheet.acclimation{i} == "18"
            colors = {'#f08080','#8b0000', '#7c4848', '#ff4040 '};
            idx18 = idx18 + 1;
            color = colors{idx18};
        end

        % plot data, get different shapes bc sometimes you have a lot of
        % data series

        if mod(j, 2) == 0
            shape = 'o';
        else
            shape = '^';
        end
        j = j + 1;

        figure(101)
        scatter(data.temp, data.freq, shape, 'DisplayName', expName)
        l = legend;
        l.Location = 'eastoutside';
        figure(102)
        scatter(data.temp, data.peaks - data.rest, shape, 'DisplayName', expName)
        l = legend;
        l.Location = 'eastoutside';

        figure(103)
        scatter(data.temp, data.rest, shape, 'DisplayName', expName)
        l = legend;
        l.Location = 'eastoutside';

    end


if analysis == "peaksBin"

    files = datasheet.files{i};
    [~, idxMaxTemp] = max(datasheet.temperature_values{i});
    [data] = expAnalysis(notebook, page, googleSheet, muscle, 3, -35, files(1):files(idxMaxTemp));

    freq = [];
    freqErr = [];
    amp = [];
    ampErr = [];
    rest = [];
    restErr = [];

    temps = unique(datasheet.temperature_values{i}, "sorted");

    realTemps = []; % only plot temps for which there is usable data 

    for t = temps
        % find peaks at that temperature
        idxTemp = find(data.temp > t - .3 & data.temp < t + .3);

        if ~isempty(idxTemp)
    
            freq = [freq mean(data.freq(idxTemp))];
            freqErr = [freqErr std(data.freq(idxTemp)) / sqrt(length(idxTemp))];
            l = legend;
            l.Location = 'eastoutside';
            
            amp = [amp mean(data.peaks(idxTemp) - data.rest(idxTemp))];
            ampErr = [ampErr std(data.peaks(idxTemp) - data.rest(idxTemp))/ sqrt(length(idxTemp))];
            l = legend;
            l.Location = 'eastoutside';
    
            rest = [rest mean(data.rest(idxTemp))];
            restErr = [restErr std(data.rest(idxTemp)) / sqrt(length(idxTemp))];

            realTemps = [realTemps, t];
        end

    end

    
    % Plot
    shapes = {'o', '*', 'square', 'diamond', '^', 'x', '.', 'pentagram'};
    if datasheet.acclimation{i} == "11"
        idx11 = idx11 + 1;
        shape = shapes{idx11};
        lineColor = 'k';
        faceColor = 'k';
    elseif datasheet.acclimation{i} == "4"
        idx4 = idx4 + 1;
        shape = shapes{idx4};
        lineColor = 'b';
        faceColor = 'b';
    elseif  datasheet.acclimation{i} == "18"
        idx18 = idx18 + 1;
        lineColor = 'r';
        faceColor = 'r';
        shape = shapes{idx18};
    end
        
    figure(101)
    plot(realTemps, freq, 'DisplayName', expName, 'LineWidth', 2)
    l = legend;
    l.Location = 'eastoutside';

    figure(102)
    plot(realTemps, amp, 'DisplayName', expName, 'LineWidth', 2)
    l = legend;
    l.Location = 'eastoutside';
    
    figure(103)
    errorbar(realTemps, rest, restErr, "vertical",lineColor, "Marker", shape, ...
    "MarkerSize",5, "MarkerEdgeColor",faceColor, ...
    "MarkerFaceColor",faceColor, 'DisplayName', expName)
    l = legend;
    l.Location = 'eastoutside';


end

%%
end

if analysis == "singleBurst"
    allAxes = findall(gcf,'type','axes');
    linkaxes(allAxes, 'y')
    
    prompt = "Make any edits and hit enter when done to fix window size";
    x = input(prompt);
    
    for i= 1:length(allAxes)
        lims = get(allAxes(i),'XLim');
         allAxes(i).XLim = [lims(1) lims(1) + win];
    end
    
    set(findall(gcf,'-property','fontname'),'fontname','arial')
    set(findall(gcf,'-property','box'),'box','off')
    set(findall(gcf,'-property','fontsize'),'fontsize',17)
end


