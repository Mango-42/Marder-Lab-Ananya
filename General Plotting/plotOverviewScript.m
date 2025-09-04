%% Sample script for using plotOverview.m
% Requirements: import_googlesheet.m, abfload.m on path
% Plotting for experiments listed in kathleen's google datasheet. 

% set directories for different people/rigs raw data folders, 
% modify as needed
kathleen_dir = "/Volumes/marder-lab/kjacquerie/_raw data";
% kathleen_dir = "/Users/kathleen/Documents/PostDoc/2025-IK";
ani_dir = "/Volumes/marder-lab/apoghosyan/raw data";

% Sample run (1 experiment)

% quick test
targetNotebook = 992;
targetPage = 44;
googleSheet = 'Intact';
saveOn = 0; % change to 1 if you want to save plot

% can do a number, range (ie, [1 2 3 4]), range = 'full' for whole exp
% or range = 'roi' for files of interest only
range = "roi"; 

% pick correct directory to use based on notebook number
if targetNotebook == 988 || targetNotebook == 985 || targetNotebook == 992
    directoryName = kathleen_dir;

elseif targetNotebook == 943
    directoryName = ani_dir;
else
    directoryName = "auto"; % will only work on mac
end

% returns 3 tables containing original data, cleaned data, and
% downsampled cleaned data that gets plotted
[d, d_c, d_d] = plotOverview(directoryName, targetPage, targetNotebook, googleSheet, saveOn, range);

%% Plot and save data for many experiments

% pairwise notebooks and pages
notebooks = [988, 985, 985, 985, 985, 985, 943, 988, 988, 943, 943];
pages = [34, 72, 74, 80, 84, 96, 70, 66, 68, 98, 102];

for i = 1:length(notebooks)
    targetNotebook = notebooks(i);
    targetPage = pages(i);
    saveOn = 1;
    range = "full";
    
    % pick correct directory to use based on notebook number
    if targetNotebook == 988 || targetNotebook == 985 || targetNotebook == 992
    directoryName = kathleen_dir;

    elseif targetNotebook == 943
        directoryName = ani_dir;
    else
        directoryName = "auto";
    end
    
    [d, d_c, d_d] = plotOverview(directoryName, targetPage, targetNotebook, googleSheet, saveOn, range);

end
%% Can also use data that plot overview returns

disp(d_d.Properties.VariableNames)
Vm1 = d_d.Vm1_d; % trace of Vm1
Vm3 = d_d.Vm3_d; % trace of Vm3
time = d_d.t_d; % time
pulse = d_d.Pulse_d; % input current / pulses
abfnum = d_d.abfNum_d;
% 
% figure()
% plot(time, Vm1)