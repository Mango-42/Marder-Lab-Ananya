function spike_times = identify_spikes_extra(extracted_data, channel_map, thresholds, threshold_map)
Fs=10^4; %frequency of sampling
spike_times = struct();
chan_names = fieldnames(channel_map);

for i = 1:length(chan_names)
    ch = chan_names{i};
    targets = channel_map.(ch);
    trace_data = extracted_data.(ch);


    if isfield(extracted_data, 'cont_files')
        file_indices = extracted_data.cont_files;
    else
        file_indices = 1:length(trace_data);
    end

    for k = file_indices
        Vm = squeeze(trace_data{k}(:,:,1));

        [pks, locs] = findpeaks(Vm, 'MinPeakHeight', thresholds(i), ...
            'MinPeakDistance', Fs/50, 'MinPeakProminence', thresholds(i), 'MinPeakWidth', 8);
                    mu_pks = mean(pks);
            sigma = std(pks);
                    % Remove spikes that are outliers (mean ± 3*std)
            upper_limit= 2.6;
            % keep_idx = & pks < upper_limit;
            keep_idx =  pks > (mu_pks - 3*sigma) & pks < (mu_pks + 3*sigma) & pks < upper_limit;
            locs_clean = locs(keep_idx);
            pks_clean = pks(keep_idx);


        % Handle single vs multi target (e.g., LP and PY on pyn)
        if iscell(targets)
            % Multiple targets — split by amplitude thresholds
            thresholds = threshold_map.(ch);
            mask1 = pks > thresholds(1) & pks <= thresholds(2);
            mask2 = pks > thresholds(2);

            spike_times.(targets{1}){k} = locs(mask1);
            pks1= pks(mask1);
            pks2=pks(mask2);
            spike_times.(targets{2}){k} = locs(mask2);

            % Plot
            t = (1:length(Vm)) / Fs;
            clf; plot(t, Vm); hold on;
            plot(locs(mask1) / Fs, pks1, 'g.', 'MarkerSize', 5);
            plot(locs(mask2) / Fs, pks2, 'r.', 'MarkerSize', 5);
            title(sprintf('%s split into %s and %s', ch, targets{1}, targets{2}));

        else
            % One target — send all to one field
            spike_times.(targets){k} = locs_clean;

            t = (1:length(Vm)) / Fs;
            clf; plot(t, Vm); hold on;
            plot(locs_clean / Fs, pks_clean, 'r.', 'MarkerSize', 5);
            title(sprintf('%s -> %s', ch, targets));
        end

        pause
    end
end
end