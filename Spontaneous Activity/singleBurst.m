function [time, v11, v21] = singleBurst(datasheet, targetNotebook, targetPage, googleSheet, muscle)

    %% Description: helper function, gets data for a requested experiment at 11 and 21 C
    % just gets the right channels data from the gsheet lol its so minimal. 
    % i need this a lot so just made it a function

    % Inputs:
        % datasheet (tbl) - passed in from import_googlesheet.m output
        % targetNotebook (int) - page of notebook
        % targetPage (int) - page of experiment
        % googleSheet (str) - datasheet to look on
            % ie, 'EJP', 'EJC', 'Real' etc
        % muscle (str) - muscle, ie "gm5b"

    % Outputs:
        % time (double []) - matching timescale for voltage data
        % v11 (double []) - voltage trace at 11
        % v21 (double []) - voltage trace at 21

    % Dependencies
        % plotOverview.m
        % import_googlesheet.m

    % Last edited: Ananya Dalal Jun 16

%%
targetNB = string(targetNotebook);
targetP = string(targetPage);
fixedPage = sprintf('%03d',str2num(targetP));


% Find rows where the 'page' column matches 'targetPage'
row = strcmp(datasheet.page, targetP) & strcmp(datasheet.notebook, targetNB) ; % can switch to contains

% Display the rows where the page matches the target
notebook = str2double(targetNB); %str2double(datasheet.notebook{row});
page = str2double(targetP); 
electrodes = datasheet.electrodes{row};
RecordType = datasheet.experiment{row}; 
files = datasheet.files{row};
tempValues = datasheet.temperature_values{row};

% Get which file is flagged for 11 and 21 degrees
ind11 = find(tempValues==11, 1);
ind21 = find(tempValues==21, 1);
file11 = files(ind11);
file21 = files(ind21);

if isempty(file11) || isempty(file21)
    time = -1;
    v11 = -1;
    v21 = -1;
    return
end
[data11, ~, ~] = plotOverview("auto", targetPage, targetNotebook, googleSheet, 0, file11);

[data21, ~, ~] = plotOverview("auto", targetPage, targetNotebook, googleSheet, 0, file21);

%% Get electrode 

indElectrode = find(strcmp(electrodes, muscle));

if indElectrode == 1
    v11 = data11.Vm1;
    v21 = data21.Vm1;
elseif indElectrode == 2
    v11 = data11.Vm2;
    v21 = data21.Vm2;
elseif indElectrode == 3
    v11 = data11.Vm3;
    v21 = data21.Vm3;
end

time = data11.t - data11.t(1);
%% If you were using this independently of querySheet.m, you can plot by uncommenting the code below

% % Make the plot
% figure(100)
% t = tiledlayout(1, 2);
% title(t, "11 and 21 NB " + targetNB + " page " + targetP + " window = " + win + "s")
% 
% nexttile
% plot(time, v11, 'k-', LineWidth=1.5)
% set(gca,'xticklabel',[])
% ax = gca;
% ax.XColor = 'none';
% xlim([0, win])
% ylabel(muscle, Rotation=0)
% 
% nexttile
% plot(time, v21, 'k-', LineWidth=1.5)
% set(gca,'xticklabel',[])
% ax = gca;
% ax.XColor = 'none';
% xlim([0, win])
% 
% allAxes = findall(gcf,'type','axes');
% linkaxes(allAxes, 'y')
% 
% set(findall(gcf,'-property','fontname'),'fontname','arial')
% set(findall(gcf,'-property','box'),'box','off')
% set(findall(gcf,'-property','fontsize'),'fontsize',17)
% 
% prompt = "Make any edits and hit enter when done";
% x = input(prompt);
% 
% for i= 1:length(allAxes)
%     lims = get(allAxes(i),'XLim');
%      allAxes(i).XLim = [lims(1) lims(1) + win];
% end