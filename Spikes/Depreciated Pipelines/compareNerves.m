function [similarityScore] = compareNerves(nb1, p1, c1, nb2, p2, c2, metadata)

    % Description: Compare nerve activity between two animals
    % nb1 (int) - notebook for first animal
    % p1 (int) - page for first animal
    % c1 (cell arr) - condition - write as {temp (double), solution (str)}
    % nb2 (int) - notebook for second animal
    % p2 (int) - page for second animal
    % c2 (cell arr) - condition - write as {temp (double), solution (str)}

    % First collect data from the experiments 

    data1 = loadExperiment(nb1, p1, metadata);
    data2 = loadExperiment(nb1, p1, metadata);
    
    file1 = find(metadata(nb1, p1).tempValues == temp);
    file2 = find(metadata(nb2, p2).tempValues == temp);

    spikes1 = getSpikeTimes("auto", nb1, p1, 0);
    spikes2 = getSpikeTimes("auto", nb1, p1, 0);

    % fetch data window under certain condition

    % con1 = metadata(nb1, p1).conditions;
    % con2 = metadata(nb2, p2).conditions; 
    % conStart1 = metadata(nb2, p2).conStarts; 
    % conStart2 = metadata(nb2, p2).conStarts; 
    
    % % ugh something like this i dont know i copied this from tiledexp 
    % conditionByFiles = {};
    % c = 1;
    % for i = 1:length(files)
    % 
    %     if c+1 <= length(conditions) & starts(c+1) <= files(i)
    %         c = c + 1;
    %     end
    %     conditionByFiles{i} = conditions{c}; 
    % end
    availableNerves1 = fieldnames(spikes1);
    availableNerves2 = fieldnames(spikes1);
     % make sure to diff between labelling as neurons (LP, PD) vs (lvn, pdn)

    for nerve in nerves :

    % +1 because arrays start at 1 but abf indexing starts at 0
    v1 = data1.(nerve){file1 + 1};
    v2 = data2.(nerve){file2 + 1};

    spikeStorer1 = struct();
    spikeStorer1.(nerve) = spikes1.(nerve){file1 + 1};
    nerveStorer1 = struct();
    nerveStorer1.(nerve) = data1.(nerve){file1 + 1};
    

    [activity, robust] = burstActivity(spikeStorer1, nerve, vStorer1)
    

    % compare isi distributions 
    similarityScore = isiDistCompare(spikes1, spikes2);

    % get nerve state for each of the nerves that both the traces have 
    state1 = getNerveState(spikeTimes1, v1, "all"); % <-- update this to run for all states
    state2 = getNerveState(spikeTimes2, v2, "all");
    
    idxBursting1 = find(state1 == 1);
    idxBursting2 = find(state1 == 1);

    % get burst statistics on burst regions
    [a1, r1] = burstAnalysis(spikes1, "all", v1(idxBursting1));
    [a2, r2] = burstAnalysis(spikes2, "all", v1(idxBursting1));

    % BURSTING SIMILARITY = similarityScore(1) * ba1 - ba2
    % obviously not that simple lol 

    end




    



