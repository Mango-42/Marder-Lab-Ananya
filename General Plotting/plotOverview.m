function [data, data_clean, data_downsampled] = plotOverview(directoryName, targetPage, targetNotebook, googleSheet, saveOn, range)
    
    % Description: plots and save continuous traces for rig experiments,
    % over full or custom range of ABF files in a directory
    % Takes data from up to 3 voltage electrodes, temp, and input channels
    % Cleans pulse artifacts; plots a downsampled version of this data

    % Known issues: Pathing is fine on mac, but for use on windows especially 
    % via other functions, fix the first pathing section so that 
    % "auto" option yields correct paths. 

    % Inputs:
        % directory_name (str) -  file path to raw data folder, ie
        %   "/Volumes/marder-lab/kjacquerie/_raw data";
        %   Can also be set to "auto" and will find mac version access onto
        %   server path of raw data

        % targetPage (int) - page of experiment
        % targetNotebook (int) - page of notebook
        % googleSheet (str) - name for import google sheet
            % 'EJP', 'EJC', 'Real' etc
        % saveOn (bool) - save figure (1) or not (0)

        % range (str, or int array) - range of experiment's abf files
            % 'full' for getting full range of experiment
            % 'roi' for getting only abf files stated in google sheet
            % or int array with range of files ie [0:10] or [1, 2, 7, 8,], etc
            
    % Outputs:
        % data (table): has these fields for each timepoint of experiment
            % # of the file, time, temp, Vm1, Vm2, Vm3, V input, In 5 and
            % In 6

        % data_clean (table): data with pulse artifact removed and replaced
        % data_downsampled (table): same as data_clean, but downsampled 10x
            % this is the dataset that is plotted

    % Last edited: Ananya Dalal July 21
%% Set directory automatically, or it remains whatever was inputted
% literally death and destruction, i forgot pathfinder wont work before
% R2022

if directoryName == "auto"
    directoryName = pathfinder(targetNotebook, targetPage);
end


%% Pull information from google sheet about experiment

targetNotebook = string(targetNotebook);
targetPage = string(targetPage);
fixedPage = sprintf('%03d',str2num(targetPage));

datasheet = import_googlesheet(googleSheet);

% Find rows where the 'page' column matches 'targetPage'
row = strcmp(datasheet.page, targetPage) & strcmp(datasheet.notebook, targetNotebook) ; % can switch to contains

% Display the rows where the page matches the target
notebook = str2double(targetNotebook); %str2double(datasheet.notebook{row});
page = str2double(targetPage); 

RecordType = datasheet.experiment{row}; 
pulseFiles = datasheet.files{row}; 

try
electrodeName = datasheet.electrodes{row};
% for FTHeart sheet where electrodes aren't labeled help
catch
    electrodeName = {"x", "x", "x"};
end

%%
% use full range of ABF files, or custom depending on input param
if isequal(range, "full")

    % switch directory briefly to get number of ABF files for experiment
    originalDirectory = cd; %save a ref to working directory
   
    cd(directoryName)
    
    numFiles = length(dir('*.abf'));
    files = double([0:numFiles - 1]);
    cd(originalDirectory) % switch back to working directory!
% use specific files from google sheet
elseif isequal(range, "roi") 
    files = pulseFiles;
% use custom range provided
else
    files = range;
end


%% Process experiment files using abfload

% Allocate space
Vm1 = [];
Vm2 = [];
Vm3 = [];
Pulse = []; % input current
Temp = []; 
abfNum = [];
PulseArea = []; % marked areas with pulses for processing
In5 = [];
In6 = [];
MissedFiles = []; % will print at the end, with any files that failed to load

% Constants
dt = 1e-4;


