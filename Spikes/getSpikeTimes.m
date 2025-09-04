function [splitSpikes] = getSpikeTimes(crabsortPath, targetNotebook, targetPage, range)
    %% Description: adapted from condenseSpikeTimes.m in basic analysis code 
    % in the lab google drive. 

    % Requires that you've already sorted spikes for the
    % experiment. Will not work on 2024 matlab. 

    % Made significant edits so that it doesnt assume data alignment and
    % instead works with makeContinous

    % Inputs:
        % crabsortPath (str) - general folder containing different exp crabsorts
            % can default to "auto" for ananya's crabsorts
        % targetNotebook (int) - page of notebook
        % targetPage (int) - page of experiment


    % Outputs:
        % spikeTimes (structure) - contains fields storing arrays with
            % spike times on different nerves. Field names are things
            % like "LP", "PD", etc

    % Last edited: Ananya Dalal Jun 16
%% Get spike times (adapted from condenseSpikeTimes.m)

if crabsortPath == "auto"
    % i still cant figure out sprintf lmao
    if targetPage < 10
        folderid = "/Users/ananyadalal/Documents/MATLAB/tools/Marder/Crabsorts/" + targetNotebook + "_" + "00" + targetPage;
    elseif targetPage < 100
        folderid = "/Users/ananyadalal/Documents/MATLAB/tools/Marder/Crabsorts/" + targetNotebook + "_" + "0" + targetPage;
    else
        folderid = "/Users/ananyadalal/Documents/MATLAB/tools/Marder/Crabsorts/" + targetNotebook + "_" + targetPage;
    end
else 
    folderid = crabsortPath;
end

fids = dir(folderid);
elapsedTime = 0;

LP = [];
PD = [];
PY = [];

spikeTimes = struct();

filenum = 1;


metadataMaster
if isequal(range, "roi")
    files = metadata(targetNotebook, targetPage).tempFiles;
elseif isequal(range, "crash");
    [~, idxMax] = max(metadata(targetNotebook, targetPage).tempValues);
    fileCrash = metadata(targetNotebook, targetPage).tempFiles(idxMax);
    fileBefore = fileCrash - 2;
    files = fileBefore:fileCrash;
end

% load in spikes 
for  numFile = files % for all the files in our data set...

    filename = sprintf('%s/%d_%03d_%04d.abf.crabsort', folderid, targetNotebook, targetPage, numFile);
             
         load(filename,'-mat'); % save the data from the abf file
     
        try 
        next_LP = ...
                crabsort_obj.spikes.lvn.LP*1e-4; %+ elapsedTime;
            
        catch % catch files where there are no spikes
            % check if it is actually on lpn
            try
                next_LP = ...
                crabsort_obj.spikes.lpn.LP*1e-4; %+ elapsedTime;
            catch
            next_LP = []; 
            end
        end 

        try
         next_PD = ...
             crabsort_obj.spikes.pdn.PD*1e-4; %+ elapsedTime;
        catch
            next_PD = [];
        end

        try
         next_PY = ...
             crabsort_obj.spikes.pyn.PY*1e-4; %+ elapsedTime;
        catch
            next_PY = [];
        end

        try
         next_LG = ...
             crabsort_obj.spikes.lgn.LG*1e-4; %+ elapsedTime;
        catch
            next_LG = [];
            disp("bruh")
        end


       if issorted(next_LP) == 0
        warning("LP spikes not in sorted order. Sorting spikes in time order.")
            next_LP = sort(next_LP);
       end
       
       if issorted(next_PD) == 0
        warning("PD spikes not in sorted order. Sorting spikes in time order.")
            next_PD = sort(next_PD);
       end

       if issorted(next_PY) == 0
        warning("PY spikes not in sorted order. Sorting spikes in time order.")
            next_PY = sort(next_PY);
       end

        if issorted(next_LG) == 0
        warning("LG spikes not in sorted order. Sorting spikes in time order.")
            next_LG = sort(next_LG);
        end

       % Check if there's anything to even store
       if ~isempty(next_LP)
           splitSpikes.LP{filenum} = next_LP;
       end

       if ~isempty(next_PD)
           splitSpikes.PD{filenum} = next_PD;
       end

       if ~isempty(next_PY)
           splitSpikes.PY{filenum} = next_PY;
       end

       if ~isempty(next_LG)
           splitSpikes.LG{filenum} = next_LG;
       end
       
       
    filenum = filenum + 1;

end