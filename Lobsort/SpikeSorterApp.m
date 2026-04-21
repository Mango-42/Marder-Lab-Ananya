function SpikeSorterApp()
% SpikeSorterApp  Prototype spike sorter UI.
%
% Workflow:
%   1. Enter NB, page, range  →  Load Experiment
%   2. Select a nerve channel from the channel list
%   3. Select a file from the file list
%   4. Run Sort  →  calls sortSpikes on that file's trace
%   5. Rename / quick-assign groups in the label panel
%   6. Step through remaining files with Prev / Next
%   7. Export all sorted files for this channel to .mat

    %% ---- Shared state ------------------------------------------------
    state.experiment   = [];    % struct from loadExperiment
    state.channel      = '';    % currently selected nerve channel
    state.fileIdx      = 1;     % index into the cell array of sweeps
    state.trace        = [];    % trace for current file

    % Per-channel, per-file sort results.
    % state.results.(channel){fileIdx} = spikeGroups struct (or [])
    state.results      = struct();

    NERVE_CHANNELS = {'lvn','pdn','lpn','llvn','ulvn','pyn','mvn','lgn'};
    Fs = 1e4;

    %% ---- Build UI ----------------------------------------------------
    fig = uifigure('Name', 'SpikeSorter', 'Position', [80 80 1200 740]);

    % ----------------------------------------------------------------
    % Top bar: experiment loader
    % ----------------------------------------------------------------
    topPanel = uipanel(fig, 'Position', [0 700 1200 40], ...
        'BorderType', 'none', 'BackgroundColor', [0.94 0.94 0.94]);

    uilabel(topPanel, 'Text', 'NB:',   'Position', [10  10 25 20]);
    nbField = uieditfield(topPanel, 'numeric', ...
        'Value', 901, 'Position', [38 10 60 22], 'Limits', [1 9999]);

    uilabel(topPanel, 'Text', 'Page:', 'Position', [112 10 35 20]);
    pageField = uieditfield(topPanel, 'numeric', ...
        'Value', 80,  'Position', [150 10 60 22], 'Limits', [1 9999]);

    uilabel(topPanel, 'Text', 'Range:', 'Position', [224 10 42 20]);
    rangeDropdown = uidropdown(topPanel, ...
        'Items', {'all','roi','continuousRamp','crash'}, ...
        'Position', [269 10 130 22]);

    uibutton(topPanel, 'Text', 'Load Experiment', ...
        'Position', [414 8 130 26], ...
        'ButtonPushedFcn', @(~,~) onLoad());

    statusLabel = uilabel(topPanel, 'Text', 'Ready.', ...
        'Position', [560 10 620 20], 'FontColor', [0.35 0.35 0.35]);

    % ----------------------------------------------------------------
    % Left panel: channel list
    % ----------------------------------------------------------------
    uipanel(fig, 'Title', 'Channels', 'Position', [0 0 160 700]);

    channelList = uilistbox(fig, ...
        'Items', {}, ...
        'Position', [8 30 144 660], ...
        'ValueChangedFcn', @(src,~) onChannelSelected(src.Value));

    % ----------------------------------------------------------------
    % Centre-left: file list with sort status
    % ----------------------------------------------------------------
    uipanel(fig, 'Title', 'Files', 'Position', [160 0 180 700]);

    fileList = uilistbox(fig, ...
        'Items', {}, ...
        'Position', [168 30 164 660], ...
        'ValueChangedFcn', @(src,~) onFileSelected(src.Value));

    % ----------------------------------------------------------------
    % Centre: trace axes + controls
    % ----------------------------------------------------------------
    tracePanel = uipanel(fig, 'Title', 'Trace', ...
    'Position', [340 160 580 540]);

    traceAx = uiaxes(tracePanel, ...
    'Position', [8 8 564 500]);   % relative to panel
    traceAx.XLabel.String = 'Time (s)';
    traceAx.YLabel.String = 'mV';
    title(traceAx, 'Load an experiment to begin');

    % Controls row below plot
    ctrlPanel = uipanel(fig, 'Position', [340 0 580 160], 'BorderType', 'none');

    sortBtn = uibutton(ctrlPanel, 'Text', '▶  Sort This File', ...
        'Position', [10 118 140 30], 'Enable', 'off', ...
        'ButtonPushedFcn', @(~,~) onSort());

    sortAllBtn = uibutton(ctrlPanel, 'Text', 'Sort All Files', ...
        'Position', [160 118 120 30], 'Enable', 'off', ...
        'ButtonPushedFcn', @(~,~) onSortAll());

    prevBtn = uibutton(ctrlPanel, 'Text', '◀ Prev', ...
        'Position', [10 80 90 28], 'Enable', 'off', ...
        'ButtonPushedFcn', @(~,~) stepFile(-1));

    nextBtn = uibutton(ctrlPanel, 'Text', 'Next ▶', ...
        'Position', [108 80 90 28], 'Enable', 'off', ...
        'ButtonPushedFcn', @(~,~) stepFile(1));

    fileCountLabel = uilabel(ctrlPanel, 'Text', '', ...
        'Position', [210 84 160 20], 'FontColor', [0.4 0.4 0.4]);

    exportBtn = uibutton(ctrlPanel, 'Text', 'Export .mat', ...
        'Position', [390 118 110 30], 'Enable', 'off', ...
        'ButtonPushedFcn', @(~,~) onExport());

    infoLabel = uilabel(ctrlPanel, 'Text', '', ...
        'Position', [10 50 560 22], 'FontColor', [0.3 0.3 0.3]);

    progressLabel = uilabel(ctrlPanel, 'Text', '', ...
        'Position', [10 24 560 22], 'FontColor', [0.2 0.5 0.2]);

    % ----------------------------------------------------------------
    % Right panel: label editor
    % ----------------------------------------------------------------
    uipanel(fig, 'Title', 'Neuron Labels', 'Position', [920 0 280 700]);

    labelList = uilistbox(fig, ...
        'Items', {}, ...
        'Position', [928 160 264 530]);

    uilabel(fig, 'Text', 'Rename selected:', 'Position', [928 130 160 20]);
    renameField = uieditfield(fig, 'text', ...
        'Position', [928 108 188 24], 'Placeholder', 'New name…');
    uibutton(fig, 'Text', 'Rename', ...
        'Position', [1122 108 62 24], ...
        'ButtonPushedFcn', @(~,~) onRename());

    % Quick-assign buttons
    quickNames = {'LP','PD','PY','LG','LPG','noise'};
    for qi = 1:length(quickNames)
        uibutton(fig, 'Text', quickNames{qi}, ...
            'Position', [928 + (qi-1)*44 60 40 28], ...
            'ButtonPushedFcn', @(~,~) onQuickAssign(quickNames{qi}));
    end

    uilabel(fig, 'Text', 'Quick assign:', 'Position', [928 88 100 20]);

    %% ---- Callbacks ---------------------------------------------------

    function onLoad()
        nb   = nbField.Value;
        page = pageField.Value;
        rng  = rangeDropdown.Value;
        setStatus(sprintf('Loading NB %d page %d (%s)…', nb, page, rng));

        try
            state.experiment = loadExperiment(nb, page, rng);
        catch e
            setStatus(['Load error: ' e.message]);
            return
        end

        % Reset all state
        state.results = struct();
        state.channel = '';
        state.fileIdx = 1;

        % Populate channel list
        recorded     = fieldnames(state.experiment);
        nervePresent = recorded(ismember(recorded, NERVE_CHANNELS));
        channelList.Items = nervePresent';

        if ~isempty(nervePresent)
            channelList.Value = nervePresent{1};
            onChannelSelected(nervePresent{1});
        end

        setStatus(sprintf('Loaded NB %d page %d  |  channels: %s', ...
            nb, page, strjoin(nervePresent, ', ')));
    end

    function onChannelSelected(channel)
        if isempty(state.experiment) || ~isfield(state.experiment, channel)
            return
        end
        state.channel = channel;
        state.fileIdx = 1;

        % Initialise results cell array for this channel if needed
        nFiles = numel(state.experiment.(channel));
        if ~isfield(state.results, channel) || ...
                numel(state.results.(channel)) ~= nFiles
            state.results.(channel) = cell(1, nFiles);
        end

        refreshFileList();
        loadCurrentFile();
        sortBtn.Enable    = 'on';
        sortAllBtn.Enable = 'on';
    end

    function onFileSelected(listValue)
        % listValue is the display string; recover index from it
        items = fileList.Items;
        idx   = find(strcmp(items, listValue), 1);
        if isempty(idx), return, end
        state.fileIdx = idx;
        loadCurrentFile();
    end

    function loadCurrentFile()
        ch    = state.channel;
        fi    = state.fileIdx;
        if isempty(ch) || isempty(state.experiment), return, end

        sweeps      = state.experiment.(ch);
        state.trace = sweeps{fi}(:);

        disp('--- TRACE DEBUG ---')
        disp(class(state.trace))
        disp(size(state.trace))
        disp(isempty(state.trace))

        plotTrace();
        updateNavButtons();

        % Show existing sort result if available
        if ~isempty(state.results.(ch){fi})
            refreshLabelList(state.results.(ch){fi});
            nTotal = countSpikes(state.results.(ch){fi});
            groups = fieldnames(state.results.(ch){fi});
            infoLabel.Text = sprintf('File %d/%d  |  %d spikes in %d group(s)', ...
                fi, numel(sweeps), nTotal, numel(groups));
        else
            labelList.Items = {};
            infoLabel.Text  = sprintf('File %d/%d  |  not yet sorted', ...
                fi, numel(sweeps));
        end
    end

    function onSort()
        if isempty(state.trace)
            setStatus('No file loaded.');
            return
        end
        ch = state.channel;
        fi = state.fileIdx;

        setStatus(sprintf('Sorting %s file %d…', ch, fi));
        sortBtn.Enable = 'off';
        drawnow;

        try
            [sg, ~] = sortSpikes(state.trace);
        catch e
            setStatus(['Sort error: ' e.message]);
            sortBtn.Enable = 'on';
            return
        end

        state.results.(ch){fi} = sg;
        sortBtn.Enable = 'on';
        exportBtn.Enable = 'on';

        plotTrace();
        refreshLabelList(sg);
        refreshFileList();

        nTotal = countSpikes(sg);
        groups = fieldnames(sg);
        infoLabel.Text = sprintf('File %d  |  %d spikes in %d group(s)', ...
            fi, nTotal, numel(groups));
        setStatus(sprintf('Done: %s file %d.', ch, fi));
    end

    function onSortAll()
        ch     = state.channel;
        nFiles = numel(state.experiment.(ch));
        sortBtn.Enable    = 'off';
        sortAllBtn.Enable = 'off';
        exportBtn.Enable  = 'off';

        for fi = 1:nFiles
            progressLabel.Text = sprintf('Sorting file %d / %d…', fi, nFiles);
            drawnow;

            sweeps      = state.experiment.(ch);
            state.trace = sweeps{fi};
            state.fileIdx = fi;

            try
                [sg, ~] = sortSpikes(state.trace);
                state.results.(ch){fi} = sg;
            catch e
                setStatus(sprintf('Error on file %d: %s', fi, e.message));
            end

            refreshFileList();
            % Keep file list selection current
            fileList.Value = fileList.Items{fi};
        end

        loadCurrentFile();
        progressLabel.Text = sprintf('All %d files sorted.', nFiles);
        sortBtn.Enable    = 'on';
        sortAllBtn.Enable = 'on';
        exportBtn.Enable  = 'on';
        setStatus(sprintf('Sorted all %d files for %s.', nFiles, ch));
    end

    function stepFile(delta)
        ch     = state.channel;
        nFiles = numel(state.experiment.(ch));
        newIdx = state.fileIdx + delta;
        if newIdx < 1 || newIdx > nFiles, return, end
        state.fileIdx  = newIdx;
        fileList.Value = fileList.Items{newIdx};
        loadCurrentFile();
    end

    function onRename()
        ch = state.channel;
        fi = state.fileIdx;
        sg = state.results.(ch){fi};
        if isempty(sg), return, end

        selected = labelList.Value;
        newName  = strtrim(renameField.Value);
        if isempty(selected) || isempty(newName), return, end

        oldName = extractGroupName(selected);
        if isfield(sg, oldName) && ~isfield(sg, newName)
            sg.(newName) = sg.(oldName);
            sg = rmfield(sg, oldName);
            state.results.(ch){fi} = sg;
            refreshLabelList(sg);
            plotTrace();
        end
        renameField.Value = '';
    end

    function onQuickAssign(label)
        ch = state.channel;
        fi = state.fileIdx;
        sg = state.results.(ch){fi};
        if isempty(sg) || isempty(labelList.Value), return, end

        oldName = extractGroupName(labelList.Value);
        if isfield(sg, oldName)
            if isfield(sg, label)
                sg.(label) = [sg.(label) sg.(oldName)];
            else
            sg.(label) = sg.(oldName);
            end
            sg = rmfield(sg, oldName);

            state.results.(ch){fi} = sg;
            refreshLabelList(sg);
            refreshFileList();
            plotTrace();
        end
    end

    function onExport()
        ch = state.channel;
        if isempty(ch) || ~isfield(state.results, ch), return, end

        nb   = nbField.Value;
        page = pageField.Value;
        defaultName = sprintf('NB%d_p%d_%s_allFiles.mat', nb, page, ch);
        [f, p] = uiputfile('*.mat', 'Export all sorted files', defaultName);
        if isequal(f, 0), return, end

        % Build export struct: results.file1, results.file2, ...
        results = struct(); %#ok<NASGU>
        nFiles  = numel(state.results.(ch));
        for fi = 1:nFiles
            key = sprintf('file%d', fi);
            if ~isempty(state.results.(ch){fi})
                results.(key) = state.results.(ch){fi};
            end
        end
        save(fullfile(p, f), 'results');
        setStatus(['Exported to ' fullfile(p, f)]);
    end

    %% ---- Helpers -----------------------------------------------------

    function refreshFileList()
        ch = state.channel;
        if isempty(ch) || ~isfield(state.experiment, ch), return, end
        nFiles = numel(state.experiment.(ch));
        items  = cell(1, nFiles);
        for fi = 1:nFiles
            sg = state.results.(ch){fi};
            if isempty(sg)
                badge = '○';
            else
                % Show neuron names if labeled, otherwise group count
                gnames = fieldnames(sg);
                named  = gnames(~startsWith(gnames, 'spikeTimes'));
                if ~isempty(named)
                    badge = ['✓ ' strjoin(named, ' ')];
                else
                    badge = sprintf('✓ %d groups', numel(gnames));
                end
            end
            items{fi} = sprintf('File %02d  %s', fi, badge);
        end
        fileList.Items = items;
        % Keep selection in sync
        if state.fileIdx <= nFiles
            fileList.Value = items{state.fileIdx};
        end
    end

    function updateNavButtons()
        ch     = state.channel;
        nFiles = numel(state.experiment.(ch));
        prevBtn.Enable = onOff(state.fileIdx > 1);
        nextBtn.Enable = onOff(state.fileIdx < nFiles);
        fileCountLabel.Text = sprintf('File %d of %d', state.fileIdx, nFiles);
    end

    function plotTrace()
        cla(traceAx);
        if isempty(state.trace), return, end

        t = (0:length(state.trace)-1) / Fs;
        plot(traceAx, t, state.trace, 'Color', [0.2 0.2 0.2], 'LineWidth', 0.4);
        hold(traceAx, 'on');


        ch = state.channel;
        fi = state.fileIdx;
        sg = state.results.(ch){fi};

        if ~isempty(sg)
            groups = fieldnames(sg);
            colors = lines(numel(groups));
            for gi = 1:numel(groups)
                times = sg.(groups{gi});
                times = times(times >= t(1) & times <= t(end));
                amps  = interp1(t, state.trace, times, 'linear', 0);
                scatter(traceAx, times, amps, 20, colors(gi,:), 'filled', ...
                    'DisplayName', groups{gi});
            end
            legend(traceAx, 'Location', 'northeast');
        end

        hold(traceAx, 'off');
        title(traceAx, sprintf('%s  —  file %d', ch, fi));
        traceAx.XLabel.String = 'Time (s)';
        traceAx.YLabel.String = 'mV';
        drawnow;
    end

    function refreshLabelList(sg)
        if isempty(sg) || ~isstruct(sg)
            labelList.Items = {};
            return
        end
        groups = fieldnames(sg);
        items  = cellfun(@(g) sprintf('%s  (%d spikes)', g, length(sg.(g))), ...
            groups, 'UniformOutput', false);
        labelList.Items = items';
        if ~isempty(items)
            labelList.Value = items{1};
        end
    end

    function n = countSpikes(sg)
        if isempty(sg) || ~isstruct(sg)
            n = 0; return
        end
        groups = fieldnames(sg);
        n = sum(cellfun(@(g) length(sg.(g)), groups));
    end

    function name = extractGroupName(listItem)
        name = strtrim(regexp(listItem, '^[^\s(]+', 'match', 'once'));
    end

    function s = onOff(tf)
        if tf, s = 'on'; else, s = 'off'; end
    end

    function setStatus(msg)
        statusLabel.Text = msg;
        drawnow;
    end

end