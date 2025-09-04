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
    end
    
    datasheet = webread(url_name, options);
    
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


    disp(datasheet)


    % Convert the comma-separated strings to numeric arrays
    for i = 1:height(datasheet)
        % Split the string by commas
        index_files = strsplit(datasheet.files{i}, ' ');
        if(strcmp(sheetName, 'EJP') || strcmp(sheetName, 'EJC')) % do not do this on real!!
            index_cond =  strsplit(datasheet.index_condition{i}, ' ');
            datasheet.index_condition{i} = str2double(strtrim(index_cond)); 
        end
        
        % Convert the split strings to numbers and store them in a new array
        datasheet.files{i} = str2double(strtrim(index_files)); % Trim and convert to numbers
        
        if(strcmp(sheetName, 'EJP') || strcmp(sheetName, 'EJC')) % do not do this on real!!
            index_logic =  strsplit(datasheet.temperature_ref_logic{i}, ' ');
            datasheet.temperature_ref_logic{i} = str2double(strtrim(index_logic)); 
        end
    end

    % Display the table with the numeric array column
    datasheet.electrodes = cellfun(@(x) strsplit(x, ', '), datasheet.electrodes, 'UniformOutput', false);
    if(strcmp(sheetName, 'Real'))
        datasheet.index_condition = cellfun(@(x) strsplit(x, ', '), datasheet.index_condition, 'UniformOutput', false);
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
    
    split_conditions = cellfun(@(x) strsplit(x, ', '), datasheet.conditions, 'UniformOutput', false);
    datasheet.conditions = split_conditions; 
    datasheet.notebook = string(datasheet.notebook); 
    datasheet.page = string(datasheet.page); 
    datasheet.acclimation = string(datasheet.acclimation); 
    
%     if strcmp(sheetName,'IV') 
%         datasheet.notebook = str2double(datasheet.notebook);
%         datasheet.Nsteps = str2double(datasheet.Nsteps);
%         datasheet.Nloop = str2double(datasheet.Nloop);
%     end
end
