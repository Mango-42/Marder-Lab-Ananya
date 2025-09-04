targetNotebook = 992;
targetPage = 58;

data = loadExperiment(targetNotebook, targetPage, "crash");
spikes = getSpikeTimes("auto", 992, 58, "crash");
[activity] = loadBurstStats(992, 58, "crash");

data = makeContinuous(data, 0);
figure
subplot(3, 1, 1)
plot(data.t, data.temp)
subplot(3, 1, 2)
plot(data.t, data.lvn)


allAxes = findall(gcf,'type','axes');
linkaxes(allAxes, 'x')
%%

stgCrashes = [26 31.5 32 24 33 33.8];
heartCrashes = [27 30 28 26 23 27];

figure
scatter(stgCrashes, heartCrashes, 70, "black", 'filled')
ylabel("Heart crash temperature (°C)")
xlabel("STG crash temperature (°C)")
ylim([20 35])
xlim([20 35])
hold on
plot([20 35], [20 35], 'k--')
set(findall(gcf,'-property','fontname'),'fontname','times')
set(findall(gcf,'-property','box'),'box','off')
set(findall(gcf,'-property','fontsize'),'fontsize',20)

%%