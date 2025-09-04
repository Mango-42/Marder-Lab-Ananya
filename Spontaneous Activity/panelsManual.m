% Code to manually plot one of the figures I made in 1.5 hrs lol
%% Load data 
directoryName = "auto";
targetNotebook = 992;
targetPage = 44;
googleSheet = 'Real';
saveOn = 0; % change to 1 if you want to save plot

% can do a number, range (ie, [1 2 3 4]), range = 'full' for whole exp
% or range = 'roi' for files of interest only
range = "roi"; 

% returns 3 tables containing original data, cleaned data, and
% downsampled cleaned data that gets plotted
[d, d_c, d_d] = plotOverview(directoryName, targetPage, targetNotebook, googleSheet, saveOn, range);
%%
disp(d_d.Properties.VariableNames)
Vm1 = d_d.Vm1_d; % trace of Vm1
Vm3 = d_d.Vm3_d; % trace of Vm3
time = d_d.t_d; % time
pulse = d_d.Pulse_d; % input current / pulses
abfnum = d_d.abfNum_d;

files = unique(abfnum);
changes = [1, find(ischange(abfnum))];


figure()
t = tiledlayout(5, 2);

nexttile(t, 1)

i = 1;
localRangeVm = Vm1(changes(i):changes(i)+10000);
localTime = time(changes(1):changes(1)+10000);

plot(localTime, localRangeVm)
ylim([-80, -30])
xlim([0 10])
ylabel("11°C", "Rotation", 0, "FontSize",14)
title("Saline", "FontSize",14)

nexttile(t, 3)
i = 2;
localRangeVm = Vm1(changes(i):changes(i)+10000);
localTime = time(changes(1):changes(1)+10000);

plot(localTime, localRangeVm)
ylim([-80, -30])
xlim([0 10])
ylabel("16°C", "Rotation", 0, "FontSize",14)

nexttile(t, 5)
i = 3;
localRangeVm = Vm1(changes(i):changes(i)+10000);
localTime = time(changes(1):changes(1)+10000);

plot(localTime, localRangeVm)
ylim([-80, -30])
xlim([0 10])
ylabel("21°C", "Rotation", 0, "FontSize",14)

nexttile(t, 7)
i = 4;
localRangeVm = Vm1(changes(i):changes(i)+10000);
localTime = time(changes(1):changes(1)+10000);

plot(localTime, localRangeVm)
ylim([-80, -30])
xlim([0 10])
ylabel("11°C", "Rotation", 0, "FontSize",14)

% lvn
nexttile(t, 9)
localTime = time(changes(1):changes(1)+10000);
localPulse = pulse(changes(1):changes(1)+10000);
plot(localTime, localPulse)
xlim([0 10])
ylabel("lvn", "Rotation", 0, "FontSize",14)

% second column for CCAP
nexttile(t, 2)
i = 5;
localRangeVm = Vm1(changes(i):changes(i)+10000);
localTime = time(changes(1):changes(1)+10000);

plot(localTime, localRangeVm)
ylim([-80, -30])
xlim([0 10])
ylabel("11°C", "Rotation", 0, "FontSize",14)
title("CCAP 10^{-8}", "FontSize",14)

nexttile(t, 4)
i = 6;
localRangeVm = Vm1(changes(i):changes(i)+10000);
localTime = time(changes(1):changes(1)+10000);

plot(localTime, localRangeVm)
ylim([-80, -30])
xlim([0 10])
ylabel("16°C", "Rotation", 0, "FontSize",14)

nexttile(t, 6)
i = 7;
localRangeVm = Vm1(changes(i):changes(i)+10000);
localTime = time(changes(1):changes(1)+10000);

plot(localTime, localRangeVm)
ylim([-80, -30])
xlim([0 10])
ylabel("21°C", "Rotation", 0, "FontSize",14)

nexttile(t, 8)
i = 8;
localRangeVm = Vm1(changes(i):changes(i)+10000);
localTime = time(changes(1):changes(1)+10000);

plot(localTime, localRangeVm)
ylim([-80, -30])
xlim([0 10])
ylabel("11°C", "Rotation", 0, "FontSize",14)

% lvn
nexttile(t, 10)
localTime = time(changes(1):changes(1)+10000);
localPulse = pulse(changes(5):changes(5)+10000);
plot(localTime, localPulse)
xlim([0 10])
ylabel("lvn", "Rotation", 0, "FontSize",14)

%%
figure()
t = tiledlayout(3, 4);
localTime = time(changes(1):changes(1)+5000);

% 11 degrees saline
i = 5;
nexttile(t, 1)
localRangeVm = Vm1(changes(i):changes(i)+5000);
plot(localTime, localRangeVm)
xlim([0 5])
ylim([-80 -40])
ylabel("cpv6", "Rotation", 0, "FontSize",14)
title("11°C", "Rotation", 0, "FontSize",14)

nexttile(t, 5)
localRangeVm = Vm3(changes(i):changes(i)+5000);
plot(localTime, localRangeVm)

xlim([0 5])
ylabel("gm5b", "Rotation", 0, "FontSize",14)
ylim([-100, -60])

nexttile(t, 9)
localPulse = pulse(changes(i):changes(i)+5000);
plot(localTime, localPulse)
xlim([0 5])
ylabel("lvn", "Rotation", 0, "FontSize",14)
ylim([-1 1])

% 16 degrees saline
i = 6;
nexttile(t, 2)
localRangeVm = Vm1(changes(i):changes(i)+5000);
plot(localTime, localRangeVm)
xlim([0 5])
ylim([-80 -40])
title("16°C", "Rotation", 0, "FontSize",14)

nexttile(t, 6)
localRangeVm = Vm3(changes(i):changes(i)+5000);
plot(localTime, localRangeVm)
xlim([0 5])
ylim([-100, -60])


nexttile(t, 10)

localPulse = pulse(changes(i):changes(i)+5000);
plot(localTime, localPulse)
xlim([0 5])
ylim([-1 1])


% 21 degrees saline
i = 7;
nexttile(t, 3)
localRangeVm = Vm1(changes(i):changes(i)+5000);
plot(localTime, localRangeVm)
xlim([0 5])
ylim([-80 -40])
title("21°C", "Rotation", 0, "FontSize",14)

nexttile(t, 7)
localRangeVm = Vm3(changes(i):changes(i)+5000);
plot(localTime, localRangeVm)
xlim([0 5])
ylim([-100, -60])


nexttile(t, 11)
localPulse = pulse(changes(i):changes(i)+5000);
plot(localTime, localPulse)
xlim([0 5])
ylim([-1 1])


% 11 degrees saline
i = 8;
nexttile(t, 4)
localRangeVm = Vm1(changes(i):changes(i)+5000);
plot(localTime, localRangeVm)
xlim([0 5])
ylim([-80 -40])
title("11°C", "Rotation", 0, "FontSize",14)

nexttile(t, 8)
localRangeVm = Vm3(changes(i):changes(i)+5000);
plot(localTime, localRangeVm)
xlim([0 5])
ylim([-100, -60])


nexttile(t, 12)
localPulse = pulse(changes(i):changes(i)+5000);
plot(localTime, localPulse)
xlim([0 5])
ylim([-1 1])

set(findall(gcf,'-property','fontname'),'fontname','times')
set(findall(gcf,'-property','box'),'box','off')
