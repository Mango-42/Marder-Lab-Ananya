% Parameters are targetNotebook, targetPage, google sheet (will only work
% with intact for now), window size in seconds, and whether to save plot)

% Will have 2 stages in plotting: first lets you adjust x axis on any of
% the columns, so you can pick cool regions. Then lets you zoom in on a specific y range
    % in case the electrode popped out or smth and your trace is tiny

tiledExperiment(992, 44, 'Intact', 2.5, 0)

%%

[d, dc, dd] = plotOverview("auto", 44, 992, "Intact", 0, "full")


%%
Fs = 1000;            % Sampling frequency                    
T = 1/Fs;             % Sampling period       
L = length(dd.t_d);             % Length of signal
t = dd.t_d(2:end);        % Time vector

s = dd.Vm3_d(2:end);
%% 1st attempt using a spectrogram -- didn't like this!

figure
subplot(2, 1, 1)
spectrogram(s,10000,7000,100,Fs,'yaxis')
colormap hot
subplot(2, 1, 2)
plot(t/60, s)

allAxes = findall(gcf,'type','axes');
linkaxes(allAxes, 'x')



%% 2nd attempt using find peaks

figure


plot(t/60, s, 'k-')
hold on
findpeaks(s, 'MinPeakDistance', 10);

%%

ss = smoothdata(s, 'movmean', 500);

figure 
plot(t/60, s, 'k-')

%%
in = dd.Pulse_d(2:end);
figure
plot(t, in)

%%
figure
plot(t, smoothdata(in, L, "loess", 1000))
hold on
plot(t, in)

%%

figure
ff = fft(in);
x =  1000 * (1:length(t)) / L;
plot(x, ff)

%%

x = 0:.01:50;
y = sin(2 * pi * x * 15) + cos(2 * pi * x * 10);

ff = fft(y);

freq = 100 * (1:length(x)) /length(x);
figure
plot(freq, abs(ff))

%%


x = dd.t_d(3000*60: 3500*60);
y = dd.Vm3_d(3000*60:3500*60);

figure
findpeaks(dd.Vm1_d, "MinPeakProminence",5)

%%

figure
plot(x, y)

ff = fft(y);

figure
freq = 1000 * (1:length(x)) /length(x);

ff(1:3) = 0;
plot(freq, abs(ff))
xlim([0 100])




%% where you left off
% tried spectrograms, didn't look so good. tried fft and that seemed
% promising but you need to extract the max of fft region wise and then
% plot over time. Some kind of fft over a moving avg. Remember to subtract
% out a false signal that's v close to 0 Hz, that's just noise or sampling
% possibly. So basically track max fft frequency detected over time and
% then overlay temp and conditions. Woo. then split conditions, find avg in
% each condition window and see if significantly different. You also want
% something that detects when the temperature has changed so you can create
% time bins Maybbbbe??? but you want continuous data so like idk shrug. If
% you want to work on the nerve signal then i would smooth out the signal
% first before fft. why can't you just fft it though lol to find pyloric?
% that should be the most dominant freq........ and split by windows as
% long as you are getting enough oscillations -- ie, window size needs to
% change depending on whether you're looking at spike freq vs burst freq. 

%%
figure

%%

figure

subplot(2, 1, 1)
findpeaks(dd.Vm1_d, "MinPeakProminence", 5);
spikes = zeros([1 length(dd.Vm1_d)]);
spikes(loc) = 1;
avg = 10000 * movmean(spikes, 10000);


subplot(2, 1, 2)
plot(dd.t_d, avg)

allAxes = findall(gcf,'type','axes');
linkaxes(allAxes, 'x')


%%
tiledExperiment(992, 54, 'Intact', 2, 0)
%%
[i, j, d] = plotOverview("auto", 90, 992, "Intact", 0, 0:15)

%% points of confusion: 
% what why are the Vm channels orders different. the tiled starts with Gm6
% and oh i rotated them didn't i. bruh. lmao. ok we good i just need to
% flip order. 

%%

figure
subplot(3, 1, 1)
plot(d.t_d, d.Temp_d)
ylabel("Temp")

