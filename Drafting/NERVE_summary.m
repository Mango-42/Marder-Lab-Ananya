%% ============ Burst features vs Temperature (median ± SEM per experiment) ============
% Loads <NB>_<PAGE>_burst.mat files (e.g., 998_035_burst.mat) and plots binned medians
% (± SEM via bootstrap) for spikesPer, spikeFreq, and burstFreq found in bursts.<NEURON>.
%
% Selection:
%   (A) From a Google Sheet (filters: acclimation)
%   (B) Manual NB_PAGE list
%
% Requires (only if selectMode=="sheet"): import_googlesheet.m

clear; clc; close all;

%% ----------------------- USER CONFIG -----------------------
selectMode    = "manual";        % "sheet" or "manual"
googleSheet   = 'Intact';       % used only if selectMode=="sheet"
acclimation   = "all";          % "all" or 4 / 11 / 18

NB_PAGE_list  = ["998_24","998_28", "998_46"];  % used only when selectMode=="manual"
NB_PAGE_list  = ["992_62","992_63", "992_96", "992_143", "998_30", "998_34","998_35"];  % used only when selectMode=="manual"
NB_PAGE_list  = ["992_62","992_63","992_96","998_30","998_34","998_35", "998_46", "998_114", "998_126", "998_128", "998_129", "998_130", "998_138", "998_142"];  % <= edit as needed

NB_PAGE_list  = ["992_63","992_96", "992_143",  "998_24", "998_28","998_30","998_34","998_35", "998_46", "998_114", "998_126", "998_128", "998_129", "998_130", "998_138", "998_142"];  % <= edit as needed

dataRoot      = "/Volumes/marder-lab/adalal/MatFiles";
neuron        = "LP";           % analyze bursts.<neuron>, e.g., "LP", "PD", "PY", ...

% Optional: restrict to some conditions (use [] to keep all)
% Example: conditionFilter = ["saline","0.5xK"];
conditionFilter = "saline";   % << enforce saline-only


binCenters    = [6:1:29];   % °C
halfWidth     = 1;                   % ± °C
nBoot         = 400;                   % bootstrap resamples for SEM of median

doSave        = false;
outDir        = "/Users/kathleen/Documents/PostDoc/2026-Tcompensation/fig/NERVE";
% if ~exist(outDir,'dir'), mkdir(outDir); end
% saveName      = sprintf('bursts_%s_neuron-%s_acc-%s.svg', string(googleSheet), string(neuron), string(acclimation));

yLims.spikesPer = [0 inf];
yLims.spikeFreq = [0 inf];
yLims.burstFreq = [0 inf];

%% --------------------- Resolve NB_PAGE list ---------------------
switch lower(selectMode)
    case "sheet"
        ds = import_googlesheet(googleSheet);
        if isstring(acclimation) && acclimation == "all"
            accRows = 1:height(ds);
        else
            accRows = find(string(ds.acclimation) == string(acclimation)).';
        end
        if isempty(accRows)
            warning('No rows matched acclimation=%s in sheet %s.', string(acclimation), googleSheet);
            return;
        end
        NB_PAGE_list = strings(0,1);
        for k = accRows
            nb  = string(ds.notebook{k});
            pg  = string(ds.page{k});
            NB_PAGE_list(end+1) = nb + "_" + pg; %#ok<SAGROW>
        end
    case "manual"
        NB_PAGE_list = string(NB_PAGE_list(:));
    otherwise
        error('selectMode must be "sheet" or "manual".');
end
NB_PAGE_list = unique(NB_PAGE_list, 'stable');

%% --------------------- Prepare palette & storage ---------------------
nExp    = numel(NB_PAGE_list);
colorsExp = distinct_colors_strict(nExp);   % one unique color per experiment


features = ["spikesPer","spikeFreq","burstFreq"];
titles   = ["Spikes per burst","Spike frequency (Hz)","Burst frequency (Hz)"];
nFeat    = numel(features);
nBins    = numel(binCenters);

