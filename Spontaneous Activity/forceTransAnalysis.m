function [dataPeaks] = forceTransAnalysis(targetNotebook, targetPage, mode)
    %% Description: Get force and frequency data on a ft experiment. Pair with plotHeartAnalysis.m
    % to plot out figures from output (dataPeaks)

    % Inputs:
        % targetNotebook (int)
        % targetPage (int)
        % mode (str) - either "heart" or "muscle"

    % Output:
        % dataPeaks (struct) - struct with the following fields
            % amp - amplitude of every peak detected on files listed in metadata
            % freq - instantaneous frequency of every peaks
            % file - associated file number in the sequence --> fix
            % temp - avg temp between a peak and the next one (in Celsius)
            % time - time of each peak

    % Last updated: Oct 20 2025 by Ananya Dalal


metadata = metadataMaster;
filename = "/Volumes/marder-lab/adalal/MatFiles/" + targetNotebook + "_" + targetPage + "_force.mat";

%% Try to load experiment data if it's already there in ananya's folder
if exist(filename, "file")
    dataPeaks = load(filename);

% Otherwise load data and detect peaks along whole experiment
else

    fs = 10^4;

    data = loadExperiment(targetNotebook, targetPage, "continuousRamp");
    
    cal = metadata(targetNotebook, targetPage).calibration;

    allPeaks = struct();
    
    % Discontinuous peak detection
    for f = 1:length(data.force)
        
        % +1 offset because files start at 0 but indexing starts at 1
        v = data.force{f};
        temp = data.temp{f};

        vClean = rmoutliers(data.force{f});
        

        % Shift baseline to 0 and scale to calibration value
        force = ((v - min(vClean)) / cal) * (.001 * 9.8);
        %figure
        minHeight = mean(force) + std(force);

        % Heart vs muscle ft peak detection settings
        % will default to muscle ft if no mode arg is provided
        if nargin == 3 && mode == "heart"
            %findpeaks(force, 'MinPeakProminence', .0005, 'MinPeakDistance', 0.5 * fs, 'MinPeakHeight', minHeight);
            [peaks, loc] = findpeaks(force, 'MinPeakProminence', .0005, 'MinPeakDistance', 0.5 * fs, 'MinPeakHeight', minHeight);
        else
       
            %findpeaks(force, 'MinPeakProminence', .0003, 'MinPeakDistance', 0.1 * fs);
            [peaks, loc] = findpeaks(force, 'MinPeakProminence', .0003, 'MinPeakDistance', 0.1 * fs);
        end

        timeLoc = loc / fs;

        % Get rid of noise outlier peaks
        idxPeaks = find(peaks > peaks - 3 * std(peaks) & ...
            peaks < peaks + 3 * std(peaks));
        peaks = peaks(idxPeaks);
        loc = loc(idxPeaks);

        allPeaks.amp{f} = peaks;
        allPeaks.time{f} = timeLoc;
        
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
dataPeaks.force = peaks.amp;
dataPeaks.condition = peaks.condition;

dataPeaks.freq = freqData(1, :);
dataPeaks.temp = freqData(2, :);
% Offset, your files start at the beginning of ramp and end at end of last
% ramp
dataPeaks.file = peaks.fileNum + metadata(targetNotebook, targetPage).files(1) - 1;

end

dataPeaks = load(filename);







    




