function [freq,spike_times_min] = plot_inst_freq(spike_times,color)

%Takes an array of spiketimes (in seconds) and creates a plot of the instant
%frequency over experimental time in minutes

isi = diff(spike_times); %finds the amount of time (in s) between each spike

freq = 1./isi; %calculates the instantaneous frequency in Hz (1/isi)

spike_times_min = spike_times./60; %divide spike times by 60 to get time in minutes

spike_times_min = spike_times_min(1:end-1); 
%cut one value off the end of spike times so that the freq array size matches

%plot the result
figure
scatter(spike_times_min,freq,color); %plots a blue 'o' for the frequency at each spike time
hold on;
box off;
set(gca,'Fontsize',30');
ylabel('Frequency (Hz)'); % relabel the y axis with specific cell that the frequency is calculated from
xlabel('Time (min)');

end