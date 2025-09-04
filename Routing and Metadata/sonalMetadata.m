NB = 970;
page = 103;

metadata(NB, page).condition = 'control';

metadata(NB, page).channels.lpn = 'Ex_6';
metadata(NB, page).channels.pyn = 'Ex_5';
metadata(NB, page).channels.pdn = 'Ex_4';
metadata(NB, page).channels.PD = 'Vm_1';
metadata(NB, page).channels.PY = 'Vm_4';
metadata(NB, page).channels.temp = 'Tmp';

metadata(NB, page).modulator='CCAP';
metadata(NB, page).cond{1}='10°C';
metadata(NB, page).cond{2}='20°C';
metadata(NB, page).files = [17 22 27 32 37 41 44 46 71 74 79 83 86 88 90 92];%baseline start is first number; follwed by starts of all doses and washout- numbers matching file idx not file name
metadata(NB, page).dose_names = { ...
        'Baseline', 'CCAP 1nM', 'CCAP 3nM', 'CCAP 10nM', 'CCAP 30nM', 'CCAP 100nM', ...
        'CCAP 300nM',  'Washout'};

%%
NB = 970;
page = 105;

metadata(NB, page).condition = 'control';
metadata(NB, page).folder = '970_105';

metadata(NB, page).channels.lpn = 'Ex_4';
metadata(NB, page).channels.lvn = 'Ex_6';
metadata(NB, page).channels.pdn = 'Ex_8';
metadata(NB, page).channels.PD = 'Vm_1';
metadata(NB, page).channels.PY = 'Vm_4';
metadata(NB, page).channels.LP = 'Vm_2';
metadata(NB, page).channels.temp = 'Temp';

metadata(NB, page).modulator='CCAP';
metadata(NB, page).cond{1}={'10°C'};
metadata(NB, page).cond{2}={'20°C'};
metadata(NB, page).files = [18 21 26 31 35 38 41 44 46 65 70 76 81 86 90 95 100 105];%baseline start is first number; follwed by starts of all doses and washout- numbers matching file idx not file name

metadata(NB, page).dose_names = { ...
        'Baseline','CCAP 1nM', 'CCAP 3nM', 'CCAP 10nM', 'CCAP 30nM', 'CCAP 100nM', ...
        'CCAP 300nM', 'CCAP 1μM', 'Washout'};
%%
NB = 970;
page = 106;

metadata(NB, page).condition = 'cold acclimated';

metadata(NB, page).channels.lpn = 'Ex_8';
metadata(NB, page).channels.pyn = 'Ex_6';
metadata(NB, page).channels.pdn = 'Ex_9';
metadata(NB, page).channels.LP = 'Vm_3';
metadata(NB, page).channels.temp = 'Temp';
metadata(NB, page).decentralized = 2;
metadata(NB, page).modulator='CCAP';
metadata(NB, page).cond{1}='10°C';
metadata(NB, page).cond{2}='20°C';
metadata(NB, page).files = [14 19 24 29 34 38 42 45 48 59 64 68 72 76 80 84 88 91];%baseline start is first number; follwed by starts of all doses and washout- numbers matching file idx not file name

metadata(NB, page).dose_names = { ...
        'Baseline', 'CCAP 1nM', 'CCAP 3nM', 'CCAP 10nM', 'CCAP 30nM', 'CCAP 100nM', ...
        'CCAP 300nM', 'CCAP 1μM', 'Washout'};
%%
NB = 970;
page = 107;

metadata(NB, page).condition = 'hot acclimated';

metadata(NB, page).channels.pyn = 'Ex_8';
metadata(NB, page).channels.pdn = 'Ex_7';
metadata(NB, page).channels.PD = 'Vm_1';
metadata(NB, page).channels.PY = 'Vm_4';
metadata(NB, page).channels.LP = 'Vm_2';
metadata(NB, page).channels.temp = 'Temp';
metadata(NB, page).decentralized = 4;
metadata(NB, page).modulator='CCAP';
metadata(NB, page).cond{1}='10°C';
metadata(NB, page).cond{2}='20°C';
metadata(NB, page).files= [15 20 25 30 34 37 39 41 43 59 63 69 74 79 84 87 89 91];%baseline start is first number; follwed by starts of all doses and washout- numbers matching file idx not file name

