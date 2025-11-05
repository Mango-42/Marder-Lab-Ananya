function [condition]  = getCondition(nb, page, myFiles)

    % file can be a series of files 
    metadata = metadataMaster;
    

    files = metadata(nb, page).files;
    files = files(1):files(end); % cont ramp files
    c = metadata(nb, page).conditions;

    starts = metadata(nb, page).conditionStarts; % or doseStarts

    fileCondition = {};

    conIdx = 1;
    for i = 1:length(files)
        if length(starts) > conIdx && files(i) >= starts(conIdx+1)
            conIdx = conIdx + 1;
        end
        
        fileCondition{i} = c{conIdx};

    end
    fileCondition = string(fileCondition);
    fileCondition = string(fileCondition);



    condition =  fileCondition(myFiles - files(1) + 1);