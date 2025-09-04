%
nbs = [986 986 986 986 986 986 993 993 993 993 993];
pages = [92 110 112 116 120 124 8 9 10 11 12];

close all
metadataMaster

figure(101)
hold on
p = fill([21 35 35 21],[0 0 1.4 1.4], [.9 .9 .9]);
xlim([10 35])
ylim([0 1.4])
p.EdgeColor = 'none';


figure(102)
hold on
p = fill([21 35 35 21],[0 0 .02 .02], [.9 .9 .9]);
xlim([10 35])
ylim([0 0.02])
p.EdgeColor = 'none';




for i = 1:length(nbs)
    
    targetNotebook = nbs(i);
    targetPage = pages(i);

    dataPeaks = heartAnalysis(targetNotebook, targetPage);
    
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
    title("Heartbeat frequency")
    ylabel("Frequency (Hz)")
    xlabel("Temperature (°C)")
    l = legend;
    l.Location = 'eastoutside';
    set(findall(gcf,'-property','fontname'),'fontname','times')
    set(findall(gcf,'-property','box'),'box','off')
    set(findall(gcf,'-property','fontsize'),'fontsize',20)

figure(102)
    title("Heartbeat force")
    ylabel("Force (N)")
    xlabel("Temperature (°C)")
    l = legend;
    l.Location = 'eastoutside';
    set(findall(gcf,'-property','fontname'),'fontname','times')
    set(findall(gcf,'-property','box'),'box','off')
    set(findall(gcf,'-property','fontsize'),'fontsize',20)