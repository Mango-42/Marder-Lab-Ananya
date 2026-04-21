function SpikeSorterAppVTwo()
% SpikeSorterApp  Prototype spike sorter UI with manual correction.
%
% Workflow:
%   1. Enter NB, page, range  →  Load Experiment
%   2. Select a nerve channel from the channel list
%   3. Select a file from the file list
%   4. Run Sort  →  calls sortSpikes on that file's trace
%   5. Manual correction:
%        - Click "Select Mode" to enter correction mode
%        - Click near a spike to select the nearest point
%        - Click and drag across the trace to select all spikes in that
%          x-range (across all groups)
%        - Selected spikes highlighted in yellow
%        - Click a target label button to reassign selected spikes
%   6. Rename / quick-assign whole groups in the label panel
%   7. Step through remaining files with Prev / Next
%   8. Export all sorted files for this channel to .mat

    %% ---- Shared state ------------------------------------------------
    state.experiment   = [];    % struct from loadExperiment
    state.channel      = '';    % currently selected nerve channel
    state.fileIdx      = 1;     % index into the cell array of sweeps
    state.trace        = [];    % trace for current file

    % Per-channel, per-file sort results.
    % state.results.(channel){fileIdx} = spikeGroups struct (or [])
    state.results      = struct();

    % Manual correction state
    edit.active       = false;
    edit.selected     = [];      % spike times currently selected (seconds)
    edit.dragStart    = [];
    edit.isDragging   = false;

    % Undo stack: each entry is a snapshot of spikeGroups before a change
    undoStack = {};

    NERVE_CHANNELS = {'lvn','pdn','lpn','llvn','ulvn','pyn','mvn','lgn'};
    Fs = 1e4;

    GROUP_COLORS = lines(10);
    SEL_COLOR    = [1.0 0.85 0.0];   % yellow for selected spikes

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
    % Centre: trace axes  (your fix: axes parented to panel)
    % ----------------------------------------------------------------
    tracePanel = uipanel(fig, 'Title', 'Trace', ...
        'Position', [340 200 580 500]);

    traceAx = uiaxes(tracePanel, 'Position', [8 8 564 460]);
    traceAx.XLabel.String = 'Time (s)';
    traceAx.YLabel.String = 'mV';
    title(traceAx, 'Load an experiment to begin');

    % Wire mouse events for manual correction
    traceAx.ButtonDownFcn     = @onAxesClick;
    fig.WindowButtonMotionFcn = @onMouseMove;
    fig.WindowButtonUpFcn     = @onMouseUp;

    % ----------------------------------------------------------------
    % Controls below trace
    % ----------------------------------------------------------------
    ctrlPanel = uipanel(fig, 'Position', [340 0 580 200], 'BorderType', 'none');

    % Row 1: sort / nav / export
    sortBtn = uibutton(ctrlPanel, 'Text', '▶  Sort This File', ...
        'Position', [10 158 140 30], 'Enable', 'off', ...
        'ButtonPushedFcn', @(~,~) onSort());

    sortAllBtn = uibutton(ctrlPanel, 'Text', 'Sort All Files', ...
        'Position', [158 158 120 30], 'Enable', 'off', ...
        'ButtonPushedFcn', @(~,~) onSortAll());

    prevBtn = uibutton(ctrlPanel, 'Text', '◀ Prev', ...
        'Position', [10 120 90 28], 'Enable', 'off', ...
        'ButtonPushedFcn', @(~,~) stepFile(-1));

    nextBtn = uibutton(ctrlPanel, 'Text', 'Next ▶', ...
        'Position', [108 120 90 28], 'Enable', 'off', ...
        'ButtonPushedFcn', @(~,~) stepFile(1));

    fileCountLabel = uilabel(ctrlPanel, 'Text', '', ...
        'Position', [210 124 160 20], 'FontColor', [0.4 0.4 0.4]);

    exportBtn = uibutton(ctrlPanel, 'Text', 'Export .mat', ...
        'Position', [460 158 110 30], 'Enable', 'off', ...
        'ButtonPushedFcn', @(~,~) onExport());

    infoLabel = uilabel(ctrlPanel, 'Text', '', ...
        'Position', [10 90 560 22], 'FontColor', [0.3 0.3 0.3]);

    progressLabel = uilabel(ctrlPanel, 'Text', '', ...
        'Position', [10 68 560 22], 'FontColor', [0.2 0.5 0.2]);

    % Row 2: manual correction controls
    uipanel(ctrlPanel, 'Title', 'Manual Correction', ...
        'Position', [0 0 570 62]);

    selectBtn = uibutton(ctrlPanel, 'Text', '⊙  Select Mode: OFF', ...
        'Position', [8 28 160 26], 'Enable', 'off', ...
        'ButtonPushedFcn', @(~,~) toggleSelectMode());

    clearSelBtn = uibutton(ctrlPanel, 'Text', 'Clear Selection', ...
        'Position', [176 28 112 26], 'Enable', 'off', ...
        'ButtonPushedFcn', @(~,~) clearSelection());

    selCountLabel = uilabel(ctrlPanel, 'Text', '0 spikes selected', ...
        'Position', [296 32 160 20], 'FontColor', [0.5 0.3 0.0]);

    undoBtn = uibutton(ctrlPanel, 'Text', '↩  Undo', ...
        'Position', [460 28 100 26], 'Enable', 'off', ...
        'ButtonPushedFcn', @(~,~) onUndo());

    uilabel(ctrlPanel, 'Text', 'Reassign selected →', ...
        'Position', [8 6 140 18], 'FontSize', 10);

    % Container for dynamically-built target label buttons
    targetBtnContainer = uipanel(ctrlPanel, ...
        'Position', [150 2 415 24], 'BorderType', 'none');

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

    %% ---- Callbacks: loading ------------------------------------------

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
        undoStack     = {};
        clearSelection();

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

        nFiles = numel(state.experiment.(channel));
        if ~isfield(state.results, channel) || ...
                numel(state.results.(channel)) ~= nFiles
            state.results.(channel) = cell(1, nFiles);
        end

        clearSelection();
        refreshFileList();
        loadCurrentFile();
        sortBtn.Enable    = 'on';
        sortAllBtn.Enable = 'on';
    end

    function onFileSelected(listValue)
        items = fileList.Items;
        idx   = find(strcmp(items, listValue), 1);
        if isempty(idx), return, end
        state.fileIdx = idx;
        clearSelection();
        loadCurrentFile();
    end

    function loadCurrentFile()
        ch    = state.channel;
        fi    = state.fileIdx;
        if isempty(ch) || isempty(state.experiment), return, end

        sweeps      = state.experiment.(ch);
        state.trace = sweeps{fi}(:);   % your fix: ensure column vector

        disp('--- TRACE DEBUG ---')
        disp(class(state.trace))
        disp(size(state.trace))
        disp(isempty(state.trace))

        plotTrace();
        updateNavButtons();

        sg = state.results.(ch){fi};
        if ~isempty(sg)
            refreshLabelList(sg);
            buildTargetButtons(sg);
            nTotal = countSpikes(sg);
            groups = fieldnames(sg);
            infoLabel.Text = sprintf('File %d/%d  |  %d spikes in %d group(s)', ...
                fi, numel(sweeps), nTotal, numel(groups));
        else
            labelList.Items = {};
            clearTargetButtons();
            infoLabel.Text = sprintf('File %d/%d  |  not yet sorted', ...
                fi, numel(sweeps));
        end
    end

    %% ---- Callbacks: sorting ------------------------------------------

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

        pushUndo(ch, fi);
        state.results.(ch){fi} = sg;
        sortBtn.Enable   = 'on';
        exportBtn.Enable = 'on';
        selectBtn.Enable = 'on';

        clearSelection();
        plotTrace();
        refreshLabelList(sg);
        buildTargetButtons(sg);
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

            sweeps        = state.experiment.(ch);
            state.trace   = sweeps{fi};
            state.fileIdx = fi;

            try
                [sg, ~] = sortSpikes(state.trace);
                state.results.(ch){fi} = sg;
            catch e
                setStatus(sprintf('Error on file %d: %s', fi, e.message));
            end

            refreshFileList();
            fileList.Value = fileList.Items{fi};
        end

        loadCurrentFile();
        progressLabel.Text = sprintf('All %d files sorted.', nFiles);
        sortBtn.Enable    = 'on';
        sortAllBtn.Enable = 'on';
        exportBtn.Enable  = 'on';
        selectBtn.Enable  = 'on';
        setStatus(sprintf('Sorted all %d files for %s.', nFiles, ch));
    end

    function stepFile(delta)
        ch     = state.channel;
        nFiles = numel(state.experiment.(ch));
        newIdx = state.fileIdx + delta;
        if newIdx < 1 || newIdx > nFiles, return, end
        state.fileIdx  = newIdx;
        fileList.Value = fileList.Items{newIdx};
        clearSelection();
        loadCurrentFile();
    end

    %% ---- Callbacks: manual correction --------------------------------

    function toggleSelectMode()
        edit.active = ~edit.active;
        if edit.active
            selectBtn.Text            = '⊙  Select Mode: ON';
            selectBtn.BackgroundColor = [0.95 0.85 0.3];
            clearSelBtn.Enable        = 'on';
            setStatus('Selection mode ON — click a spike or drag across x to select.');
        else
            selectBtn.Text            = '⊙  Select Mode: OFF';
            selectBtn.BackgroundColor = [0.96 0.96 0.96];
            clearSelBtn.Enable        = 'off';
            clearSelection();
            setStatus('Selection mode OFF.');
        end
    end

    function onAxesClick(~, event)
        if ~edit.active, return, end
        edit.dragStart  = event.IntersectionPoint(1);
        edit.isDragging = false;
    end

    function onMouseMove(~, ~)
        if ~edit.active || isempty(edit.dragStart), return, end
        curX = get(traceAx, 'CurrentPoint');
        curX = curX(1, 1);
        if abs(curX - edit.dragStart) > 0.005
            edit.isDragging = true;
            plotTrace();
            % Show drag region as two vertical lines
            xline(traceAx, edit.dragStart, '--', ...
                'Color', [0.2 0.5 1.0], 'LineWidth', 1.5, ...
                'HitTest', 'off', 'HandleVisibility', 'off');
            xline(traceAx, curX, '--', ...
                'Color', [0.2 0.5 1.0], 'LineWidth', 1.5, ...
                'HitTest', 'off', 'HandleVisibility', 'off');
            drawnow limitrate;
        end
    end

    function onMouseUp(~, ~)
        if ~edit.active || isempty(edit.dragStart), return, end

        ch = state.channel; fi = state.fileIdx;
        sg = state.results.(ch){fi};
        if isempty(sg), edit.dragStart = []; return, end

        curX = get(traceAx, 'CurrentPoint');
        curX = curX(1, 1);

        if edit.isDragging
            xLo = min(edit.dragStart, curX);
            xHi = max(edit.dragStart, curX);
            edit.selected = selectSpikesInRange(sg, xLo, xHi);
        else
            edit.selected = selectNearestSpike(sg, edit.dragStart);
        end

        edit.dragStart  = [];
        edit.isDragging = false;

        selCountLabel.Text = sprintf('%d spike(s) selected', numel(edit.selected));
        plotTrace();
    end

    function spikeTimes = selectSpikesInRange(sg, xLo, xHi)
        groups     = fieldnames(sg);
        spikeTimes = [];
        for gi = 1:numel(groups)
            times      = sg.(groups{gi})(:);   % ensure column
            spikeTimes = [spikeTimes; times(times >= xLo & times <= xHi)]; %#ok<AGROW>
        end
        spikeTimes = sort(spikeTimes);
    end

    function spikeTime = selectNearestSpike(sg, clickX)
        groups   = fieldnames(sg);
        allTimes = [];
        for gi = 1:numel(groups)
            allTimes = [allTimes; sg.(groups{gi})(:)]; %#ok<AGROW>  % ensure column
        end
        if isempty(allTimes), spikeTime = []; return, end
        [~, idx]  = min(abs(allTimes - clickX));
        spikeTime = allTimes(idx);
    end

    function reassignSelected(targetGroup)
        if isempty(edit.selected), return, end
        ch = state.channel; fi = state.fileIdx;
        sg = state.results.(ch){fi};
        if isempty(sg), return, end

        pushUndo(ch, fi);

        % Remove selected spikes from all groups they currently belong to
        groups = fieldnames(sg);
        for gi = 1:numel(groups)
            sg.(groups{gi}) = setdiff(sg.(groups{gi})(:), edit.selected(:));
        end

        % Add to target (create group if it doesn't exist yet)
        if isfield(sg, targetGroup)
            sg.(targetGroup) = sort([sg.(targetGroup)(:); edit.selected(:)]);
        else
            sg.(targetGroup) = sort(edit.selected(:));
        end

        % Drop any groups that are now empty
        groups = fieldnames(sg);
        for gi = 1:numel(groups)
            if isempty(sg.(groups{gi}))
                sg = rmfield(sg, groups{gi});
            end
        end

        state.results.(ch){fi} = sg;
        clearSelection();
        plotTrace();
        refreshLabelList(sg);
        buildTargetButtons(sg);
        refreshFileList();

        nTotal = countSpikes(sg);
        infoLabel.Text = sprintf('File %d  |  %d spikes in %d group(s)', ...
            fi, nTotal, numel(fieldnames(sg)));
    end

    function clearSelection()
        edit.selected   = [];
        edit.dragStart  = [];
        edit.isDragging = false;
        if isvalid(fig)
            selCountLabel.Text = '0 spikes selected';
        end
        if isvalid(traceAx)
            plotTrace();
        end
    end

    %% ---- Callbacks: labeling -----------------------------------------

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
            pushUndo(ch, fi);
            sg.(newName) = sg.(oldName);
            sg = rmfield(sg, oldName);
            state.results.(ch){fi} = sg;
            refreshLabelList(sg);
            buildTargetButtons(sg);
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
            pushUndo(ch, fi);
            % Your fix: merge into existing group if label already exists
            if isfield(sg, label)
                sg.(label) = [sg.(label) sg.(oldName)];
            else
                sg.(label) = sg.(oldName);
            end
            sg = rmfield(sg, oldName);
            state.results.(ch){fi} = sg;
            refreshLabelList(sg);
            buildTargetButtons(sg);
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

    %% ---- Undo --------------------------------------------------------

    function pushUndo(ch, fi)
        entry.ch = ch;
        entry.fi = fi;
        entry.sg = state.results.(ch){fi};
        undoStack{end+1} = entry;
        undoBtn.Enable   = 'on';
        if numel(undoStack) > 20
            undoStack = undoStack(end-19:end);
        end
    end

    function onUndo()
        if isempty(undoStack), return, end
        entry      = undoStack{end};
        undoStack(end) = [];
        state.results.(entry.ch){entry.fi} = entry.sg;
        if isempty(undoStack), undoBtn.Enable = 'off'; end
        clearSelection();
        loadCurrentFile();
        setStatus('Undo applied.');
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
        if state.fileIdx <= nFiles
            fileList.Value = items{state.fileIdx};
        end
    end

    function updateNavButtons()
        ch     = state.channel;
        nFiles = numel(state.experiment.(ch));
        prevBtn.Enable      = onOff(state.fileIdx > 1);
        nextBtn.Enable      = onOff(state.fileIdx < nFiles);
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
            for gi = 1:numel(groups)
                times  = sg.(groups{gi});
                times  = times(times >= t(1) & times <= t(end));
                amps   = interp1(t, state.trace, times, 'linear', 0);
                color  = GROUP_COLORS(mod(gi-1, size(GROUP_COLORS,1))+1, :);

                % Unselected spikes: normal group colour
                isSel = ismember(times, edit.selected);
                if any(~isSel)
                    scatter(traceAx, times(~isSel), amps(~isSel), 20, ...
                        color, 'filled', 'DisplayName', groups{gi}, ...
                        'HitTest', 'off');
                end
                % Selected spikes: yellow with black outline
                if any(isSel)
                    scatter(traceAx, times(isSel), amps(isSel), 40, ...
                        SEL_COLOR, 'filled', 'MarkerEdgeColor', [0 0 0], ...
                        'LineWidth', 1.0, 'DisplayName', '', ...
                        'HitTest', 'off');
                end
            end
            legend(traceAx, 'Location', 'northeast');
        end

        hold(traceAx, 'off');
        title(traceAx, sprintf('%s  —  file %d', ch, fi));
        traceAx.XLabel.String = 'Time (s)';
        traceAx.YLabel.String = 'mV';
        traceAx.ButtonDownFcn = @onAxesClick;   % re-attach after cla
        drawnow;
    end

    function buildTargetButtons(sg)
        delete(targetBtnContainer.Children);
        if isempty(sg) || ~isstruct(sg), return, end
        groups = fieldnames(sg);
        x = 4; btnW = 68; gap = 4;
        for gi = 1:numel(groups)
            gname = groups{gi};
            color = GROUP_COLORS(mod(gi-1, size(GROUP_COLORS,1))+1, :);
            lum   = 0.299*color(1) + 0.587*color(2) + 0.114*color(3);
            fc    = [0 0 0]; if lum < 0.55, fc = [1 1 1]; end
            uibutton(targetBtnContainer, 'Text', gname, ...
                'Position', [x 1 btnW 22], ...
                'BackgroundColor', color, 'FontColor', fc, ...
                'ButtonPushedFcn', @(~,~) reassignSelected(gname));
            x = x + btnW + gap;
        end
    end

    function clearTargetButtons()
        delete(targetBtnContainer.Children);
    end

    function refreshLabelList(sg)
        if isempty(sg) || ~isstruct(sg)
            labelList.Items = {}; return
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
        if isempty(sg) || ~isstruct(sg), n = 0; return, end
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