metadata(NB, page).dose_names = { ...
        'Baseline','CCAP 1nM', 'CCAP 3nM', 'CCAP 10nM', 'CCAP 30nM', 'CCAP 100nM', ...
        'CCAP 300nM', 'CCAP 1μM', 'Washout'};
%%
NB = 970;
page = 108;

metadata(NB, page).condition = 'cold acclimated';

metadata(NB, page).channels.lvn = 'Ex_5';
metadata(NB, page).channels.PD = 'Vm_1';
metadata(NB, page).channels.PY = 'Vm_4';
metadata(NB, page).channels.LP = 'Vm_3';
metadata(NB, page).channels.temp = 'Temp';
metadata(NB, page).decentralized = [];
metadata(NB, page).modulator='CCAP';
metadata(NB, page).cond{1}='10°C';
metadata(NB, page).cond{2}='20°C';
metadata(NB, page).files= [25 28 34 39 44 48 51 54 55 80 84 87 94 95 104 109 114 116];%baseline start is first number; follwed by starts of all doses and washout- numbers matching file idx not file name

metadata(NB, page).dose_names = { ...
        'Baseline','CCAP 1nM', 'CCAP 3nM', 'CCAP 10nM', 'CCAP 30nM', 'CCAP 100nM', ...
        'CCAP 300nM', 'CCAP 1μM', 'Washout'};
%%
NB = 970;
page = 109;

metadata(NB, page).condition = 'hot acclimated';

metadata(NB, page).channels.lvn = 'Ex_4';%threshold =0.06 but everything is in there; gastric obscures
metadata(NB, page).channels.pdn = 'Ex_8';%threshold =1
metadata(NB, page).channels.pyn = 'Ex_7';%threshold_map.pyn = [0.2, 0.5];gastric, py
metadata(NB, page).channels.temp = 'Temp';
metadata(NB, page).decentralized = [];
metadata(NB, page).modulator='CCAP';
metadata(NB, page).cond{1}='10°C';
metadata(NB, page).cond{2}='20°C';
metadata(NB, page).files= [3 9 14 19 23 27 30 32 33 54 59 64 69 73 77 80 82 84];%baseline start is first number; followed by starts of all doses and washout- numbers matching file idx not file name
metadata(NB, page).times_to_plot={'manual', [17 27; 2 12; 42 52; 14 24; 85 95; 20 30; 21 31; 43 53; 47 57]};
metadata(NB, page).dose_names = { ...
        'Baseline','CCAP 1nM', 'CCAP 3nM', 'CCAP 10nM', 'CCAP 30nM', 'CCAP 100nM', ...
        'CCAP 300nM', 'CCAP 1μM', 'Washout'};
%%
NB = 970;
page = 110;

metadata(NB, page).condition = 'cold acclimated';

metadata(NB, page).channels.lvn = 'Ex_9';%has all most likely, 0.045 for most; try to subtract pd, py
metadata(NB, page).channels.pdn = 'Ex_5';% 0.07
metadata(NB, page).channels.pyn = 'Ex_6';%0.08 has shorter lp 
metadata(NB, page).channels.temp = 'Temp';
metadata(NB, page).decentralized = [];
metadata(NB, page).modulator='CCAP';
metadata(NB, page).cond{1}='20°C';
metadata(NB, page).cond{2}='10°C';
metadata(NB, page).files= [1 6 11 35 16 20 23 26 28 43 49 54 59 64 69 73 76 78];%baseline start is first number; followed by starts of all doses and washout- numbers matching file idx not file name

metadata(NB, page).dose_names = { ...
        'Baseline','CCAP 1nM', 'CCAP 3nM', 'CCAP 10nM', 'CCAP 30nM', 'CCAP 100nM', ...
        'CCAP 300nM', 'CCAP 1μM', 'Washout'};
