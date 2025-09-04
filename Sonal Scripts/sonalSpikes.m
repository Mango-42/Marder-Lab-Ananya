%%
figure
plot(extracted_data.LP{1})
hold on
plot(extracted_data.PD{1})
plot(extracted_data.PY{1})

spikesLP = spike_times.LP{1}



idxLP = ceil(spikesLP * 10000);

scatter(idxLP, extracted_data.LP{1}(idxLP))

%%
figure
hold on
for i = 58:75

    time = i * 120 +  1e-4 * (1:1200000);
    
    plot(time, data.PD{i}, 'k-')
end
% PD_ind = int64(PD_int * 10000);
% scatter(PD_spikes, data.PD{}(PD_ind))

%%
isi = diff(PD_int);
freq = 1./isi;
figure
scatter(PD_int(1:end-1), freq)