% should work for any rig if channel labels are same, even if in
% diff order
for idx=1:1:length(files)
    num_file =files(idx); 
    
    filename = sprintf('%s%d_%03d_%04d.abf', directoryName,notebook, page, num_file)
    disp(filename)
    
    try
        [d,~,h]=abfload(filename);
    catch e
        % catch if internal error triggered by abfload or you're in
        % the wrong directory
        error = "File " + string(files(idx)) + " didn't load";
        disp(error)
        fprintf(1,'The message was:\n%s',e.message);
        MissedFiles = [MissedFiles, error];
        continue
    end 

    % continually add datapoints from each ABF file into these vectors
    % don't separate by row/column bc abf files have diff sizes
    channels = h.recChNames;
    Temp = [Temp, transpose(d(:, ismember(channels, 'Temp')))];
    
    % check if Trig or input 5 or 6 channel exists on abf file 
    trigExists = sum(ismember(channels, 'Trig'));
    In5Exists = sum(ismember(channels, 'IN 5'));
    In6Exists = sum(ismember(channels, 'IN 6'));

    if trigExists == 1
        Pulse = [Pulse, transpose(d(:, ismember(channels, 'Trig')))];
    else % no input current? just put 0s 
        Pulse = [Pulse, zeros([1, length(d)])];
    end

    if In5Exists == 1
        In5 = [In5, transpose(d(:, ismember(channels, 'IN 5')))];
    else
        In5 = [In5, zeros([1, length(d)])];
    end

    if In6Exists == 1
        In6 = [In6, transpose(d(:, ismember(channels, 'IN 6')))];
    else
        In6 = [In6, zeros([1, length(d)])];
    end

    Vm1Exists = sum(ismember(channels, 'Vm_1'));
    if Vm1Exists == 1
    
        Vm1 = [Vm1, transpose(d(:, ismember(channels, 'Vm_1')))];
    else
        Vm1 = [Vm1, zeros([1, length(d)])];
    end


    Vm2Exists = sum(ismember(channels, 'Vm_2'));
    if Vm2Exists == 1
    
        Vm2 = [Vm2, transpose(d(:, ismember(channels, 'Vm_2')))];
    else
        Vm2 = [Vm2, zeros([1, length(d)])];
    end


    Vm3Exists = sum(ismember(channels, 'Vm_3'));
    if Vm3Exists == 1
        Vm3 = [Vm3, transpose(d(:, ismember(channels, 'Vm_3')))];
    else
        Vm3 = [Vm3, zeros([1, length(d)])];
    end

    % record what ABF file samples are from 
    abfNum = [abfNum, num_file * ones([1, length(d)])];

%     % marks areas that seem to have current pulses (1) for further
%     % processing, and ignore voltage steps (0)
%     if max(d(:,4)) > 10 || min(d(:,4)) < -5
%         PulseArea = [PulseArea, zeros([1, length(d)])];
%     else
%         PulseArea = [PulseArea, ones([1, length(d)])];
%     end
 
end

% Print any files that for any reason weren't processed by ABFLoad
MissedFiles

% set time vector now that all data is collected
t = dt * (1:length(Vm1));

%% Remove artifacts in Vm traces from pulse and downsample for plotting

status = "Data collected -- removing artifacts (may take ~30s)...";
disp(status)

% Find area of pulse + small delay in read (seemed like 30 dts)

% remove_idx = (find(PulseArea == 1 & Pulse > .01));
% remove_idx = [remove_idx, remove_idx + 30];
% valid_idx = find(remove_idx <= length(Pulse)); % prevents adding extra NaNs
% remove_idx = remove_idx(valid_idx);

% Vm_c = cleaned Vm1
Vm1_c = Vm1;
Vm2_c = Vm2;
Vm3_c = Vm3;

% DONT do cleaning of pulse artifacts on intact sheet
if googleSheet == "EJP";
    Vm1_c(remove_idx) = NaN;
    Vm2_c(remove_idx) = NaN;
    Vm3_c(remove_idx) = NaN;
    
    % Remove NaNs just by filling with previous val - simple solution for now
    Vm1_c = fillmissing(Vm1_c,'previous');
    Vm2_c = fillmissing(Vm2_c,'previous');
    Vm3_c = fillmissing(Vm3_c,'previous');