subplot(3, 1, 2)
findpeaks(d.Vm1_d, d.t_d, "MinPeakProminence", 5);
ylabel("Vm and peaks")
[peaks, loc] = findpeaks(d.Vm1_d, "MinPeakProminence", 5);
spikes = zeros([1 length(d.Vm1_d)]);
spikes(loc) = 1;
avg = movsum(spikes, 10000) / 10;



subplot(3, 1, 3)
scatter(d.t_d, avg)
ylabel("Frequency")
xlabel("Seconds")

allAxes = findall(gcf,'type','axes');
linkaxes(allAxes, 'x')

%% filter for usable regions (electrode hasn't popped out or muscle didn't contract)

figure

subplot(2, 1, 1)
plot(d.t_d / 60, d.Vm1_d)

avgVals = movmean(d.Vm1_d, 10000);
useable = find(avgVals < -35);
f1 = zeros([1, length(d.t_d)]);
f1(useable) = 1;
f2 = f1;

subplot(2, 1, 2)
plot(d.t_d / 60, f1, 'b')



% all valid regions must be > 2 minutes, otherwise more likely to be sus
changes = ischange(f1);
changes = find(changes);

for i = 1:length(changes) - 1

    % changing from invalid to valid, if between the switchover there's
    % less than 2 min of valid signal between two switch points --> invalid
    if f1(changes(i)) == 1 && sum( f1(changes(i):changes(i+1)) ) < 120000 
       f2(changes(i):changes(i+1)) = 0;
    end
end


hold on
plot(d.t_d / 60, f2, 'r')


allAxes = findall(gcf,'type','axes');
linkaxes(allAxes, 'x')


%% Some testing for frequency quantificationex

[i, j, d] = plotOverview("auto", 96, 992, "Intact", 0, "full")
%%
v = d.Vm2_d;
t = d.t_d;
temp = d.Temp_d;


usable = getUsableData(t, v, -35);


figure
subplot(4, 1, 1)
plot(t, temp)
ylabel("Temp")

subplot(4, 1, 2)
findpeaks(v, t, "MinPeakProminence", 5);
ylabel("Vm and peaks")


[peaks, loc] = findpeaks(v, "MinPeakProminence", 5);
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

figure()

scatter(tempFiltered, freqFiltered)
xlabel("Temperature")
ylabel("Frequency")

% probabyl want to add some buffer -- 10 s around a transition should be
% unusable too just for clarity reasons :thumbs up:? 

%% fitting? 


% first fit with a and b parameters (some code copied from biol 107)
s = fitoptions('Method','NonlinearLeastSquares',... % use squared error
      'Lower',[-Inf,-Inf],...   % lower bounds for [a b]
      'Upper',[Inf,Inf],... % upper bounds for [a b]
      'Startpoint',[1 1]); % startpoint, search will start at a=1,b=1

f = fittype('a*(x-b)^2','options',s);

[c,gof] = fit(transpose(tempFiltered), transpose(freqFiltered),f);

x_values = 10:35;
y_values = c(x_values); % this returns c evaluated with best a, b

%%
hold on
plot(x_values,y_values, 'k--',  LineWidth=1.5);


%%

expAnalysis(992, 90, 'Intact', 1, 5, -35)

%%

v = d.Vm1_d;
t = d.t_d;
temp = d.Temp_d;
%%
figure
[peaks, loc] = findpeaks(-v, t, "MinPeakDistance", 5);


usable * 1:size(v)
rests = NaN(size(v));
locs = locs ()

%%


loc = islocalmin(v, "MinSeparation", 100);
%%
[peaks, loc] = findpeaks(-v, 'MinPeakDistance',2000);
figure
findpeaks(-v, 'MinPeakDistance',2000);



testArr = ones(size(v));
testArr(loc) = peaks;

% interpolate between the values of peaks you have
vq = interp1(loc,peaks,loc(1):loc(end), "spline");
%%
usable = getUsableData(t, v, -40);
usableUpdate = usable(loc(1):loc(end));
idxs = find(usable);
vUpdate = v(loc(1):loc(end));
tUpdate = t(loc(1):loc(end));
tempUpdate = temp(loc(1):loc(end));


