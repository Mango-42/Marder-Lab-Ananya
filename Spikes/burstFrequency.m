function [burstStartTimes] = burstFrequency(targetNotebook, targetPage, googleSheet, nerve, crabsortPath, electrode, lastFile)
    
    %% UPDATE July 17 Recommend using burstAnalysis instead 
    %% Description: adapted from condenseSpikeTimes.m in basic analysis code in the lab
    % google drive. Gets start times for bursts. 

    % Requires that you've already sorted spikes for the
    % experiment.



    % Inputs:
        % targetNotebook (int) - page of notebook
        % targetPage (int) - page of experiment
        % googleSheet (str) - name for import google sheet
            % 'EJP', 'EJC', 'Real' etc
        % nerve (str) - currently supports "LP" or "PD"
        % crabsortPath (str) - general folder containing different exp crabsorts
        % electrode (int) - either 5 or 6 for In_5 or In_6. Lets you cross
            % check alignment of spikes with raw nerve traces
        % lastFile (int) - in case only part of an experiment is sorted, this
        % tells to ignore this file and beyonds' spikes

    % Dependencies
        % plotOverview.m

    % Last edited: Ananya Dalal July 17 2025

%% Get spike times (adapted from condenseSpikeTimes.m)
if crabsortPath == "auto"
    % i still cant figure out sprintf lmao
    if targetPage < 100
        folderid = "/Users/ananyadalal/Documents/MATLAB/tools/Marder/Crabsorts/" + targetNotebook + "_" + "0" + targetPage;
    else
        folderid = "/Users/ananyadalal/Documents/MATLAB/tools/Marder/Crabsorts/" + targetNotebook + "_" + targetPage;
    end
end

fids = dir(folderid);
elapsedTime = 0;

spikes = [];

% load in spikes 
for ii=1:(length(fids)) %f or all the files in our data set...

    if strfind(fids(ii).name,'crabsort') % only look at files that end in 'crabsort'
        
         load(fids(ii).name,'-mat'); %s ave the data from the abf file
         
        if nerve == "LP"
            try 
                next_spikes = ...
                    crabsort_obj.spikes.lvn.LP*1e-4 + elapsedTime;
            catch %catch files where there are no spikes
                next_spikes = []; 
            end 
        end

        if nerve == "PD"
            try
             next_spikes = ...
                 crabsort_obj.spikes.pdn.PD*1e-4 + elapsedTime;
            catch
                next_spikes = [];
            end
        end
            % add current file spikes to the overall array of spikes
            spikes = [spikes; next_spikes];
       
        elapsedTime = elapsedTime + 120; %add up overall time

    end 
end

% restrict spike times to files that are actually sorted
spikes = spikes(spikes < (lastFile + 1) * 120);

%% Get burst starts
burstStartTimes = [];
isi = diff(spikes);

% detecting the starts of bursts
for i = 2:length(isi)
    
    if 15 * isi(i) < isi(i - 1) % kind of arbitrary threshold, if one isi is much bigger then new burst
        burstStartTimes = [burstStartTimes; spikes(i)];
    end
end


%% Get experiment data and traces to verify spike times
[data, ~, ~] = plotOverview("auto", targetPage, targetNotebook, googleSheet, 0, "full");

figure
hold on
if electrode == 5
    nerveData = data.In5(int64(spikes * 10000)); 
    plot(data.t, data.In5)
    scatter(burstStartTimes, data.In5(int64(burstStartTimes * 10000)))

elseif electrode == 6
    nerveData = data.In6(int64(spikes * 10000));
    plot(data.t, data.In6)
    scatter(burstStartTimes, data.In6(int64(burstStartTimes * 10000)))
end

%% Show temperature vs burst frequency
temp = data.Temp(int64(burstStartTimes * 10000));
isiBursts = diff(burstStartTimes);
temp = temp(1:end - 1);

freq = 1./isiBursts;
figure
scatter(temp,freq);

xlim([10 inf])
xlabel("Temperature (°C)")
ylabel("Frequency (Hz)")
title("Temperature vs Frequency NB: " + targetNotebook + " page " + targetPage)
set(findall(gcf,'-property','fontname'),'fontname','arial')
set(findall(gcf,'-property','box'),'box','off')
set(findall(gcf,'-property','fontsize'),'fontsize',17)