end

% Downsample the data: plotting 300 million datapoints hurts my computer :( 
% Vm_d = downsampled Vm_c

t_d = downsample(t, 10);
Temp_d = downsample(Temp, 10);
Vm1_d = downsample(Vm1_c, 10);
Vm2_d = downsample(Vm2_c, 10);
Vm3_d = downsample(Vm3_c, 10);
Pulse_d = downsample(Pulse, 10);
In5_d = downsample(In5, 10);
In6_d = downsample(In6, 10);
abfNum_d = downsample(abfNum, 10);

%% Plot data after processing
% Note that because of ylims, data seems to be getting compressed? unsure why

status = "Data processed -- Plotting figure";
disp(status)

t_min = t_d / 60; % plot axis in minutes for whole experiment
figure

sgtitle(append("Notebook ", targetNotebook, " page ", targetPage, ": Post-processing: Muscle voltage over time"));

%Temperature
subplot(5, 1, 1)
plot(t_min, Temp_d, 'r-');
ylim([round(min(Temp) - 1), round(max(Temp) + 1)])
ylabel('T (°C)')
set(gca, 'XTickLabel', [])

% Vm1
subplot(5, 1, 2)
plot(t_min, Vm1_d, 'k-');
ylabel(string(electrodeName(1)) + " (mV)")

% handle limits on plot in case there's some noise or electrode falls out
lower = -Inf;
upper = Inf;
if max(Vm1_d) > 0
    upper = 0;
end
if min(Vm1_d) < -150
    lower = -150;
end
ylim([lower, upper])
set(gca, 'XTickLabel', [])

% Vm2
subplot(5, 1, 3)
plot(t_min, Vm2_d, 'k-');
ylabel(string(electrodeName(2)) + " (mV)")
lower = -Inf;
upper = Inf;
if max(Vm2_d) > 0
    upper = 0;
end
if min(Vm2_d) < -150
    lower = -150;
end
ylim([lower, upper])
set(gca, 'XTickLabel', [])

set(gca, 'XTickLabel', [])

% Vm3 (if exists)
if length(electrodeName) > 2
    subplot(5, 1, 4)
    plot(t_min, Vm3_d, 'k-');
    ylabel(string(electrodeName(3)) + " (mV)")
    lower = -Inf;
    upper = Inf;
    if max(Vm3_d) > 0
        upper = 0;
    end
    if min(Vm3_d) < -150
        lower = -150;
    end
    ylim([lower, upper])
    set(gca, 'XTickLabel', [])
    
    % Input from pulse machine
    subplot(5, 1, 5)
    plot(t_min, Pulse_d);
    ylim([-1, 10])
    ylabel("V input (mV)")
    xlabel('Time (min)', 'fontsize', 15)

else
    % Input from pulse machine
    subplot(5, 1, 4)
    plot(t_min, Pulse_d);
    ylim([-1, 10])
    ylabel("V input (mV)")
    xlabel('Time (min)', 'fontsize', 15)
end

% Set properties for all axes
set(findall(gcf,'-property','fontname'),'fontname','times')
set(findall(gcf,'-property','box'),'box','off')

allAxes = findall(gcf,'type','axes');
linkaxes(allAxes, 'x')

%% Save plot as SVG in current working directory

if saveOn == 1
    status = "Saving figure as SVG to current working directory";
    disp(status)
    saveName = strcat(targetNotebook, '_', fixedPage, '_', "overview", ".svg");
    saveas(gcf, saveName)
end

%% Variables to return for analysis

data = table(abfNum, t, Temp, Vm1, Vm2, Vm3, Pulse, In5, In6);
data_clean = table(abfNum, t, Temp, Vm1_c, Vm2_c, Vm3_c, Pulse, In5, In6);

data_downsampled = table(abfNum_d, t_d, Temp_d, Vm1_d, Vm2_d, Vm3_d, Pulse_d, In5_d, In6_d);

status = "Process complete!";
disp(status)
