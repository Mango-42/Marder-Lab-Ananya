function [cdata, cspikes] = makeContinuous(data, varargin)
    
% Description: makes continuous data from preloaded file separated abf
% data, and also can do the same for spikes when file length of data
% collected varies

% Inputs:
    % data (struct) loaded data using loadExperiment

% Optional Inputs: 

    % targetNotebook (double)  (for continuous metadata)
    % targetPage (double) (for continuous metadata)

    % spikes (struct) formatted the same way as data, but fieldnames are
        % spike types (LP, PY, PD, etc). Can be generated using
            % 1) getSpikeTimes.m on crabsorted data OR
            % 2) sortSpikes.m + continuousBurstAnalysis.m

% Can call using the following signatures:
    % makeContinuous(data)
    % makeContinuous(data, spikes)
    % makeContinuous(data, targetNotebook, targetPage)
    % makeContinuous(data, targetNotebook, targetPage, spikes)


% Output:
    % cdata (struct): continuous data (each field is an array); + time
        % field. If target notebook + page are provided, will add
        % continuous metadata (solution, on upramp or not
    % cspikes (struct): continuous spike times for different neurons

%% Set fields based on number of params
if nargin == 2
    spikes = varargin{1};
elseif nargin == 3
    nb = varargin{1};
    page = varargin{2};
elseif nargin == 4
    nb = varargin{1};
    page = varargin{2};
    spikes = varargin{3};
elseif nargin > 4
    ME = MException('MATLAB:IncorrectNumInputs', ...
        'Must be 4 or fewer inputs.');
    throw(ME)
end


Fs = 10^4;

%% Make data continuous
    fn = fieldnames(data);
    
    cdata = struct;
    
    for name = 1:length(fn)
        store = [];
        for i = 1:length(data.(fn{name}))

            store = [store data.(fn{name}){i}];
        end
        cdata.(fn{name}) = store;
    end
    
    % Add a continuous time field
    cdata.t = .0001 * (0:length(cdata.(fn{1})));
    cdata.t = cdata.t(1:end - 1);

    % Add the file number each data value is associated with
    fileNums = [];
    for i = 1:length(data.(fn{1}))

        fileNums = [fileNums i * ones([1 length(data.(fn{name}){i})]) ];

    end

    cdata.fileNums = fileNums;

%% On analysis, if you're given exp nb and page pull condition
% this will get associated with spike/peak data not ALL data

if exist('nb', 'var') && exist('page', 'var')
    metadata = metadataMaster;

    files = metadata(nb, page).files;
    files = files(1):files(end); % cont ramp files
    c = metadata(nb, page).conditions;

    starts = metadata(nb, page).conditionStarts; % or doseStarts

    fileCondition = {i};

    conIdx = 1;
    for i = 1:length(files)
        if files(i) > starts(conIdx) && length(starts) > conIdx
            conIdx = conIdx + 1;
        end
        
        fileCondition{i} = c{conIdx};

    end
    fileCondition = string(fileCondition);
end


%% If given spikes or peaks, align them with corresponding data files.

% Spike mode
if exist('spikes', 'var') && ~isfield(spikes, 'amp')

    fn2 = fieldnames(spikes);
    % amp is a field name in peaks structures

    cspikes = struct;
    
    for name = 1:length(fn2)
        store = [];
        fileNum = [];

        for i = 1:length(spikes.(fn2{name}))
            if i == 1
                elapsedTime = 0;
            else
                elapsedTime = elapsedTime + (length(data.(fn{1}){i - 1}) / Fs);
            end
            nextSpikeTimes = (spikes.(fn2{name}){i} + elapsedTime);
            store = [store nextSpikeTimes];

            fileNum = [fileNum i * ones([1 length(nextSpikeTimes)])];
        end
    cspikes.(fn2{name}) = store;
    conName = "condition" + (fn2{name});
    cspikes.(conName) =  fileCondition(fileNum);

    end

end

% Peaks mode 
if exist('spikes', 'var') && isfield(spikes, 'amp')
    storeTime = [];
    storeAmp = [];
    fileNum = [];

    % Amp is a field name in peaks structures

    cspikes = struct;
    
    % Make peak times continuous
    for i = 1:length(spikes.time)
        if i == 1
            elapsedTime = 0;
        else
            elapsedTime = elapsedTime + (length(data.(fn{1}){i}) / Fs);
        end
    
        spikes.time{i} = spikes.time{i} + elapsedTime;

        fileNum = [fileNum i * ones([1 length(spikes.time{i})])];
    end

    % Wrap everything into a container cspikes
    for i = 1:length(spikes.amp)
        storeTime = [storeTime spikes.time{i}];
        storeAmp = [storeAmp spikes.amp{i}];
    end

    cspikes.time = storeTime;
    cspikes.amp = storeAmp;
    cspikes.fileNum = fileNum;

    cspikes.condition =  fileCondition(fileNum);

end

