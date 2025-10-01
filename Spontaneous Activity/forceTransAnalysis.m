function [dataPeaks] = forceTransAnalysis(targetNotebook, targetPage)
    %% Description: Get force and frequency data on a ft experiment. Pair with plotHeartAnalysis.m
    % to plot out figures from output (dataPeaks)

    % Inputs:
        % targetNotebook (int)
        % targetPage (int)
    % Output:
        % dataPeaks (struct) - struct with the following fields
            % amp - amplitude of every peak detected on files listed in metadata
            % freq - instantaneous frequency of every peaks
            % file - associated file number in the sequence --> fix
            % temp - avg temp between a peak and the next one (in Celcius)
            % time - time of each peak

    % Last updated: Sept 18 2025 by Ananya Dalal


metadataMaster
filename = "/Volumes/marder-lab/adalal/MatFiles/" + targetNotebook + "_" + targetPage + "_heart.mat";

% Try to load experiment data if it's already there in ananya's folder
if exist(filename, "file")
    dataPeaks = load(filename);
else

    fs = .0001;

    data = loadExperiment(targetNotebook, targetPage, "roi");
    %%
    
    allData = struct();
    allData.amp = [];
    allData.freq = [];
    allData.temp = [];
    allData.file = [];
    allData.time = [];

    files = metadata(targetNotebook, targetPage).files;
    temps = metadata(targetNotebook, targetPage).tempValues;
    cal = metadata(targetNotebook, targetPage).calibration;

    for f = 1:length(files)
        
%         % skip analysis for any files marked to ignore
%         if ismember(f, metadata(targetNotebook, targetPage).ignore)
%             continue
%         end
       
        % +1 offset because files start at 0 but indexing starts at 1
        v = data.heart{f};
        temp = data.temp{f};

        vClean = rmoutliers(data.heart{f});
        
%         % Vrest
%         [rests, loc] = findpeaks(-v, 'MinPeakDistance',2000);
%         
%         % Filter noise in data from touching the rig
%         idxRests = find(rests > rests - 3 * std(rests) & ...
%             rests < rests + 3 * std(rests));
% 
%         rests = rests(idxRests);
%         loc = loc(idxRests);
%         restStart = loc(1);
%         restEnd = loc(end);
% 
%         % Interpolate vrest between sampled points
%         vrestShortRange = interp1(loc, -rests, restStart:restEnd);
% 
%         % Align vrests with v
%         vrest = zeros([1 length(v)]);
%         vrest(restStart:restEnd) = vrestShortRange; 
%         vrest(1:restStart) = vrest(restStart);
%         vrest(restEnd:end) = vrest(restEnd);

        % Shift baseline to 0 and scale to calibration value
        force = ((v - min(vClean)) / cal) * (.001 * 9.8);
        figure
        minHeight = mean(force) + std(force);

        % THIS SETTING FOR HEART
        %findpeaks(force, 'MinPeakProminence', .0005, 'MinPeakDistance', 0.5 / fs, 'MinPeakHeight', minHeight);
        %THIS SETTING FOR MUSCLE FT
        findpeaks(force, 'MinPeakProminence', .0003, 'MinPeakDistance', 0.1 / fs);
        % THIS SETTING FOR HEART
        %[peaks, loc] = findpeaks(force, 'MinPeakProminence', .0005, 'MinPeakDistance', 0.5 / fs, 'MinPeakHeight', minHeight);
        %THIS SETTING FOR MUSCLE FT
        [peaks, loc] = findpeaks(force, 'MinPeakProminence', .0003, 'MinPeakDistance', 0.1 / fs);
        timeLoc = loc * fs;

        % Get rid of noise outlier peaks
        idxPeaks = find(peaks > peaks - 3 * std(peaks) & ...
            peaks < peaks + 3 * std(peaks));
        peaks = peaks(idxPeaks);
        loc = loc(idxPeaks);

        freqData = zeros([5, length(peaks)]);

        % Frequency and force calculations
        for i = 1:length(peaks) - 1
            loc1 = loc(i);
            loc2 = loc(i +1);
                freqData(1, i) = peaks(i); % peak value
                freqData(2, i) = 1 / (timeLoc(i+1) - timeLoc(i)); % freq
                freqData(3, i) = mean(temp(loc1:loc2)); % avg temp in ISI
                freqData(4, i) = f;
                freqData(5, i) = timeLoc(i);
        end

        allData.amp = [allData.amp, freqData(1, :)];
        allData.freq = [allData.freq, freqData(2, :)];
        allData.temp = [allData.temp, freqData(3, :)];
        allData.file = [allData.file, freqData(4, :)];
        allData.time = [allData.time, freqData(5, :)];

    end

dataPeaks = matfile(filename,'Writable',true);
dataPeaks.amp = allData.amp;
dataPeaks.freq = allData.freq;
dataPeaks.temp = allData.temp;
dataPeaks.file = allData.file;
dataPeaks.time = allData.time;


end
%%

dataPeaks = load(filename);







    




