function plot_dose_response_temp_traces_all(data, metadata, Exp_no, cells, t_start, t_end, how_many_files_to_end, do_denoise)
if nargin < 8
    do_denoise = false;
end
Fs = 1e4;
folder = metadata(Exp_no).folder;
condition_name = metadata(Exp_no).condition;
conds = metadata(Exp_no).cond;
dose_starts = metadata(Exp_no).dose_starts;
dose_labels = metadata(Exp_no).dose_names;

nCells = length(cells);
nTemps = length(conds);
nDoses = length(dose_starts)/2;
columns = ceil(nDoses); % Half doses per temperature

channels = cellfun(@(c) data.(c), cells, 'UniformOutput', false);
nFiles = size(channels{1}, 2);
dose_inds = [
    dose_starts(2:columns),         dose_starts(columns)+5;
    dose_starts(columns+2:end),     nFiles - how_many_files_to_end
    ];
time = t_start:1/Fs:t_end;

% Compute y-limits
ylims = zeros(nCells, 2);
for ci = 1:nCells
    all_segments = [];
    for temp_i = 1:nTemps
        for d = 1:columns
            file_i = dose_inds(temp_i,d);
            disp(t_start*Fs+1)
            disp(t_end*Fs+1)
            seg = channels{ci}{file_i}((t_start*Fs+1):(t_end*Fs+1));
            all_segments = [all_segments, seg];
        end
    end
    mean_val = mean(all_segments);
    std_val = std(all_segments);
    valid_data = all_segments(abs(all_segments - mean_val) <= 20*std_val);
    ylims(ci,:) = [min(valid_data), max(valid_data)];
end

% Prepare figure
figure('Name', 'Dose Response Traces', 'Units', 'normalized', 'Position', [0.05 0.05 0.85 0.85]);
% set(gcf, 'Color', 'none');  % Makes the figure background transparent
axHandles = cell(nCells * nTemps, columns);

% Plotting loop
for temp_i = 1:nTemps
    for ci = 1:nCells
        for d = 1:columns
            subplot_idx = (ci + (temp_i-1)*nCells - 1)*columns + d;
            ax = subtightplot(nCells * nTemps, columns, subplot_idx, [0.01 0.01], [0.02 0.06], [0.025 0.035]);
            axHandles{ci + (temp_i-1)*nCells, d} = ax;
            file_i = dose_inds(temp_i,d);
            trace = channels{ci}{file_i}((t_start*Fs+1):(t_end*Fs+1));
            if do_denoise
                trace = wdenoise(trace, 6); % Level 4 wavelet denoising (adjust as needed)
            end
            plot(time, trace, 'k', 'LineWidth', 1.4);
            % set(ax, 'Color', 'none');  % Makes subplot background transparent
            ylim(ax, ylims(ci,:));
            xlim([t_start, t_end]);
            axis off;

            if ci == 1 && temp_i == 1
                title(dose_labels{d}, 'Interpreter', 'none', 'FontSize', 20);
            end

            if d == 1
                text(-0.05, 0.5, cells{ci}, 'Units', 'normalized', ...
                    'FontSize', 25, 'HorizontalAlignment', 'right');
            end

            if ci == 1 && d == 1
                text(-.05, 0.97, conds{temp_i}, 'Units', 'normalized', ...
                    'FontSize', 20, 'FontWeight', 'bold');
            end
            if d == columns && ~contains(cells{ci}, 'n')
                y = ylims(ci,1);
                hold on
                % Vertical scale bar (5 mV)
                line([t_end, t_end], [y, y+5], 'color', 'k', 'LineWidth', 2);
                text(t_end+0.25, y+2.5, '5 mV', 'FontSize', 20);

                % Horizontal -40 mV line near bottom of plot
                % Choose the anchor voltage based on current y-limits
                if ylims(ci,1) <= -40 && ylims(ci,2) >= -40
                    anchor = -40;
                elseif ylims(ci,1) <= -50 && ylims(ci,2) >= -50
                    anchor = -50;
                elseif ylims(ci,1) <= -30 && ylims(ci,2) >= -30
                    anchor = -30;
                else
                    anchor = [];  % None visible
                end

                % Plot horizontal anchor line and label if within limits
                if ~isempty(anchor)
                    line([t_end-2.8, t_end-0.2], [anchor, anchor], ...
                        'LineStyle', '--', 'Color', [0.2 0.2 0.2], 'LineWidth', 1.5);
                    text(t_end-0.2, anchor, sprintf('%d mV', anchor), ...
                        'FontSize', 15, 'VerticalAlignment', 'top');
                end
            end

            if ci == nCells && temp_i == nTemps && d == columns
                y = ylims(ci,1);
                line([t_end-1, t_end], [y, y], 'color', 'k', 'LineWidth', 2);
                text(t_end-0.5, y - 0.05*(max(ylims(ci,:)) - min(ylims(ci,:))), '1 s', 'HorizontalAlignment', 'center', 'FontSize', 20);
            end
        end
    end
end


% % UI Panel for y-limit adjustment
% uicontrol('Style', 'text', 'String', 'Adjust Y-Limits for Cell:', ...
%     'Units', 'normalized', 'Position', [0.88 0.92 0.1 0.04], ...
%     'HorizontalAlignment', 'left', 'FontSize', 10);
% cell_menu = uicontrol('Style', 'popupmenu', 'String', cells, ...
%     'Units', 'normalized', 'Position', [0.88 0.88 0.1 0.04]);
% 
% uicontrol('Style', 'text', 'String', 'Y-min:', ...
%     'Units', 'normalized', 'Position', [0.88 0.83 0.05 0.03], ...
%     'HorizontalAlignment', 'left');
% ymin_box = uicontrol('Style', 'edit', 'String', num2str(ylims(1,1)), ...
%     'Units', 'normalized', 'Position', [0.93 0.83 0.05 0.03]);
% 
% uicontrol('Style', 'text', 'String', 'Y-max:', ...
%     'Units', 'normalized', 'Position', [0.88 0.79 0.05 0.03], ...
%     'HorizontalAlignment', 'left');
% ymax_box = uicontrol('Style', 'edit', 'String', num2str(ylims(1,2)), ...
%     'Units', 'normalized', 'Position', [0.93 0.79 0.05 0.03]);
% 
% uicontrol('Style', 'pushbutton', 'String', 'Apply', ...
%     'Units', 'normalized', 'Position', [0.89 0.74 0.08 0.04], ...
%     'Callback', @(src, event) updateYLimits());
% 
%     function updateYLimits()
%         idx = cell_menu.Value;
%         ymin = str2double(ymin_box.String);
%         ymax = str2double(ymax_box.String);
%         for temp_i = 1:nTemps
%             ax_group = axHandles{(idx + (temp_i-1)*nCells), :};
%             for d = 1:columns
%                 ylim(ax_group{d}, [ymin ymax]);
%             end
%         end
%     end
% Save
% setFigureSize(gcf, 1, 1);
% filename = sprintf('%s_%s_dose_response_traces', folder, condition_name);
% saveas(gcf, [filename '.tiff']);
% saveas(gcf, [filename '.png']);
% saveas(gcf, [filename '.pdf']);
end
