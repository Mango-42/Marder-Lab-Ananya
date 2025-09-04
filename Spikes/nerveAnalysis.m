function [similarityScore] = nerveAnalysis(notebooks, pages, nerve)
    %%
    % Description: Compare bursting nerve activity for one or multiple animals 
    % at different conditions / temperatures --> right now only works on
    % lvn

close all
figure(100)
    title("Interburst frequency")
    xlabel("Temperature (C)")
    hold on
figure(101)
        title("Intraburst frequency")
        xlabel("Temperature (C)")
        hold on
figure(102)
        title("Spikes per burst")
        xlabel("Temperature (C)")
        hold on
figure(103)
        title("Duty Cycle")
        xlabel("Temperature (C)")
        hold on

idx11 = 0;
idx4 = 0;
idx18 = 0;
metadataMaster

for i = 1:length(notebooks)

    nb = notebooks(i);
    page = pages(i);
    
    temps = metadata(nb, page).tempValues;
    files = metadata(nb, page).tempFiles;
    if ~isempty(metadata(nb, page).abfOffset)
        files = files - metadata(nb, page).abfOffset;
    end

    activities = [];

    for i = 1:length(files)
        data = loadBurstStats(nb, page, "roi");
        
        activities = [activities, data.(nerve){i}];
        
    end

    inter = [];
    intra = [];
    spikesPer = [];
    dCycle = [];

    interErr = [];
    intraErr = [];
    spikesPerErr = [];
    dCycleErr = [];
    
    for i = 1:length(files)
            inter = [inter, mean(activities(i).inter)];
            intra = [intra, mean(activities(i).intra)];
            spikesPer = [spikesPer, mean(activities(i).spikesPer)];
            dCycle = [dCycle, mean(activities(i).dCycle)];

            interErr = [interErr, std(activities(i).inter) / sqrt(length(activities(i).inter))];
            intraErr = [intraErr, std(activities(i).intra) / sqrt(length(activities(i).intra))];
            spikesPerErr = [spikesPerErr, std(activities(i).spikesPer) / sqrt(length(activities(i).spikesPer))];
            dCycleErr = [dCycleErr, std(activities(i).dCycle) / sqrt(length(activities(i).dCycle))];
    end
    

    expName = "NB: " + nb + " page " + page ;

    % Plot parameters for line colors by acclimation 
    shapes = {'o', 'square', 'diamond', '^'};
    if metadata(nb, page).acclimation == 11
        lineColor = 'k-';
        faceColor = 'k';
        idx11 = idx11 + 1;
        shape = shapes{idx11};
    elseif  metadata(nb, page).acclimation == 4
        lineColor = 'b-';
        faceColor = 'b';
        idx4 = idx4 + 1;
        shape = shapes{idx4};
    elseif  metadata(nb, page).acclimation == 18
        lineColor = 'r-';
        idx18 = idx18 + 1;
        faceColor = 'r';
        shape = shapes{idx18};
    end

    disp(shape)

    
    figure(100)
         errorbar(temps, inter, interErr, "vertical",lineColor, "Marker", shape, ...
             "MarkerSize",5, "MarkerEdgeColor",faceColor, ...
             "MarkerFaceColor",faceColor, 'DisplayName', expName)

    figure(101)
         errorbar(temps, intra, intraErr, "vertical",lineColor, "Marker", shape, ...
             "MarkerSize",5, "MarkerEdgeColor",faceColor, ...
             "MarkerFaceColor",faceColor, 'DisplayName', expName)

    figure(102)
         errorbar(temps, spikesPer, spikesPerErr, "vertical",lineColor, "Marker", shape, ...
             "MarkerSize",5, "MarkerEdgeColor",faceColor, ...
             "MarkerFaceColor",faceColor, 'DisplayName', expName)

    figure(103)
         errorbar(temps, dCycle, dCycleErr, "vertical",lineColor, "Marker", shape, ...
             "MarkerSize",5, "MarkerEdgeColor",faceColor, ...
             "MarkerFaceColor",faceColor, 'DisplayName', expName)
end

for i = 100:103
    figure(i)
    l = legend;
    l.Location = 'eastoutside';
    % lovely lovely formatting
    set(findall(gcf,'-property','fontname'),'fontname','arial')
    set(findall(gcf,'-property','box'),'box','off')
    set(findall(gcf,'-property','fontsize'),'fontsize',17)
end

