function spike_times = identify_spikes_intra(extracted_data, channels, prom, upper_limit)

    if nargin < 3
        upper_limit = Inf; % No upper limit unless specified
    end
%%
spike_times = struct();
Fs=10^4;
for i = 1:length(channels)
    ch_name = channels{i};
    trace_data = extracted_data.(ch_name);
    base_name = erase(ch_name, '_intra');

    if isfield(extracted_data, 'cont_files')
        file_indices = extracted_data.cont_files;
    else
        file_indices = 1:length(trace_data);
    end

    for k = file_indices

        trace = squeeze(trace_data{k}(:,:,1));
        % 
        % Filter to extract oscillations
         [b,a]=butter(1,1/(Fs/2));%bandpass 0.01 to 5Hz to select only slow wave
         Vm = filter(b, a, trace);

        % baseline Vm detection using negative peaks
         [troughs, t_locs] = findpeaks(-Vm, 'MinPeakHeight',7, ...
             'MinPeakDistance', Fs/250, 'MinPeakProminence', 3);
         % [pks, locs] = findpeaks(trace,'MaxPeakWidth',200, 'MinPeakWidth',5,...
         %    'MinPeakDistance', Fs/250, 'MinPeakProminence',2.5);
                  [pks, locs,~,p] = findpeaks(trace,...
            'MinPeakDistance', Fs/250, 'MinPeakProminence',prom(i));
            mu_pks = mean(pks);
            sigma = std(pks);
                    % Remove spikes that are outliers (mean ± 3*std)
                    if ~isempty(troughs)
            mu = mean(troughs);
            thresh= 7;
                    else
                        mu=mean(-Vm);
                        thresh= 5;
                    end
            % keep_idx = & pks < upper_limit;
            keep_idx = pks > (-mu +thresh) & pks > (mu_pks - 3*sigma) & pks < (mu_pks + 15*sigma) & pks < upper_limit;
            locs_clean = locs(keep_idx);
            pks_clean = pks(keep_idx);

            spike_times.(base_name){k}(1,:) = p;
            % spike_times.(base_name){k}(2,:) = pks_clean;        
            % Plot
      
        % make_it_tight = true;
        % subplot = @(m,n,p) subtightplot(m, n, p, [0.01 0.01], [0.01 0.01], [0.01 0.01]);
        clf;
        % subplot(2,1,1) 
            figure
            t = (1:length(trace)) / Fs;
            plot(t, trace); hold on;
            plot(locs_clean / Fs, pks_clean, 'r.', 'MarkerSize', 6);

        % subplot(2,1,2)
        % t = (1:length(Vm)) / Fs;
        % plot(t, -Vm(1:end)); hold on;
        % % t_locs=t_locs(t_locs>5000);
        % plot(t_locs / Fs, troughs, 'r.', 'MarkerSize', 4);
        %set(gcf,'Position',[100 400 2600 900])
        title(sprintf('Intracellular: %s, File #%d', base_name, k));
        % pause
    end
end
end