tempFinal = tempUpdate(idxs);
vFinal = vUpdate(idxs);
tFinal = tUpdate(idxs);
vmFinal = vq(idxs);

figure()
subplot(2, 1, 1)
plot(t, v)
subplot(2, 1, 2)
scatter(tFinal, vmFinal)

allAxes = findall(gcf,'type','axes');
linkaxes(allAxes, 'x')

%%
usableLoc = times(usable, loc);
usableLoc = find(usableLoc);

vUsable = v(usableLoc);

figure
plot(usableLoc, vUsable)

%%
tiledExperiment(992, 63, "Intact", 2, 0)
%%
figure
plot(1:10, rand(10))
set(gca,'linewidth',6)

%%
data1 = expAnalysis(992, 50, "Intact", "p1", 3, -35, 11:42);

%% redo

data2 = expAnalysis(992, 58, "Intact", "p1", 3, -35, 7:29);

%%

data3 = expAnalysis(992, 84, "Intact", "p1", 3, -35, 13:23);

%%
figure
hold on

scatter(data2.temp, data2.freq)
scatter(data3.temp, data3.freq)
xlim([10 inf])
xlabel("Temperature (°C)")
ylabel("Frequency (Hz)")
title("p1 frequency")
set(findall(gcf,'-property','fontname'),'fontname','arial')
set(findall(gcf,'-property','box'),'box','off')
set(findall(gcf,'-property','fontsize'),'fontsize',17)

%%

figure
hold on
% scatter(data1.temp, data1.peaks - data1.rest)
scatter(data2.temp, data2.peaks - data2.rest)
scatter(data3.temp, data3.peaks - data3.rest)
xlim([10 inf])
xlabel("Temperature (°C)")
ylabel("Amplitude (mV)")
title("p1 amplitude")
set(findall(gcf,'-property','fontname'),'fontname','arial')
set(findall(gcf,'-property','box'),'box','off')
set(findall(gcf,'-property','fontsize'),'fontsize',17)

%%

figure
hold on
% scatter(data1.temp, data1.rest)
scatter(data2.temp, data2.rest)
scatter(data3.temp, data3.rest)
xlim([10 inf])
xlabel("Temperature (°C)")
ylabel("V rest (mV)")
title("p1 V rest")
set(findall(gcf,'-property','fontname'),'fontname','arial')
set(findall(gcf,'-property','box'),'box','off')
set(findall(gcf,'-property','fontsize'),'fontsize',17)

%%
data4 = expAnalysis(992, 63, "Intact", "p2", 3, -35, 59:83);
data5 = expAnalysis(992, 96, "Intact", "p2", 3, -35, 1:17);

%%
figure
hold on

scatter(data4.temp, data4.freq)
scatter(data5.temp, data5.freq)
xlim([10 inf])
xlabel("Temperature (°C)")
ylabel("Frequency (Hz)")
title("p2 frequency")
set(findall(gcf,'-property','fontname'),'fontname','arial')
set(findall(gcf,'-property','box'),'box','off')
set(findall(gcf,'-property','fontsize'),'fontsize',17)


%%

figure
hold on
% scatter(data1.temp, data1.peaks - data1.rest)
scatter(data4.temp, data4.peaks - data4.rest)
scatter(data5.temp, data5.peaks - data5.rest)
xlim([10 inf])
xlabel("Temperature (°C)")
ylabel("Amplitude (mV)")
title("p2 amplitude")
set(findall(gcf,'-property','fontname'),'fontname','arial')
set(findall(gcf,'-property','box'),'box','off')
set(findall(gcf,'-property','fontsize'),'fontsize',17)

%%

figure
hold on
% scatter(data1.temp, data1.rest)
scatter(data4.temp, data4.rest)
scatter(data5.temp, data5.rest)
xlim([10 inf])
xlabel("Temperature (°C)")
ylabel("V rest (mV)")
title("p2 V rest")
set(findall(gcf,'-property','fontname'),'fontname','arial')
set(findall(gcf,'-property','box'),'box','off')
set(findall(gcf,'-property','fontsize'),'fontsize',17)

%% giving up on crabsort :')

