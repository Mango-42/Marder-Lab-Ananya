function [dataPeaks] = expAnalysis(targetNotebook, targetPage, googleSheet, channel, peakProm, thresh, range)
    %% Description: get quantifications for spontaneous activity 
    % Returns vrest, frequency, and amplitude changes over time from a
    % trace. 
    % Known issues: will fail when no peaks are detected
    % undefined frequency output for gm muscles still (amplitude and
    % vrest are fine)

    % Inputs:
        % targetNotebook (int) -  notebook of experiment, ie, 992, 943, etc
        % targetPage (int) - page of experiment
        % targetNotebook (int) - page of notebook
        % googleSheet (str) - name for import google sheet
            % 'EJP', 'EJC', 'Real' etc
        % channel (str) - name of muscle, ie, "gm5b" in google sheet
        % peakProm (int) - minimum peak prominence for good spike detection
            % usually around 3 to 10
        % thresh (int) - upper limit to detect when electrode falls out
        % can be set to -35, -30 by default and generally will do its
        % job

        % range (str, or int array) - range of experiment's abf files
            % 'full' for getting full range of experiment
            % 'roi' for getting only abf files stated in google sheet
            % or int array with range of files ie [0:10] or [1, 2, 7, 8,], etc
            
    % Outputs:
        % dataPeaks (table): has these fields for each detected peak
            % peaks - value of peak
            % freq - instantaneous frequency calculated by ISI
            % temp - mean temp in the ISI after the peak
            % rest - vrest at time of the peak, calculated by getRest

    % Dependencies: 
        % plotOverview.m
        % import_googlesheet.m
        % getRests.m

    % Last edited: Ananya Dalal July 17

%% Access data from experiment

filename = "/Volumes/marder-lab/adalal/MatFiles/" + targetNotebook + "_" + targetPage + "_" + channel + "_peaks.mat";

% Try to load experiment data if it's already there in ananya's folder
if exist(filename, "file")
    dataPeaks = load(filename);
else
    dataPeaks = matfile(filename,'Writable',true);
    
    [~, ~, d] = plotOverview("auto", targetPage, targetNotebook, googleSheet, 0, range);
    
    % Google sheet handling to get name of electrode
    targetNotebook = string(targetNotebook);
    targetPage = string(targetPage);
    notebook = str2double(targetNotebook); %str2double(datasheet.notebook{row});
    page = str2double(targetPage); 
    
    datasheet = import_googlesheet(googleSheet);
    
    row = strcmp(datasheet.page, targetPage) & strcmp(datasheet.notebook, targetNotebook);
    
    electrodes = datasheet.electrodes{row};
    nerves = datasheet.extra{row};
    
    if strcmp(channel, electrodes{1})
        v = d.Vm1_d;
    elseif strcmp(channel, electrodes{2})
        v = d.Vm2_d;
    elseif strcmp(channel, electrodes{3})
        v = d.Vm3_d;
    elseif strcmp(channel, nerves{1})
        v = d.In5_d;
    elseif strcmp(channel, nerves{2})
        v = d.In6_d;
    else
        disp(["error: channel name for this experiment not found. Pick one of " electrodes nerves])
    end
    
    electrode = channel;
    t = d.t_d;
    temp = d.Temp_d;
    usable = getUsableData(t, v, thresh);
    method1 = 0;
    method2 = 0;
    
    %% Get vrest, peaks, and frequency
    
    %make sure to avoid local minima but still with sampling over time in
    %bursting muscles 
    if strcmp(channel, "gm5b") || strcmp(channel, "gm6")
        [rests, loc] = findpeaks(-v, 'MinPeakDistance',20000);
        method1 = 1; % diff get rests method
    else
        [rests, loc] = findpeaks(-v, 'MinPeakDistance',2000);
        method2 = 1; % diff get rests method 
    end
    
    
    % check that the peak distance (in array units) is > than the lowest
    % frequency you're generally seeing, but not too big, for good temporal resolution 
    
    % rests
    restStart = loc(1);
    restEnd = loc(end);
    figure
    % interpolate vrest between sampled points
    vrestShortRange = interp1(loc, -rests, restStart:restEnd);
    
    vrest = zeros([1 length(t)]);
    vrest(restStart:restEnd) = vrestShortRange; % align vrests with time array
    
    % shrink usable data to the range of the vrest interpolation
    if method2
        usable(1:loc(1)) = 0;
        usable(loc(end): end) = 0;
    end
    
    % Use changes in vrest to find areas where muscle contracted and mark them  
    % also as unusable
    
    % actually i dont like this vrest method on gm muscles, 
    % so im just going to use it for extra filtering
    filter = ischange(vrest, 'mean', 'Threshold', 10000);
    filter = movmean(filter, 10000);
    usable(filter > .0002) = 0;
    
    if method1 % gm muscles vrest method 
        vrest = zeros([1 length(t)]);
        [idxRests, rests] = getRests(t, v);
        vrest(idxRests) = rests;
        
        disp(idxRests(1:100))
        
        usable(1:idxRests(1)) = 0;
        usable(idxRests(end):end) = 0;
    end
    
    figure
    subplot(5, 1, 1)
    sgtitle(electrode + " Temp vs frequency " + targetNotebook + "_" + targetPage, 'Interpreter', 'none')
    
    plot(t, temp)
    ylabel("Temp (°C)")
    
    subplot(5, 1, 2)
    
    % filter noisy peak data by setting a min peak prominence and distance
    % by setting min peak distance of 50 datapoints, you set a max possible
    % frequency of 20 Hz at sample interval of 0.001
    findpeaks(v, t, "MinPeakProminence", peakProm, 'MinPeakDistance', .5);
    ylabel("Vm and peaks")
    ylim([-100 0])
    
    [peaks, loc] = findpeaks(v, "MinPeakProminence", peakProm, 'MinPeakDistance', 500);
    timeLoc = loc * .001;
    
    freqData = zeros([5, length(peaks)]);
    
    % compile frequency data given peaks and usable data
    for i = 1:length(peaks) - 1
        loc1 = loc(i);
        loc2 = loc(i +1);
        if usable(loc1) == 1 && usable(loc2) == 1
            freqData(1, i) = peaks(i); % peak value
            freqData(2, i) = 1 / (t(loc2) - t(loc1)); % freq
            freqData(3, i) = mean(temp(loc1:loc2)); % avg temp in ISI
            freqData(4, i) = vrest(loc1); % vrest
            freqData(5, i) = d.abfNum_d(loc1);
        end
    end
    
    dataPeaks.peaks = freqData(1, :);
    dataPeaks.freq = freqData(2, :);
    dataPeaks.temp = freqData(3, :);
    dataPeaks.rest = freqData(4, :);
    dataPeaks.filenum = freqData(5, :);


subplot(5, 1, 3)
plot(t, vrest)
ylabel("vrest")

subplot(5, 1, 4)
plot(timeLoc, dataPeaks.freq)
ylabel("Freq (Hz)")
subplot(5, 1, 5)
plot(t, usable)
ylabel("Usable data")
xlabel("Time (s)")
allAxes = findall(gcf,'type','axes');
linkaxes(allAxes, 'x')

dataPeaks = load(filename);

end
