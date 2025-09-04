Exp_no = 1;

dose_temp_metadata(Exp_no).condition = 'control';
dose_temp_metadata(Exp_no).folder = '970_103';

dose_temp_metadata(Exp_no).channels.lpn = 'Ex_6';
dose_temp_metadata(Exp_no).channels.pyn = 'Ex_5';
dose_temp_metadata(Exp_no).channels.pdn = 'Ex_4';
dose_temp_metadata(Exp_no).channels.PD = 'Vm_1';
dose_temp_metadata(Exp_no).channels.PY = 'Vm_4';
dose_temp_metadata(Exp_no).channels.temp = 'Tmp';

dose_temp_metadata(Exp_no).modulator='CCAP';
dose_temp_metadata(Exp_no).cond{1}='10°C';
dose_temp_metadata(Exp_no).cond{2}='20°C';
dose_temp_metadata(Exp_no).dose_starts = [17 22 27 32 37 41 44 46 71 74 79 83 86 88 90 92];%baseline start is first number; follwed by starts of all doses and washout- numbers matching file idx not file name
dose_temp_metadata(Exp_no).dose_names = { ...
        'Baseline', 'CCAP 1nM', 'CCAP 3nM', 'CCAP 10nM', 'CCAP 30nM', 'CCAP 100nM', ...
        'CCAP 300nM',  'Washout'};

%%
Exp_no = 2;

dose_temp_metadata(Exp_no).condition = 'control';
dose_temp_metadata(Exp_no).folder = '970_105';

dose_temp_metadata(Exp_no).channels.lpn = 'Ex_4';
dose_temp_metadata(Exp_no).channels.lvn = 'Ex_6';
dose_temp_metadata(Exp_no).channels.pdn = 'Ex_8';
dose_temp_metadata(Exp_no).channels.PD = 'Vm_1';
dose_temp_metadata(Exp_no).channels.PY = 'Vm_4';
dose_temp_metadata(Exp_no).channels.LP = 'Vm_2';
dose_temp_metadata(Exp_no).channels.temp = 'Tmp';

dose_temp_metadata(Exp_no).modulator='CCAP';
dose_temp_metadata(Exp_no).cond{1}={'10°C'};
dose_temp_metadata(Exp_no).cond{2}={'20°C'};
dose_temp_metadata(Exp_no).dose_starts = [18 21 26 31 35 38 41 44 46 65 70 76 81 86 90 95 100 105];%baseline start is first number; follwed by starts of all doses and washout- numbers matching file idx not file name

dose_temp_metadata(Exp_no).dose_names = { ...
        'Baseline','CCAP 1nM', 'CCAP 3nM', 'CCAP 10nM', 'CCAP 30nM', 'CCAP 100nM', ...
        'CCAP 300nM', 'CCAP 1μM', 'Washout'};
%%
Exp_no = 3;

dose_temp_metadata(Exp_no).condition = 'cold acclimated';
dose_temp_metadata(Exp_no).folder = '970_106';

dose_temp_metadata(Exp_no).channels.lpn = 'Ex_8';
dose_temp_metadata(Exp_no).channels.pyn = 'Ex_6';
dose_temp_metadata(Exp_no).channels.pdn = 'Ex_9';
dose_temp_metadata(Exp_no).channels.LP = 'Vm_3';
dose_temp_metadata(Exp_no).channels.temp = 'Tmp';

dose_temp_metadata(Exp_no).modulator='CCAP';
dose_temp_metadata(Exp_no).cond{1}='10°C';
dose_temp_metadata(Exp_no).cond{2}='20°C';
dose_temp_metadata(Exp_no).dose_starts = [14 19 24 29 34 38 42 45 48 59 64 68 72 76 80 84 88 91];%baseline start is first number; follwed by starts of all doses and washout- numbers matching file idx not file name

dose_temp_metadata(Exp_no).dose_names = { ...
        'Baseline', 'CCAP 1nM', 'CCAP 3nM', 'CCAP 10nM', 'CCAP 30nM', 'CCAP 100nM', ...
        'CCAP 300nM', 'CCAP 1μM', 'Washout'};
%%
Exp_no = 4;

dose_temp_metadata(Exp_no).condition = 'hot acclimated';
dose_temp_metadata(Exp_no).folder = '970_107';

