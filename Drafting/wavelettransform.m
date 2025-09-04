load wecg
tm = 0:1/180:numel(wecg)*1/180-1/180;
plot(tm,wecg)
grid on
axis tight
title("Human ECG")
xlabel("Time (s)")
ylabel("Amplitude")

%%

figure
Fs = 10000;
v = data.PD{5}(1:10000);
[cfs,f] = cwt(data.PD{5},Fs);

time = 1/Fs * (0:10000 - 1);
imagesc(time,f,abs(cfs))
xlabel("Time (s)")
ylabel("Frequency (Hz)")
axis xy
clim([0.025 0.25])
title("CWT of ECG Data")

%%
figure
plot(data.pdn{1})