%%
NB = 970;
page = 111;

metadata(NB, page).condition = 'hot acclimated';

metadata(NB, page).channels.lvn = 'Ex_9';%biggest lp >py>pd
metadata(NB, page).channels.pdn = 'Ex_4';
metadata(NB, page).channels.pyn = 'Ex_8';%has short lp too
metadata(NB, page).channels.temp = 'Tmp';
metadata(NB, page).decentralized = 8;
metadata(NB, page).modulator='CCAP';
metadata(NB, page).cond{1}='20°C';
metadata(NB, page).cond{2}='10°C';
metadata(NB, page).files= [20 29 34 39 44 48 51 54 56 75 79 84 88 88 88 88 88];%baseline start is first number; followed by starts of all doses and washout- numbers matching file idx not file name

metadata(NB, page).dose_names = { ...
        'Baseline','CCAP 1nM', 'CCAP 3nM', 'CCAP 10nM', 'CCAP 30nM', 'CCAP 100nM', ...
        'CCAP 300nM', 'CCAP 1μM', 'Washout'};
%%
NB = 970;
page = 112;

metadata(NB, page).condition = 'hot acclimated';

metadata(NB, page).channels.lvn = 'Ex_4'; %pd and lpg
metadata(NB, page).channels.pdn = 'Ex_8';% cut off 1
metadata(NB, page).channels.pyn = 'Ex_6';%shorter py 0.05 and bigger lp 0.1
metadata(NB, page).channels.temp = 'Temp';
metadata(NB, page).decentralized = 2;
metadata(NB, page).modulator='CCAP';
metadata(NB, page).cond{1}='20°C';
metadata(NB, page).cond{2}='10°C';
metadata(NB, page).files= [24 31 36 41 46 49 51 53 55 65 73 77 81 85 89 92 95 97];%baseline start is first number; followed by starts of all doses and washout- numbers matching file idx not file name

metadata(NB, page).dose_names = { ...
        'Baseline','CCAP 1nM', 'CCAP 3nM', 'CCAP 10nM', 'CCAP 30nM', 'CCAP 100nM', ...
        'CCAP 300nM', 'CCAP 1μM', 'Washout'};
%%
NB = 970;
page = 113;

metadata(NB, page).condition = 'cold acclimated';

metadata(NB, page).channels.lvn = 'Ex_4'; %lp big
metadata(NB, page).channels.pyn = 'Ex_8';%has all 3 shorter py 0.05 and bigger lp 0.1
metadata(NB, page).channels.pdn = 'Ex_10';% clean 0.8
metadata(NB, page).channels.temp = 'Temp';
metadata(NB, page).decentralized = 4;
metadata(NB, page).modulator='CCAP';
metadata(NB, page).cond{1}='20°C';
metadata(NB, page).cond{2}='10°C';
metadata(NB, page).files= [20 27 31 35 39 43 46 48 50 56 62 67 71 75 78 81 83 85];%baseline start is first number; followed by starts of all doses and washout- numbers matching file idx not file name

metadata(NB, page).dose_names = { ...
        'Baseline','CCAP 1nM', 'CCAP 3nM', 'CCAP 10nM', 'CCAP 30nM', 'CCAP 100nM', ...
        'CCAP 300nM', 'CCAP 1μM', 'Washout'};
%%
NB = 970;
page = 114;

metadata(NB, page).condition = 'hot acclimated';

metadata(NB, page).channels.lpn = 'Ex_6'; %0.2
metadata(NB, page).channels.lvn = 'Ex_10'; %lp big, py small
metadata(NB, page).channels.pyn = 'Ex_8';%0.4
metadata(NB, page).channels.pdn = 'Ex_4';% clean 0.1
metadata(NB, page).channels.temp = 'Temp';