dose_temp_metadata(Exp_no).channels.pyn = 'Ex_8';
dose_temp_metadata(Exp_no).channels.pdn = 'Ex_7';
dose_temp_metadata(Exp_no).channels.PD = 'Vm_1';
dose_temp_metadata(Exp_no).channels.PY = 'Vm_4';
dose_temp_metadata(Exp_no).channels.LP = 'Vm_2';
dose_temp_metadata(Exp_no).channels.temp = 'Tmp';

dose_temp_metadata(Exp_no).modulator='CCAP';
dose_temp_metadata(Exp_no).cond{1}='10°C';
dose_temp_metadata(Exp_no).cond{2}='20°C';
dose_temp_metadata(Exp_no).dose_starts= [15 20 25 30 34 37 39 41 43 59 63 69 74 79 84 87 89 91];%baseline start is first number; follwed by starts of all doses and washout- numbers matching file idx not file name

dose_temp_metadata(Exp_no).dose_names = { ...
        'Baseline','CCAP 1nM', 'CCAP 3nM', 'CCAP 10nM', 'CCAP 30nM', 'CCAP 100nM', ...
        'CCAP 300nM', 'CCAP 1μM', 'Washout'};
%%
Exp_no = 5;

dose_temp_metadata(Exp_no).condition = 'cold acclimated';
dose_temp_metadata(Exp_no).folder = '970_108';

dose_temp_metadata(Exp_no).channels.lvn = 'Ex_5';
dose_temp_metadata(Exp_no).channels.PD = 'Vm_1';
dose_temp_metadata(Exp_no).channels.PY = 'Vm_4';
dose_temp_metadata(Exp_no).channels.LP = 'Vm_3';
dose_temp_metadata(Exp_no).channels.temp = 'Tmp';

dose_temp_metadata(Exp_no).modulator='CCAP';
dose_temp_metadata(Exp_no).cond{1}='10°C';
dose_temp_metadata(Exp_no).cond{2}='20°C';
dose_temp_metadata(Exp_no).dose_starts= [25 28 34 39 44 48 51 54 55 80 84 87 94 95 104 109 114 118];%baseline start is first number; follwed by starts of all doses and washout- numbers matching file idx not file name

dose_temp_metadata(Exp_no).dose_names = { ...
        'Baseline','CCAP 1nM', 'CCAP 3nM', 'CCAP 10nM', 'CCAP 30nM', 'CCAP 100nM', ...
        'CCAP 300nM', 'CCAP 1μM', 'Washout'};
%%
Exp_no = 6;

dose_temp_metadata(Exp_no).condition = 'hot acclimated';
dose_temp_metadata(Exp_no).folder = '970_109';

dose_temp_metadata(Exp_no).channels.lvn = 'Ex_4';
dose_temp_metadata(Exp_no).channels.pdn = 'Ex_8';
dose_temp_metadata(Exp_no).channels.pyn = 'Ex_7';
dose_temp_metadata(Exp_no).channels.temp = 'Tmp';

dose_temp_metadata(Exp_no).modulator='CCAP';
dose_temp_metadata(Exp_no).cond{1}='10°C';
dose_temp_metadata(Exp_no).cond{2}='20°C';
dose_temp_metadata(Exp_no).dose_starts= [3 9 14 19 23 27 30 32 33 54 59 64 69 73 77 80 82 84];%baseline start is first number; followed by starts of all doses and washout- numbers matching file idx not file name

dose_temp_metadata(Exp_no).dose_names = { ...
        'Baseline','CCAP 1nM', 'CCAP 3nM', 'CCAP 10nM', 'CCAP 30nM', 'CCAP 100nM', ...
        'CCAP 300nM', 'CCAP 1μM', 'Washout'};
%%
Exp_no = 7;

dose_temp_metadata(Exp_no).condition = 'cold acclimated';
dose_temp_metadata(Exp_no).folder = '970_110';

dose_temp_metadata(Exp_no).channels.lvn = 'Ex_9';
dose_temp_metadata(Exp_no).channels.pdn = 'Ex_5';
dose_temp_metadata(Exp_no).channels.pyn = 'Ex_6';
dose_temp_metadata(Exp_no).channels.temp = 'Tmp';

dose_temp_metadata(Exp_no).modulator='CCAP';
dose_temp_metadata(Exp_no).cond{1}='20°C';
dose_temp_metadata(Exp_no).cond{2}='10°C';
dose_temp_metadata(Exp_no).dose_starts= [1 6 11 35 16 20 23 26 28 43 49 54 59 64 69 73 76 78];%baseline start is first number; followed by starts of all doses and washout- numbers matching file idx not file name