[data, ~, ~] = plotOverview("auto", 58, 992, "Intact", 0, 0:37);

%%
lvn = data.In_d;
lvn = abs(lvn);
figure
subplot(2, 1, 1)
plot(data.t_d, data.Temp_d)
subplot(2, 1, 2)
plot(data.t_d, movmean(lvn, 100))
%findpeaks(lvn, data.t_d, "MinPeakDistance", .250)
allAxes = findall(gcf,'type','axes');
linkaxes(allAxes, 'x')

%%

temps = i.Temp(int64(PD * 10000));
%%

freq = 1./isi(1:end);
figure
scatter(temps,freq)

xlabel("Temperature (°C)")
ylabel("PD frequency (Hz)")
title("Temp vs PD frequency")

set(findall(gcf,'-property','fontname'),'fontname','arial')
set(findall(gcf,'-property','box'),'box','off')
set(findall(gcf,'-property','fontsize'),'fontsize',17)

%%

[data, ~, ~] = plotOverview("auto", 58, 992, "Intact", 0, "full");
%%
figure()
pd = data.In6(int64(PD * 10000)); % basically just checking these peaks are legit...
subplot(3, 1, 1)
hold on
plot(data.t, data.In6)
scatter(PD, pd)
%%



%%
temp = data.Temp(int64(LP * 10000));
isiLP = diff(LP);
temp = temp(1:end - 1);

freq = 1./isiLP(1:end);
figure
scatter(temp,freq)

xlabel("Temperature (°C)")
ylabel("LP frequency (Hz)")
title("Temp vs LP frequency")
% hold on
% 
% 
% temp = data.Temp(int64(PD * 10000));
% isiPD = diff(PD);
% temp = temp(1:end - 1);
% 
% freq = 1./isiPD(1:end);
% scatter(temp,freq);



%% getting lvn burst frequency thumbs up
burstStartTimes = [];
nerve = LP;
isi = diff(nerve);
sum = 0;

% detecting the starts of bursts
for i = 2:length(isi)
    
    if 8 * isi(i) < isi(i - 1)
        burstStartTimes = [burstStartTimes; nerve(i)];
    end
end



figure

lvn = data.In6(int64(LP * 10000)); % basically just checking these peaks are legit...

plot(data.t, data.In6)
hold on
% this should show all the spikes detected
scatter(LP, lvn)


scatter(burstStartTimes, data.In6(int64(burstStartTimes * 10000)))
allAxes = findall(gcf,'type','axes');
linkaxes(allAxes, 'x')

%%

temp = data.Temp(int64(burstStartTimes * 10000));
isiBursts = diff(burstStartTimes);
temp = temp(1:end - 1);

freq = 1./isiBursts;
figure
scatter(temp,freq);
%%
[data, ~, dataD] = plotOverview("auto", 54, 992, "Intact", 0, 11:28)

%%
figure
subplot(2, 1, 1)
plot(dataD.t_d, dataD.Vm1_d)

changes = ischange(dataD.Vm1_d, "mean", Threshold=1000);
subplot(2, 1, 2)
plot(dataD.t_d(idxRest), vRest)

allAxes = findall(gcf,'type','axes');
linkaxes(allAxes, 'x')
%%
idxChanges = find(changes);

timeBetweenChanges = diff(idxChanges);
% at least 3 seconds of time between "changes" (spikes)
idxLongRests = find(timeBetweenChanges > 3000);

t1 = idxChanges(idxLongRests) + 1000;
t2 = idxChanges(idxLongRests + 1) - 1000;

idxRest = [];
vRest = [];
for i = 1:length(t1)
    % add the time values for which there's at least 2.5 sec of rest

    idxRest = [idxRest, t1(i):t2(i)];
    meanVal = mean(dataD.Vm1_d(t1(i):t2(i)));
    vRest = [vRest, ones([1 (t2(i)-t1(i) + 1)]) * meanVal];

end

%%
vrests = interp1(idxRest, vRest, idxRest(1):idxRest(end));
time = dataD.t_d(idxRest(1):idxRest(end));
%%

plotOverview("auto", 8, 993, "Intact", 0, 30:32)

%%
tiledExperiment(993, 8, 10, 0)