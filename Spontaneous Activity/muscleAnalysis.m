function [similarityScore] = muscleAnalysis(datas, notebooks, pages, metadata)
    %%
    % Description: Makes clean plots of quantification metrics for diff
    % temps and acclimations for animals 

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

for i = 1:length(notebooks)

    nb = notebooks(i);
    page = pages(i);
    data = datas(i);

    % Load data
    %data = loadExperiment(nb, page, metadata);
    
    temps = metadata(nb, page).tempValues;
    files = metadata(nb, page).tempFiles;

    spikes = getSpikeTimes("auto", nb, page);
    storeActivity = [];
    storeRobust = [];

    for i = files
        [activity, robust] = burstAnalysis(spikes.LP{i + 1}, "LP", data.lvn{i + 1});
        storeActivity = [storeActivity, activity];
        storeRobust = [storeRobust, robust];
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
            inter = [inter, storeActivity(i).inter];
            intra = [intra, storeActivity(i).intra];
            spikesPer = [spikesPer, storeActivity(i).spikesPer];
            dCycle = [dCycle, storeActivity(i).dCycle];

            interErr = [interErr, storeRobust(i).inter];
            intraErr = [intraErr, storeRobust(i).intra];
            spikesPerErr = [spikesPerErr, storeRobust(i).spikesPer];
            dCycleErr = [dCycleErr, storeRobust(i).dCycle];
    end

    expName = "NB: " + nb + " page " + page;
    figure(100)
         errorbar(temps, inter, interErr, "vertical","k-", "Marker", 'o', ...
             "MarkerSize",5, "MarkerEdgeColor","k", ...
             "MarkerFaceColor","k", 'DisplayName', expName)

    figure(101)
         errorbar(temps, intra, intraErr, "vertical","k-", "Marker", 'o', ...
             "MarkerSize",5, "MarkerEdgeColor","k", ...
             "MarkerFaceColor","k", 'DisplayName', expName)

    figure(102)
         errorbar(temps, spikesPer, spikesPerErr, "vertical","k-", "Marker", 'o', ...
             "MarkerSize",5, "MarkerEdgeColor","k", ...
             "MarkerFaceColor","k", 'DisplayName', expName)

    figure(103)
         errorbar(temps, dCycle, dCycleErr, "vertical","k-", "Marker", 'o', ...
             "MarkerSize",5, "MarkerEdgeColor","k", ...
             "MarkerFaceColor","k", 'DisplayName', expName)
end

for i = 100:103
    figure(i)
    xticks(temps)
    legend
    % lovely lovely formatting
    set(findall(gcf,'-property','fontname'),'fontname','arial')
    set(findall(gcf,'-property','box'),'box','off')
    set(findall(gcf,'-property','fontsize'),'fontsize',17)
end

