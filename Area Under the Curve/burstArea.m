function [m] = burstArea(directoryName, targetPage, targetNotebook, googleSheet)

    %% Description: For an animal, creates a mat file object for area data
    % to hold area associated data. Calls on calcBurstArea to calculate area 
    % for each file and also plot it along the way. 
    
    % Known issues: pathing for mat file save on windows 

    % Inputs
        % directory_name (str) -  file path to raw data folder, ie
        %   "/Volumes/marder-lab/kjacquerie/_raw data";
        %   Can also be set to "auto" and will find mac version access onto
        %   server path of raw data
        % targetPage (int) - page of experiment
        % targetNotebook (int) - page of notebook
        % googleSheet (str) - name for import google sheet
            % 'EJP', 'EJC', 'Real' etc. For burst data, use 'Real'

    % Outputs: 
        % m (mat file) - Creates a mat file associated with the animal 
        % to hold all area associated data; fields below
          % Activity and area are both 1 x #files size 
          % times, V, and V_S are len(time) x #files by in size 
                % (make a different row for each activity). 
          % V is the original Vm1 in the abf file, split by activity
          % V_S is the standardized one, where all pulses have the same baseline to make
          % area comparisons easier (all areas shifted up so Vrest = 0)
    
    % Last edited: Ananya Dalal Jun 16

%% Google Sheet Handling
targetNotebook = string(targetNotebook);
targetPage = string(targetPage);

datasheet = importRealSheet(googleSheet);

% Find rows where the 'page' column matches 'targetPage'
row = strcmp(datasheet.page, targetPage) & strcmp(datasheet.notebook, targetNotebook) ; % can switch to contains

% Display the rows where the page matches the target
notebook = str2double(targetNotebook); %str2double(datasheet.notebook{row});
page = str2double(targetPage); 
rois = datasheet.files{row}; 
electrodeName = datasheet.electrodes{row};
activity = datasheet.index_condition{row}; % should be an array with terms like LG11_11, LG_11_21 ... etc 
conditions = datasheet.conditions{row}; 
areas = [];
voltages = [];
voltages_s = [];
times = [];

% Create mat file that should contain everything in ananya's matfile folder
% in server

filename = "/Volumes/marder-lab/adalal/MatFiles/" + targetNotebook + "_" + targetPage + "_area.mat";
matObj = matfile(filename);
m = matfile(filename,'Writable',true);


for idx=1:1:length(rois)
    num_file =rois(idx); 
    % get data from plot overview, which loads abf and also will plot trace
    % for comparison
    [d, d_c, data] = plotOverview(directoryName, targetPage, targetNotebook, googleSheet, 0, num_file);
    
    % For now, just uses Vm1 data but update to make it electrode/muscle dependent
    Vm1 = data.Vm1_d;
    % Vm2 = data.Vm2_d;
    % Vm3 = data.Vm3_d;
    time = data.t_d;
    Pulse = data.Pulse_d;
    figTitle = strcat("Area Under Curve for ", activity(idx));

    % call on plotBurstArea to actually calculate the burst area and v
    % standardized to have a baseline of 0

    [fileArea, Vs] = calcBurstArea(time, Pulse, Vm1, figTitle);

    areas = [areas, fileArea];
    voltages = [voltages; Vm1];
    voltages_s = [voltages_s; Vs]; 
    times = [times; time];

    
end
% add fields to animal's mat file
m.animal = targetNotebook + "_" + targetPage;
m.areas = areas;
m.activityTemp = activity;
m.time = times;
m.voltages = voltages;
m.voltages_s = voltages_s;
