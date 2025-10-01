
% Use this to plot force transducer analysis. You don't need to already
% have done the analysis; it'll call forceTransAnalysis.m on your experiment
% if there isn't stored peak data

% Set these with your nbs and pages
nbs = [998 998 998];
pages = [24 28 46];

close all
metadataMaster % Make sure your experiment is in this file (within Routing and Metadata folder)

figure(101)
hold on
% p = fill([21 35 35 21],[0 0 1.4 1.4], [.9 .9 .9]);
% xlim([10 35])
% ylim([0 1.4])
% p.EdgeColor = 'none';


figure(102)
hold on
% p = fill([21 35 35 21],[0 0 .02 .02], [.9 .9 .9]);
% xlim([10 35])
% ylim([0 0.02])
% p.EdgeColor = 'none';


for i = 1:length(nbs)
    
    targetNotebook = nbs(i);
    targetPage = pages(i);

    dataPeaks = forceTransAnalysis(targetNotebook, targetPage);
    
    expName = "NB: " + targetNotebook + " page " + targetPage;
    temps = metadata(targetNotebook, targetPage).tempValues;
    % Plotting! 

    freq = [];
    freqErr = [];
    amp = [];
    ampErr = [];
    
    realTemps = []; % only plot temps for which there is usable data 
    
    for t = temps
        % find peaks at that temperature
        idxTemp = find(dataPeaks.temp > t - .3 & dataPeaks.temp < t + .3);
    
        if ~isempty(idxTemp)
    
            freq = [freq mean(dataPeaks.freq(idxTemp))];
            freqErr = [freqErr std(dataPeaks.freq(idxTemp)) / sqrt(length(idxTemp))];
            
            amp = [amp mean(dataPeaks.amp(idxTemp))];
            ampErr = [ampErr std(dataPeaks.amp(idxTemp))/ sqrt(length(idxTemp))];
    
            realTemps = [realTemps, t];
        end
    
    
    end
    
    lineColor = 'k';
    faceColor = 'k';
    
    if targetNotebook == 986
        shape = '^';
    else
        shape = 'square';
    end   

    figure(101)
    
    plot(realTemps, freq, 'DisplayName', expName, "LineWidth", 2)
    hold on

    figure(102)
    
    plot(realTemps, amp, 'DisplayName', expName, 'LineWidth',2)
    hold on
    
end

figure(101)
    title("FT Frequency")
    ylabel("Frequency (Hz)")
    xlabel("Temperature (°C)")
    l = legend;
    l.Location = 'eastoutside';
    set(findall(gcf,'-property','fontname'),'fontname','times')
    set(findall(gcf,'-property','box'),'box','off')
    set(findall(gcf,'-property','fontsize'),'fontsize',20)

figure(102)
    title("FT force")
    ylabel("Force (N)")
    xlabel("Temperature (°C)")
    l = legend;
    l.Location = 'eastoutside';
    set(findall(gcf,'-property','fontname'),'fontname','times')
    set(findall(gcf,'-property','box'),'box','off')
    set(findall(gcf,'-property','fontsize'),'fontsize',20)