dose_temp_metadata(Exp_no).dose_names = { ...
        'Baseline','CCAP 1nM', 'CCAP 3nM', 'CCAP 10nM', 'CCAP 30nM', 'CCAP 100nM', ...
        'CCAP 300nM', 'CCAP 1μM', 'Washout'};
%%
Exp_no = 8;

dose_temp_metadata(Exp_no).condition = 'hot acclimated';
dose_temp_metadata(Exp_no).folder = '970_111';

dose_temp_metadata(Exp_no).channels.lvn = 'Ex_9';%biggest lp >py>pd
dose_temp_metadata(Exp_no).channels.pdn = 'Ex_4';
dose_temp_metadata(Exp_no).channels.pyn = 'Ex_8';%has short lp too
dose_temp_metadata(Exp_no).channels.temp = 'Tmp';

dose_temp_metadata(Exp_no).modulator='CCAP';
dose_temp_metadata(Exp_no).cond{1}='20°C';
dose_temp_metadata(Exp_no).cond{2}='10°C';
dose_temp_metadata(Exp_no).dose_starts= [20 29 34 39 44 48 51 54 56 75 79 84 88 88 88 88 88];%baseline start is first number; followed by starts of all doses and washout- numbers matching file idx not file name

dose_temp_metadata(Exp_no).dose_names = { ...
        'Baseline','CCAP 1nM', 'CCAP 3nM', 'CCAP 10nM', 'CCAP 30nM', 'CCAP 100nM', ...
        'CCAP 300nM', 'CCAP 1μM', 'Washout'};
%%
Exp_no = 9;

dose_temp_metadata(Exp_no).condition = 'hot acclimated';
dose_temp_metadata(Exp_no).folder = '970_112';

dose_temp_metadata(Exp_no).channels.lvn = 'Ex_4'; %pd and lpg
dose_temp_metadata(Exp_no).channels.pdn = 'Ex_8';% cut off 1
dose_temp_metadata(Exp_no).channels.pyn = 'Ex_6';%shorter py 0.05 and bigger lp 0.1
dose_temp_metadata(Exp_no).channels.temp = 'Tmp';

dose_temp_metadata(Exp_no).modulator='CCAP';
dose_temp_metadata(Exp_no).cond{1}='20°C';
dose_temp_metadata(Exp_no).cond{2}='10°C';
dose_temp_metadata(Exp_no).dose_starts= [24 31 36 41 46 49 51 53 55 65 73 77 81 85 89 92 95 97];%baseline start is first number; followed by starts of all doses and washout- numbers matching file idx not file name

dose_temp_metadata(Exp_no).dose_names = { ...
        'Baseline','CCAP 1nM', 'CCAP 3nM', 'CCAP 10nM', 'CCAP 30nM', 'CCAP 100nM', ...
        'CCAP 300nM', 'CCAP 1μM', 'Washout'};
%%
Exp_no = 10;

dose_temp_metadata(Exp_no).condition = 'cold acclimated';
dose_temp_metadata(Exp_no).folder = '970_113';

dose_temp_metadata(Exp_no).channels.lvn = 'Ex_4'; %lp big
dose_temp_metadata(Exp_no).channels.pyn = 'Ex_8';%has all 3 shorter py 0.05 and bigger lp 0.1
dose_temp_metadata(Exp_no).channels.pdn = 'Ex_10';% clean
dose_temp_metadata(Exp_no).channels.temp = 'Tmp';

dose_temp_metadata(Exp_no).modulator='CCAP';
dose_temp_metadata(Exp_no).cond{1}='20°C';
dose_temp_metadata(Exp_no).cond{2}='10°C';
dose_temp_metadata(Exp_no).dose_starts= [20 27 31 35 39 43 46 48 50 56 62 67 71 75 78 81 83 85];%baseline start is first number; followed by starts of all doses and washout- numbers matching file idx not file name

dose_temp_metadata(Exp_no).dose_names = { ...
        'Baseline','CCAP 1nM', 'CCAP 3nM', 'CCAP 10nM', 'CCAP 30nM', 'CCAP 100nM', ...
        'CCAP 300nM', 'CCAP 1μM', 'Washout'};