targetNotebook = 992;
targetPage = 90;
googleSheet = "Intact";
channel = 1;
thresh = -35;
peakProm = 5;

[i, j, d] = plotOverview("auto", targetPage, targetNotebook, googleSheet, 0, "full");
%%

targetNotebook = string(targetNotebook);
targetPage = string(targetPage);
notebook = str2double(targetNotebook); %str2double(datasheet.notebook{row});
page = str2double(targetPage); 


datasheet = import_googlesheet(googleSheet);

row = strcmp(datasheet.page, targetPage) & strcmp(datasheet.notebook, targetNotebook);

electrodes = datasheet.electrodes{row};

if channel == 1
    v = d.Vm1_d;
elseif channel == 2
    v = d.Vm2_d;
elseif channel == 3
    v = d.Vm3_d;
end

electrode = electrodes{channel};

t = d.t_d;
temp = d.Temp_d;


usable = getUsableData(t, v, thresh);

figure
subplot(4, 1, 1)
title(electrode + " Temp vs frequency " + targetNotebook + "_" + targetPage, 'Interpreter', 'none')

plot(t, temp)
ylabel("Temp (°C)")

subplot(4, 1, 2)
findpeaks(v, t, "MinPeakProminence", peakProm);
ylabel("Vm and peaks")


[peaks, loc] = findpeaks(v, "MinPeakProminence", peakProm);
spikes = zeros([1 length(v)]);
spikes(loc) = 1;
freq = movsum(spikes, 10000) / 10;

subplot(4, 1, 3)
scatter(t, freq)
ylabel("Frequency")
xlabel("Seconds")

subplot(4, 1, 4)
plot(t, usable)

allAxes = findall(gcf,'type','axes');
linkaxes(allAxes, 'x')

%%
% now you wanna grab frequency but only in the usable areas 
idxs = find(usable);
freqFiltered = freq(idxs);
timeFiltered = t(idxs);
tempMean = movmean(temp, 10000);
tempFiltered = tempMean(idxs);

%% fitting - quadratic

% % first fit with a and b parameters (some code copied from biol 107)
% s = fitoptions('Method','NonlinearLeastSquares',... % use squared error
%       'Lower',[-Inf,-Inf, -Inf],...   % lower bounds for [a b]
%       'Upper',[Inf,Inf, Inf],... % upper bounds for [a b]
%       'Startpoint',[1 1 0]); % startpoint, search will start at a=1,b=1,c=0
% 
% f = fittype('a*(x-b)^2 + c','options',s);
% 
% [c,gof] = fit(transpose(tempFiltered), transpose(freqFiltered),f);
% 
% x_values = 10:35;
% y_values = c(x_values); % applies the fit to x 

%% Plot temp vs freq

figure()

scatter(tempFiltered, freqFiltered)
hold on
xlabel("Temperature (°C)")
ylabel("Frequency (Hz)")
title(electrode + " Temp vs frequency " + targetNotebook + "_" + targetPage, 'Interpreter', 'none')

% 
% plot(x_values,y_values, 'k--',  LineWidth=1.5); % plot best fit 
ylim([0 Inf])
xlim([0 Inf])
%% Vrest

peaksLoc = loc;


% get the troughs (vrest) by using negative signal 
[rests, loc] = findpeaks(-v, 'MinPeakDistance',2000);
% check that the peak distance (in array units) is > than the lowest
% frequency you're generally seeing, but not too big, for good temporal resolution 
figure
findpeaks(-v, 'MinPeakDistance',2000);


% interpolate between the values of peaks you have
vq = interp1(loc,-rests,loc(1):loc(end));


% the updates are just to shrink to the range of the interpolation
usable(1:loc(1)) = 0;
usable(loc(end): end) = 0;

idxs = find(usable);

% now shrink to only the usable areas 
tempFinal = temp(idxs);
vFinal = v(idxs);
tFinal = t(idxs);
vmFinal = vq(idxs - loc(1));

% this plots vm across time
figure()
subplot(2, 1, 1)
title("Vrest over time")
plot(t/60, v)
ylabel("p1 voltage")
subplot(2, 1, 2)
scatter(tFinal / 60, vmFinal)
xlabel("Time (min)")
ylabel("p1 Vrest")


allAxes = findall(gcf,'type','axes');
linkaxes(allAxes, 'x')

%%
% this plots vm across temperature
figure()
scatter(temp(loc), -rests)

xlabel("Temperature (°C)")
ylabel("Resting membrane voltage")
title("Temperature vs Vrest")
%% lets finally plot peak height omggg

[~, ~, d] = plotOverview("auto", 54, 992, "Intact", 0, 1:5);
%%

tiledExperiment(992, 90, "Intact", 2, 0);

%%
figure
t = tiledlayout(2,2,'TileSpacing','none');

% Tile 1
nexttile
plot(rand(1,20))
title('Sample 1')

% Tile 2
nexttile
plot(rand(1,20))
title('Sample 2')

% Tile 3
nexttile
plot(rand(1,20))
title('Sample 3')

% Tile 4
nexttile
plot(rand(1,20))
title('Sample 4')