MED = struct(); SEM = struct();
for f = 1:nFeat
    MED.(features(f)) = nan(nExp, nBins);
    SEM.(features(f)) = nan(nExp, nBins);
end
labels = strings(nExp,1);

% Tracking for reporting
missingFiles    = strings(0,1);
missingNeuron   = strings(0,1);
noUsableData    = strings(0,1);  % all bins NaN
perBinMissing   = cell(nExp,1);  % list bin centers missing for each exp

%% --------------------- Load each experiment & bin ---------------------
for e = 1:nExp
    nbp = NB_PAGE_list(e);
    labels(e) = "NB: " + extractBefore(nbp,"_") + " page " + extractAfter(nbp,"_");

    matPath = fullfile(dataRoot, nbp + "_burst.mat");
    if ~isfile(matPath)
        missingFiles(end+1) = nbp; %#ok<SAGROW>
        continue;
    end

    S = load(matPath);   % expects variable "bursts"
    if ~isfield(S, 'bursts') || ~isfield(S.bursts, neuron)
        missingNeuron(end+1) = nbp; %#ok<SAGROW>
        continue;
    end

    B = S.bursts.(neuron);
        % Optional: quick peek at conditions present
    if isfield(B,'condition')
        u = unique(strtrim(lower(string(B.condition(:)))));
        fprintf('Conditions in %s: %s\n', nbp, strjoin(u', ', '));
    end

    % Pull vectors
    if ~isfield(B,'temp')
        missingNeuron(end+1) = nbp; %#ok<SAGROW>
        continue;
    end
    T  = B.temp(:);

    % Features we need (guard if absent)
    d1 = getfield_or_nan(B,'spikesPer');  % column vector or NaN
    d2 = getfield_or_nan(B,'spikeFreq');
    d3 = getfield_or_nan(B,'burstFreq');


    % Optional condition filter (robust: case-insensitive, trims spaces)
    keep = ~isnan(T);
    if ~isempty(conditionFilter)
        if isfield(B,'condition')
            rawCond = string(B.condition(:));
            % normalize both sides: lower case + trim spaces
            normCond = strtrim(lower(rawCond));
            want     = strtrim(lower(string(conditionFilter(:))));   % allow array
            keep = keep & ismember(normCond, want);
            % For reporting: count how many samples were retained
            keptN = sum(keep);
            if keptN==0
                fprintf('WARN: %s has 0 samples after condition filter (%s).\n', ...
                    nbp, strjoin(string(conditionFilter),', '));
            end
        else
            % No condition field: drop this experiment (keeps saline-only guarantee)
            fprintf('WARN: %s has no "condition" field; skipping to guarantee saline-only.\n', nbp);
            keep(:) = false;
        end
    end


    T  = T(keep);
    d1 = d1(keep);
    d2 = d2(keep);
    d3 = d3(keep);

    % Bin + record which bins are missing
    missBins = false(1, nBins);
    for b = 1:nBins
        tc   = binCenters(b);
        idx  = (T >= (tc - halfWidth)) & (T < (tc + halfWidth));

        [MED.spikesPer(e,b), SEM.spikesPer(e,b)] = med_sem_boot(d1(idx), nBoot);
        [MED.spikeFreq(e,b), SEM.spikeFreq(e,b)] = med_sem_boot(d2(idx), nBoot);
        [MED.burstFreq(e,b), SEM.burstFreq(e,b)] = med_sem_boot(d3(idx), nBoot);

        % count a bin as missing if ALL three features are NaN (no samples)
        if all(isnan([MED.spikesPer(e,b), MED.spikeFreq(e,b), MED.burstFreq(e,b)]))
            missBins(b) = true;
        end
    end
    perBinMissing{e} = binCenters(missBins);

    % Mark experiments with no usable bins at all
    if all(isnan(MED.spikesPer(e,:))) && all(isnan(MED.spikeFreq(e,:))) && all(isnan(MED.burstFreq(e,:)))
        noUsableData(end+1) = nbp; %#ok<SAGROW>
    end
end

%% --------------------- Plot (3 aligned panels) ---------------------
f = figure('Color','w');
tl = tiledlayout(3,1,'TileSpacing','compact','Padding','compact');

% For legend: keep only lines that were actually drawn
hLinesForLegend = gobjects(0);
labelsForLegend = strings(0,1);

for p = 1:3
    nexttile; hold on;
    ax = gca;
    set(ax,'FontName','Arial','FontSize',11,'TickDir','out','TickLength',[0.02 0.02]);
    box off; grid on; grid minor;
    xlim([min(binCenters)-2, max(binCenters)+2]);

    % Light gray band (21?35 °C), hidden from legend
    yl = ylim;
    band = patch([21 35 35 21],[yl(1) yl(1) yl(2) yl(2)], [0.965 0.965 0.965], ...
                 'EdgeColor','none','HandleVisibility','off');
    uistack(band,'bottom');
    addlistener(ax,'YLim','PostSet',@(src,evt) ...
        set(band,'YData',[evt.AffectedObject.YLim(1) evt.AffectedObject.YLim(1) ...
                           evt.AffectedObject.YLim(2) evt.AffectedObject.YLim(2)]));

    % Choose data for this panel
    switch p
        case 1, med = MED.spikesPer; sem = SEM.spikesPer; ylim(yLims.spikesPer);
        case 2, med = MED.spikeFreq; sem = SEM.spikeFreq; ylim(yLims.spikeFreq);
        case 3, med = MED.burstFreq; sem = SEM.burstFreq; ylim(yLims.burstFreq);
    end

    % Plot per experiment; only add to legend if there is at least one non-NaN
    for e = 1:nExp
        if all(isnan(med(e,:))), continue; end  % skip fully-missing traces

        c = colorsExp(e,:);   % do NOT wrap with mod/size

        y1 = med(e,:) - sem(e,:);
        y2 = med(e,:) + sem(e,:);
        [xb, ylo, yhi] = local_nan_strips(binCenters, y1, y2);
        for seg = 1:numel(xb)
            if numel(xb{seg}) >= 2
                xv = [xb{seg}  fliplr(xb{seg})];
                yv = [ylo{seg} fliplr(yhi{seg})];
                patch('XData',xv,'YData',yv,'FaceColor',c,'FaceAlpha',0.18, ...
                      'EdgeColor','none','HandleVisibility','off');
            end
        end
        h = plot(binCenters, med(e,:), '-o', 'Color', c, 'MarkerFaceColor', c, ...
                 'MarkerSize',4, 'LineWidth',1.6);
        % only record legend entry once (first panel where it appears)
        if p == 1
            hLinesForLegend(end+1,1) = h; %#ok<AGROW>
            labelsForLegend(end+1,1) = labels(e); %#ok<AGROW>
        end
    end

    ylabel(sprintf('%s', titles(p)));
    %title(titles(p));
    if p < 3
        set(gca,'XTickLabel',[]);
    else
        xlabel('Temperature (°C)');
    end
end

% ---- Legend: only for lines that were actually drawn ----
if ~isempty(hLinesForLegend)
    lg = legend(hLinesForLegend, labelsForLegend, ...
        'Location','eastoutside','Interpreter','none');
    %lg.Title.String = 'Experiments';
end

% ---- NO overall figure title (as requested) ----
% (intentionally removed)

% Save
% if doSave
%     set(f,'PaperUnits','centimeters','PaperPosition',[0 0 18 20]);
%     print(f, fullfile(outDir, saveName), '-dsvg');
%     fprintf('Saved: %s\n', fullfile(outDir, saveName));
% end

%% --------------------- Console report of missing data ---------------------
fprintf('\n========== Missing-data report (neuron = %s) ==========\n', string(neuron));

if ~isempty(missingFiles)
    fprintf('Missing files (%d):\n', numel(missingFiles));
    for i=1:numel(missingFiles), fprintf('  - %s_burst.mat\n', missingFiles(i)); end
else
    fprintf('Missing files: none\n');
end

if ~isempty(missingNeuron)
    fprintf('Files present but missing bursts.%s (%d):\n', string(neuron), numel(missingNeuron));
    for i=1:numel(missingNeuron), fprintf('  - %s_burst.mat\n', missingNeuron(i)); end
else
    fprintf('Files missing bursts.%s: none\n', string(neuron));
end

% Experiments that loaded but had no usable bins across ALL features
if ~isempty(noUsableData)
    fprintf('No usable data in any bin (%d):\n', numel(noUsableData));
    for i=1:numel(noUsableData), fprintf('  - %s\n', noUsableData(i)); end
else
    fprintf('All loaded experiments had at least one usable bin.\n');
end

% Per-experiment per-bin gaps (for those that did plot at least one point)
fprintf('Per-experiment missing bins (by center):\n');
for e = 1:nExp
    nbp = NB_PAGE_list(e);
    % Count plotted as having any non-NaN in any feature:
    plotted = any(~isnan(MED.spikesPer(e,:))) | any(~isnan(MED.spikeFreq(e,:))) | any(~isnan(MED.burstFreq(e,:)));
    if plotted
        gaps = perBinMissing{e};
        if isempty(gaps)
            fprintf('  - %s: none\n', nbp);
        else
            fprintf('  - %s: %s\n', nbp, strjoin(string(gaps), ', '));
        end
    end
end
fprintf('=======================================================\n');

%% ======================= LOCAL HELPERS =======================
function v = getfield_or_nan(S, fname)
    if isfield(S, fname)
        v = S.(fname)(:);
    else
        v = nan(size(S.temp(:)));
    end
end

function [m, s] = med_sem_boot(x, nBoot)
    x = x(:); x = x(~isnan(x));
    if isempty(x)
        m = NaN; s = NaN; return;
    end
    m = median(x);
    if numel(x) >= 2
        n = numel(x);
        mb = nan(nBoot,1);
        for bb = 1:nBoot, mb(bb) = median(x(randi(n,n,1))); end
        s = std(mb,'omitnan');
    else
        s = NaN;
    end
end

function C = local_distinguishable_colors(n)
% Distinct, color-blind-safe palette for any n.
% - Uses a strong qualitative base (Tol/Tableau/ColorBrewer mix).
% - For n > size(base,1), expands with evenly spaced hues (golden-ratio order)
%   and alternates saturation/brightness to avoid ?all same? pastels.

    % --- strong qualitative base (22 colors) ---
    base = [ ...
        0.000 0.450 0.700;  % blue
        0.835 0.371 0.000;  % orange
        0.000 0.620 0.451;  % teal
        0.800 0.475 0.655;  % pink
        0.941 0.894 0.259;  % yellow
        0.902 0.624 0.000;  % amber
        0.337 0.706 0.914;  % sky
        0.000 0.447 0.000;  % dark green
        0.800 0.000 0.000;  % red
        0.580 0.404 0.741;  % purple
        0.651 0.337 0.157;  % brown
        0.400 0.400 0.400;  % gray
        0.121 0.466 0.705;  % blue2
        1.000 0.498 0.054;  % orange2
        0.172 0.627 0.172;  % green2
        0.839 0.153 0.157;  % red2
        0.580 0.404 0.741;  % purple2
        0.549 0.337 0.294;  % brown2
        0.890 0.467 0.761;  % magenta
        0.498 0.498 0.498;  % gray2
        0.737 0.741 0.133;  % olive
        0.090 0.745 0.811]; % cyan

    m = size(base,1);
    if n <= m
        C = base(1:n,:);
        return;
    end

    % --- need more: generate well-separated hues ---
    k   = n - m;
    % golden-ratio step for good separation
    phi = (1 + sqrt(5))/2;
    H   = mod((0:k-1) * (1/phi), 1);     % 0..1 hues, well spread
    % alternate saturation/brightness to keep neighbors distinct
    S   = repmat([0.95; 0.75], ceil(k/2), 1); S = S(1:k);
    V   = repmat([0.90; 0.70], ceil(k/2), 1); V = V(1:k);

    ext = hsv2rgb([H(:) S(:) V(:)]);
    % interleave with base so new colors aren?t all at the end
    C = zeros(n,3);
    C(1:m,:)          = base;
    C(m+1:n,:)        = ext;

    % small reorder to separate near neighbors (again using golden-ratio hop)
    idx = mod(round((0:n-1)*(1/phi))*3, n) + 1;  % multiply & mod to shuffle
    C = C(idx,:);
end


function [xb, ylo, yhi] = local_nan_strips(x, y1, y2)
    valid  = ~(isnan(y1) | isnan(y2));
    d      = diff([false valid false]);
    starts = find(d==1);
    ends   = find(d==-1) - 1;
    xb = cell(numel(starts),1); ylo = xb; yhi = xb;
    for ii=1:numel(starts)
        idx = starts(ii):ends(ii);
        xb{ii}  = x(idx);
        ylo{ii} = y1(idx);
        yhi{ii} = y2(idx);
    end
end


function C = distinct_colors_strict(n)
% Distinct, color-blind-friendly colors for ANY n (no repeats).
% Base: 20 Tableau/ColorBrewer-like unique colors.
% Expansion: evenly spaced HSV with a coprime-step permutation (true bijection).

    base = [ ... % 20 UNIQUE colors
        0.894, 0.102, 0.110;  % red
    0.216, 0.494, 0.722;  % blue
    0.302, 0.686, 0.290;  % green
    1.000, 0.498, 0.000;  % orange
    0.600, 0.308, 0.631;  % purple
    0.651, 0.337, 0.157;  % brown
    0.969, 0.506, 0.749;  % pink
    0.580, 0.580, 0.580;  % gray
    0.890, 0.466, 0.000;  % amber
    0.337, 0.706, 0.914;  % sky blue
    0.000, 0.620, 0.451;  % teal
    0.835, 0.371, 0.000;  % burnt orange
    0.494, 0.184, 0.556;  % violet
    0.737, 0.741, 0.133;  % olive
    0.121, 0.466, 0.705;  % dark blue
    0.800, 0.475, 0.655;  % rose
    0.172, 0.627, 0.172;  % dark green
    0.929, 0.694, 0.125;  % gold
    0.090, 0.745, 0.811;  % cyan
    0.984, 0.603, 0.600;  % light red
    0.415, 0.239, 0.603;  % indigo
    0.992, 0.682, 0.380;  % light orange
    0.400, 0.651, 0.118;  % lime
    0.580, 0.404, 0.741;  % lavender
    0.125, 0.698, 0.667;  % turquoise
    0.941, 0.894, 0.259;  % yellow
    0.160, 0.500, 0.725]; % steel blue

    m = size(base,1);
    if n <= m
        C = base(1:n,:);
        return;
    end

    % Need more: generate additional, well-separated hues
    k = n - m;
    H = linspace(0,1,k+1); H(end) = [];
    S = 0.92*ones(k,1);
    V = 0.85*ones(k,1);
    ext = hsv2rgb([H(:) S V]);

    % Permute with a coprime step to avoid near neighbors
    step = max(1, round(k/3));
    while gcd(step,k) ~= 1
        step = step + 1;
    end
    order = mod((0:k-1)*step, k) + 1;
    ext = ext(order,:);

    % Concatenate: base first, then extended
    C = [base; ext];

    % Final safety: ensure exactly n rows
    C = C(1:n,:);
end


function C = rainbow_colors(n)
% Generates n colors spanning smoothly from red to blue (rainbow-like).
% n = number of distinct colors (e.g., 27 for your case).

    % Hue range: red (0°) ? blue (240°) in HSV space
    H = linspace(0, 240/360, n)';  % 0 to 240 degrees, normalized [0,1]
    S = ones(n,1) * 0.9;            % strong saturation
    V = ones(n,1) * 0.9;            % high brightness
    C = hsv2rgb([H S V]);
end


