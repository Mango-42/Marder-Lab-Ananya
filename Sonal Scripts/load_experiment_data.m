function extracted_data = load_experiment_data(metadata, Exp_no)
%%
% % Load metadata
% metadata = load('metadata_JD.mat');

% Get folder name
folder = metadata(Exp_no).folder;
directory = "/Volumes/marder-lab/skedia/Sonal_data/" + folder;
file_search = strcat(directory, '/', '*.abf') % Find ABF files
files = dir(file_search) % List ABF files

% Initialize storage
Data = cell(1, length(files)); % Pre-allocate for efficiency
file_names = cell(1, length(files));
continuous_files=[];
ramp_files=[];
% Load ABF files
for i = 1:length(files)
    file_names{i} = files(i).name;
    fullfile_name = fullfile(directory, file_names{i})

    try
        [~, ~, fields_for_names] = abfload(fullfile_name, 'info');% Get ABF file info- channel names, etc
        %if strcmp(fields_for_names.protocolName,'\Users\Admin\Desktop\Protocols\2min_continuous_4In_6Ex.pro')==1
        [raw_data, ~, h] = abfload(fullfile_name); % Load ABF file data 
        Data{i} = raw_data';  % Ensure correct orientation: Channels x Samples
        continuous_files= [continuous_files, i];
        %else
         %   ramp_files=[ramp_files, i];
       % end
    catch
        warning('Could not load file: %s', fullfile_name);
    end
end

% Get recorded channel names
[~, ~, fields_for_names] = abfload(fullfile_name, 'info');
recorded_channels = fields_for_names.recChNames;

% Define possible cell types
cell_types = { 'PD','LP', 'LPG', 'GM', 'VD', 'PY', ...
    'lvn', 'pdn','lpn','llvn','ulvn', 'pyn',   'mvn', 'temp', ...
    'heart', 'Temp', 'p1', 'cpv4', 'gm5b', 'p2'};

% Initialize extracted data structure
extracted_data = struct();

% Loop through all possible cell types
for i = 1:length(cell_types)
    cell_type = cell_types{i};

    % Check if the metadata field exists and is non-empty
    if isfield(metadata(Exp_no).channels, cell_type) && ~isempty(metadata(Exp_no).channels.(cell_type))
        channel_name = metadata(Exp_no).channels.(cell_type);

        % Find index of the corresponding channel in recorded data
        channel_idx = find(strcmp(recorded_channels, channel_name));

        if ~isempty(channel_idx)
            % Extract and store full channel data for each file
            extracted_data.(cell_type) = cellfun(@(x) x(channel_idx, :), Data, 'UniformOutput', false);
        else
            warning('Channel %s not found in recorded data', channel_name);
        end
    end
end
% save file ids for different experimental protocols
extracted_data.cont_files= continuous_files;
extracted_data.ramp_files= ramp_files;
% full_length_temp=[];
% for i= 1:length(files)
%         % Save the extracted full-length temperature data
%         full_length_temp =[full_length_temp, extracted_data.Temp{i}]; % Keep as a cell array
% end
%         temp_file_name = strcat(metadata.Foldername{Exp_no}, '_temp.mat');
%         save(temp_file_name, 'full_length_temp');
% 
% 
% % Extract temperature-related data
% if metadata.up_ramp_start(Exp_no)~=0
% 
% up_ramp_start = metadata.up_ramp_start(Exp_no);
% up_ramp_end = metadata.up_ramp_end(Exp_no);
% highest_temp = metadata.highest_temp(Exp_no);
% Fs=10000;
% 
% % Ensure temperature data is extracted correctly
% if isfield(metadata, 'Temp_channel') && ~isempty(metadata.Temp_channel{Exp_no})
%     temp_channel_name = metadata.Temp_channel{Exp_no};
%     temp_channel_idx = find(strcmp(recorded_channels, temp_channel_name));
% 
%     if ~isempty(temp_channel_idx)
%         extracted_data.Temp = cellfun(@(x) x(temp_channel_idx, :), Data, 'UniformOutput', false);
%     else
%         warning('Temperature channel not found in recorded data.');
%         extracted_data.Temp = {};
%     end
% else
%     warning('No temperature channel specified in metadata.');
%     extracted_data.Temp = {};
% end
% 
% Extract Temperature Steps and Time Stamps
% start_temp = 11;
% end_temp = highest_temp;
% temp_steps = start_temp:4:end_temp;
% temp_labels = string(temp_steps) + "°C";
% 
% p = 1;
% temp_files = [];
% lim1_temp = [];
% 
% for i = up_ramp_start:up_ramp_end + 1
%     if isempty(extracted_data.Temp)
%         break;
%     end
% 
%     temp_data = extracted_data.Temp{i}; % Extract correct Temp channel
%     idx = find(temp_data > temp_steps(p), 1, 'first');
% 
%     if ~isempty(idx)
%         t_start = idx / Fs;  % Convert index to time
%         if t_start + 8 >= 120
%             t_start = 120 - (8 + 0.0002);
%         end
%         lim1_temp(p) = t_start;
%         temp_files(p) = i;
%         p = p + 1;
%         if p > length(temp_steps)
%             break;
%         end
%     end
% end
% 
% % Store temperature-related data in extracted_data struct
% extracted_data.temp_steps = temp_steps;
% extracted_data.temp_labels = temp_labels;
% extracted_data.temp_files = temp_files;
% extracted_data.lim1_temp = lim1_temp;
% else
% end
end