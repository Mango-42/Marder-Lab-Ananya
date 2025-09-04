function datasheet = import_googlesheet(sheetName)

    % ------------
    % Go to File > Share > Publish to the web.
    % Choose the option to publish the entire document or a specific sheet.
    % Make sure to publish it in Comma-separated values (.csv) format.
    % Copy the URL provided by Google Sheets that ends with output=csv.

    options = weboptions('ContentType', 'table', 'Timeout', 15);

    switch sheetName
        case 'EJP'
            url_name = 'https://docs.google.com/spreadsheets/d/e/2PACX-1vTtVhS0VwtAOj80c0RromaAHAEXuODhg48-OZ3vdKzZegYmYCwwdGqUPuKKfS6L9v-7JPpPt3XPWLlm/pub?gid=1889790711&single=true&output=csv';
            %url_name = 'https://docs.google.com/spreadsheets/d/e/2PACX-1vTtVhS0VwtAOj80c0RromaAHAEXuODhg48-OZ3vdKzZegYmYCwwdGqUPuKKfS6L9v-7JPpPt3XPWLlm/pub?gid=875096595&single=true&output=csv';
            %url_name = 'https://docs.google.com/spreadsheets/d/e/2PACX-1vTtVhS0VwtAOj80c0RromaAHAEXuODhg48-OZ3vdKzZegYmYCwwdGqUPuKKfS6L9v-7JPpPt3XPWLlm/pub?output=csv';
        case 'IV'
            url_name = 'https://docs.google.com/spreadsheets/d/e/2PACX-1vTtVhS0VwtAOj80c0RromaAHAEXuODhg48-OZ3vdKzZegYmYCwwdGqUPuKKfS6L9v-7JPpPt3XPWLlm/pub?gid=176181240&single=true&output=csv';
        case 'EJC'
            url_name = 'https://docs.google.com/spreadsheets/d/e/2PACX-1vTtVhS0VwtAOj80c0RromaAHAEXuODhg48-OZ3vdKzZegYmYCwwdGqUPuKKfS6L9v-7JPpPt3XPWLlm/pub?gid=467200414&single=true&output=csv'; 
        case 'Real'
            url_name = 'https://docs.google.com/spreadsheets/d/e/2PACX-1vTtVhS0VwtAOj80c0RromaAHAEXuODhg48-OZ3vdKzZegYmYCwwdGqUPuKKfS6L9v-7JPpPt3XPWLlm/pub?gid=916018646&single=true&output=csv';
        case 'Intact'
            url_name = 'https://docs.google.com/spreadsheets/d/e/2PACX-1vTtVhS0VwtAOj80c0RromaAHAEXuODhg48-OZ3vdKzZegYmYCwwdGqUPuKKfS6L9v-7JPpPt3XPWLlm/pub?gid=908466604&single=true&output=csv';
        case 'FTHeart'
            url_name = 'https://docs.google.com/spreadsheets/d/e/2PACX-1vTtVhS0VwtAOj80c0RromaAHAEXuODhg48-OZ3vdKzZegYmYCwwdGqUPuKKfS6L9v-7JPpPt3XPWLlm/pub?gid=385819826&single=true&output=csv';
               
    end
    
    datasheet = webread(url_name, options);

    disp("ok here is the raw datasheet")
    disp(datasheet)
    
    % Try to read the CSV data as a table
    if all(startsWith(datasheet.Properties.VariableNames, 'Var'))
        % Extract the first row as variable names
        newVarNames = table2cell(datasheet(1, :)); 

        % Assign new variable names from the first row
        datasheet.Properties.VariableNames = newVarNames; 

        % Remove the first row (since it's now treated as headers)
        datasheet(1, :) = []; 
    else
        datasheet(1, :) = []; 
    end




    % Convert the comma-separated strings to numeric arrays
    for i = 1:height(datasheet)
        % Split the string by commas
        index_files = strsplit(datasheet.files{i}, ' ');
        % on all sheets but intact
        try
        index_cond =  strsplit(datasheet.index_condition{i}, ' ');
        datasheet.index_condition{i} = str2double(strtrim(index_cond)); 
        catch e

        end

        % on intact sheet
        try
            temp_values = strsplit(datasheet.temperature_values{i}, ' ');
            datasheet.temperature_values{i} = str2double(strtrim(temp_values));

        catch

        end

        % on FTHeart
        try
            temp_values = strsplit(datasheet.temp_index{i}, ' ');
            datasheet.temp_index{i} = str2double(strtrim(temp_values));
            
            cond_index = strsplit(datasheet.condition_index{i}, ' ');
            datasheet.condition_index{i} = str2double(strtrim(cond_index));
            
            
            datasheet.conditions = cellfun(@(x) strsplit(x, ' '), datasheet.conditions, 'UniformOutput', false);

        catch

        end
        
        try
            starts = strsplit(datasheet.start_conditions{i}, ' ');
            datasheet.start_conditions{i} = str2double(strtrim(starts)); 

        catch

        end
        
        % extra electrodes
        try
            datasheet.extra = cellfun(@(x) strsplit(x, ', '), datasheet.extra, 'UniformOutput', false);

        catch

        end


        % Convert the split strings to numbers and store them in a new array
        datasheet.files{i} = str2double(strtrim(index_files)); % Trim and convert to numbers
        
        if(strcmp(sheetName, 'EJP') || strcmp(sheetName, 'EJC'))
            index_logic =  strsplit(datasheet.temperature_ref_logic{i}, ' ');
            datasheet.temperature_ref_logic{i} = str2double(strtrim(index_logic)); 
        end
    end

    % Display the table with the numeric array column
    try
    datasheet.electrodes = cellfun(@(x) strsplit(x, ', '), datasheet.electrodes, 'UniformOutput', false);
    catch
    end
    disp(datasheet);


    if strcmp(sheetName, 'EJP') || strcmp(sheetName,'EJC')
        % Loop through each row and process removal_temperatures column
        for i = 1:height(datasheet)
            if ~isempty(datasheet.removal_temperatures{i})  % If there's any data in the removal_temperatures column
                % Remove the square brackets and split the data by semicolons
                temp_data = datasheet.removal_temperatures{i};
                temp_data = temp_data(2:end-1); % Remove the square brackets

                % Split the data into rows based on the semicolon separator
                rows = strsplit(temp_data, ';');

                % Initialize a temporary matrix to store the parsed data
                temp_matrix = [];

                % Loop through each row string and extract the numbers
                for j = 1:length(rows)
                    % Split each row by spaces and convert to numbers
                    temp_row = str2double(strsplit(strtrim(rows{j})));
                    temp_matrix = [temp_matrix; temp_row];  % Append the row to the matrix
                end

                % Store the matrix in the corresponding cell of the removal_temperatures column
                datasheet.removal_temperatures{i} = temp_matrix;
            else
                % If empty, leave as is (empty matrix)
                datasheet.removal_temperatures{i} = [];
            end
        end    
    end
    
    for i = 1:height(datasheet)
        if strcmp(sheetName, 'EJP')
            if ~isempty(datasheet.removal_area{i})
                area_data = datasheet.removal_area{i};
                area_data = area_data(2:end-1); % Remove the square brackets
                rows = strsplit(area_data, ';');
                area_matrix = [];
                % Loop through each row string and extract the numbers
                for j = 1:length(rows)
                    % Split each row by spaces and convert to numbers
                    area_row = str2double(strsplit(strtrim(rows{j})));
                    area_matrix = [area_matrix; area_row];  % Append the row to the matrix
                end

                % Store the matrix in the corresponding cell of the removal_temperatures column
                datasheet.removal_area{i} = area_matrix;
            end
        end
    end
    
    if sheetName ~= "FTHeart"
        split_conditions = cellfun(@(x) strsplit(x, ', '), datasheet.conditions, 'UniformOutput', false);
        datasheet.conditions = split_conditions; 
    end
    datasheet.notebook = string(datasheet.notebook); 
    datasheet.page = string(datasheet.page); 
    datasheet.acclimation = string(datasheet.acclimation); 
    
%     if strcmp(sheetName,'IV') 
%         datasheet.notebook = str2double(datasheet.notebook);
%         datasheet.Nsteps = str2double(datasheet.Nsteps);
%         datasheet.Nloop = str2double(datasheet.Nloop);
%     end
end
