function [dataPeaks, n] = forceTransAnalysis(targetNotebook, targetPage, mode)
    %% Description: Get force and frequency data on a ft experiment. Pair with plotHeartAnalysis.m
    % to plot out figures from output (dataPeaks)

    % Inputs:
        % targetNotebook (int)
        % targetPage (int)
        % mode (str) - either "heart" or "muscle"

    % Output:
        % dataPeaks (struct) - struct with the following fields per contraction
            % force - value in Newtons of each contraction
            % amp - value in Volts of each contraction
            % base and peak - values in V for computing amp and force
            % freq - instantaneous frequency of every peaks
            % file - associated file number in the sequence --> fix
            % 
            % temp - avg temp between a peak and the next one (in Celsius)
            % time - time of max contraction force
            % startTime - start time of each contraction

    % Occasionally you might get an error with a negative amp, this means
    % baseline calculation likely was not good at that spot -- just ignore
    % these values.

    % Last updated: Jan 23 2025 by Ananya Dalal


metadata = metadataMaster;
filename = "/Volumes/marder-lab/adalal/MatFiles/" + targetNotebook + "_" + targetPage + "_force.mat";

%% Try to load experiment data if it's already there in ananya's folder
if exist(filename, "file")
    dataPeaks = load(filename);

% Otherwise load data and detect peaks along whole experiment
else

    fs = 10^4;

    data = loadExperiment(targetNotebook, targetPage, "continuousRamp"); % continuousRamp
    
    cal = metadata(targetNotebook, targetPage).calibration;

    allPeaks = struct();
    
    % Discontinuous peak detection
    for f = 1:length(data.force)
        
        % +1 offset because files start at 0 but indexing starts at 1
        v = data.force{f};
        temp = data.temp{f};

        vClean = rmoutliers(data.force{f});
        

        % Shift baseline to 0 and scale to calibration value
        %force = ((v - min(vClean)) / cal) * (9.8); % This is in centinewtons. 
        %figure
        minHeight = mean(vClean) + std(vClean);

        % Heart vs muscle ft peak detection settings
        % will default to muscle ft if no mode arg is provided
        if nargin == 3 && mode == "heart"
            %figure
            %findpeaks(vClean, 'MinPeakProminence', .0005, 'MinPeakDistance', 0.5 * fs, 'MinPeakHeight', minHeight);
            [peaks, loc] = findpeaks(vClean, 'MinPeakProminence', .0005, 'MinPeakDistance', 0.5 * fs, 'MinPeakHeight', minHeight);
        else
            %figure
            %findpeaks(smooth(vClean, 1000)', 'MinPeakProminence', .0003, 'MinPeakDistance', 0.25 * fs, 'MinPeakHeight', minHeight);
            % DIFF OLD? findpeaks(force, 'MinPeakProminence', .0003, 'MinPeakDistance', 0.1 * fs);
            [peaks, loc] = findpeaks(smooth(vClean, 1000)', 'MinPeakProminence', .0003, 'MinPeakDistance', 0.25 * fs, 'MinPeakHeight', minHeight);
        end

        timeLoc = loc / fs;

        % Get rid of noise outlier peaks
        idxPeaks = find(peaks > peaks - 3 * std(peaks) & ...
            peaks < peaks + 3 * std(peaks));
        peaks = peaks(idxPeaks);
        loc = loc(idxPeaks);


        % Find times when contractions start
        [base, locs] = findpeaks(movmean(-vClean, 1000), 'MinPeakProminence', .0005, 'MinPeakDistance', 0.4 * fs);
        base = -base;
        %figure
        %findpeaks(movmean(-vClean, 1000), 'MinPeakProminence', .0005, 'MinPeakDistance', 0.4 * fs);
        % interpolate start times in an array so you can easily access which start
        % time for a peak by indexing
        allvals = 1:length(vClean);
        xq = setdiff(allvals, locs);
        startLocs = interp1(locs,locs,xq,'previous');
        allvals(xq) = startLocs;
        allvals(locs) = locs;
        startLocs = allvals(loc); % from peak point last start
        startTimes = startLocs / fs;% convert to time

        % interpolate baseline values 
        allvals = 1:length(vClean);
        xq = setdiff(allvals, base);
        baseline = interp1(locs,base,xq,'previous');
        allvals(xq) = baseline;
        allvals(locs) = base;
        baseline = allvals(loc); % from peak point last start


        allPeaks.base{f} = baseline;
        allPeaks.peaks{f} = peaks;
        allPeaks.amp{f} = peaks - baseline;
        allPeaks.force{f} = ((peaks - baseline) / cal) * (9.8) / (100); 
        allPeaks.time{f} = timeLoc;
        allPeaks.startTime{f} = startTimes;

        n = allPeaks;
        
    end
    
%% Do analysis on continuous data
[cdata, peaks] = makeContinuous(data, targetNotebook, targetPage, allPeaks);

freqData = zeros([2, length(peaks.amp)]);

% Frequency and force calculations
for i = 1:length(peaks.amp) - 1
    loc1 = peaks.time(i);
    loc2 = peaks.time(i +1);
        freqData(1, i) = 1 / (loc2 - loc1); % freq
        freqData(2, i) = cdata.temp(int64(loc1 * fs)); % temp at peak
end






%% Put everything into a structure to be stored!!
dataPeaks = matfile(filename,'Writable',true);
dataPeaks.time = peaks.time;
dataPeaks.force = peaks.force;
dataPeaks.amp = peaks.amp;
dataPeaks.peaks = peaks.peaks;
dataPeaks.base = peaks.base;

dataPeaks.condition = peaks.condition;
dataPeaks.startTime = peaks.startTime;
dataPeaks.freq = freqData(1, :);
dataPeaks.temp = freqData(2, :);
% Offset, your files start at the beginning of ramp and end at end of last
% ramp
dataPeaks.file = peaks.fileNum; %+ metadata(targetNotebook, targetPage).files(1) - 1;

end

dataPeaks = load(filename);







    