metadata(NB, page).decentralized = 5;
metadata(NB, page).modulator='CCAP';
metadata(NB, page).cond{1}='20°C';
metadata(NB, page).cond{2}='10°C';
metadata(NB, page).files= [36 41 46 51 55 59 62 64 66 86 92 97 101 105 109 112 114 116];%baseline start is first number; followed by starts of all doses and washout- numbers matching file idx not file name

metadata(NB, page).dose_names = { ...
        'Baseline','CCAP 1nM', 'CCAP 3nM', 'CCAP 10nM', 'CCAP 30nM', 'CCAP 100nM', ...
        'CCAP 300nM', 'CCAP 1μM', 'Washout'};
%%
NB = 970;
page = 115;

metadata(NB, page).condition = 'cold acclimated';

metadata(NB, page).channels.lpn = 'Ex_4'; %0.3
metadata(NB, page).channels.lvn = 'Ex_6';% py 0.05 and bigger lp 0.12
metadata(NB, page).channels.pdn = 'Ex_10';% clean 0.1
metadata(NB, page).channels.temp = 'Temp';

metadata(NB, page).decentralized = 6;
metadata(NB, page).modulator='CCAP';
metadata(NB, page).cond{1}='20°C';
metadata(NB, page).cond{2}='10°C';
metadata(NB, page).files= [32 41 46 51 56 61 65 68 71 80 86 91 96 101 106 111 116 119];%baseline start is first number; followed by starts of all doses and washout- numbers matching file idx not file name

metadata(NB, page).dose_names = { ...
        'Baseline','CCAP 1nM', 'CCAP 3nM', 'CCAP 10nM', 'CCAP 30nM', 'CCAP 100nM', ...
        'CCAP 300nM', 'CCAP 1μM', 'Washout'};
%%
NB = 970;
page = 116;

metadata(NB, page).condition = 'cold acclimated';

metadata(NB, page).channels.lvn = 'Ex_4'; %lp big 0.037; py 0.02
metadata(NB, page).channels.lpn = 'Ex_6'; %pd big 0.5, lp small 0.1 - easier to sort lp on this than anything else
metadata(NB, page).channels.pyn = 'Ex_10';%lp same size 
metadata(NB, page).channels.pdn = 'Ex_5';% clean 0.9
metadata(NB, page).channels.temp = 'Temp';
metadata(NB, page).decentralized = 6;
metadata(NB, page).modulator='CCAP';
metadata(NB, page).cond{1}='20°C';
metadata(NB, page).cond{2}='10°C';
metadata(NB, page).files= [26 35 40 45 48 51 53 55 56 72 77 81 85 89 92 95 97 99];%baseline start is first number; followed by starts of all doses and washout- numbers matching file idx not file name

metadata(NB, page).dose_names = { ...
        'Baseline','CCAP 1nM', 'CCAP 3nM', 'CCAP 10nM', 'CCAP 30nM', 'CCAP 100nM', ...
        'CCAP 300nM', 'CCAP 1μM', 'Washout'};
%%
NB = 970;
page = 114;

metadata(NB, page).condition = 'hot acclimated';

metadata(NB, page).channels.lvn = 'Ex_8'; %lp big 0.037; py 0.02
metadata(NB, page).channels.pyn = 'Ex_10';%lp same size 
metadata(NB, page).channels.pdn = 'Ex_6';% clean 0.9
metadata(NB, page).channels.temp = 'Temp';

metadata(NB, page).modulator='CCAP';
metadata(NB, page).cond{1}='20°C';
metadata(NB, page).cond{2}='10°C';
metadata(NB, page).decentralized = 2;
metadata(NB, page).files= [16 22 27 32 37 41 44 46 50 66 72 77 82 87 91 96 99 101];%baseline start is first number; followed by starts of all doses and washout- numbers matching file idx not file name

metadata(NB, page).dose_names = { ...
        'Baseline','CCAP 1nM', 'CCAP 3nM', 'CCAP 10nM', 'CCAP 30nM', 'CCAP 100nM', ...
        'CCAP 300nM', 'CCAP 1μM', 'Washout'};