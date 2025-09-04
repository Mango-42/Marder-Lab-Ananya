%% KATHLEEN METADATA

%% CONTROL 1
NB = 992;
page = 96;

metadata(NB, page).acclimation = 11;
metadata(NB, page).channels.cpv4 = "Vm_1";
metadata(NB, page).channels.gm5b = "Vm_2";
metadata(NB, page).channels.p2 = "Vm_3";
metadata(NB, page).channels.lvn = "IN 5";
metadata(NB, page).channels.pdn = "IN 6";
metadata(NB, page).channels.temp = 'Temp';
metadata(NB, page).tempValues = [11 14 17 21 24 27 31];
metadata(NB, page).files = [1 3 5 10 13 15 16];
metadata(NB, page).conditions = {"saline"};
metadata(NB, page).conditionStarts = [0];

%% CONTROL 2
NB = 992;
page = 62;

metadata(NB, page).acclimation = 11;
metadata(NB, page).channels.gm5b = "Vm_1";
metadata(NB, page).channels.p1 = "Vm_2";
metadata(NB, page).channels.gm6 = "Vm_3";
metadata(NB, page).channels.pyn = "IN 5";
metadata(NB, page).channels.lvn = "IN 6";
metadata(NB, page).channels.temp = 'Temp';
metadata(NB, page).tempValues = [11 14 17 21 24 31.5 11];
metadata(NB, page).files = [34 38 40 44 46 54 68];
metadata(NB, page).conditions = {"saline"};
metadata(NB, page).conditionStarts = [0];

%% CONTROL 3 - add another file for up ramp i need to fix this hhhh
NB = 992;
page = 63;

metadata(NB, page).acclimation = 11;
metadata(NB, page).channels.gm5a = "Vm_1";
metadata(NB, page).channels.p1 = "Vm_2";
metadata(NB, page).channels.p2 = "Vm_3";
metadata(NB, page).channels.pyn = "IN 5";
metadata(NB, page).channels.lvn = "IN 6";
metadata(NB, page).channels.temp = 'Temp';
metadata(NB, page).tempValues = [11 14 17 21 24];
metadata(NB, page).files = [70 73 75 79 81];
metadata(NB, page).conditions = {"saline"};
metadata(NB, page).conditionStarts = [0];
metadata(NB, page).abfOffset= 59;

%% HOT 1 % need to readd file 28 for temp = 33
NB = 992;
page = 90;

metadata(NB, page).acclimation = 18;
metadata(NB, page).channels.p1 = "Vm_1";
metadata(NB, page).channels.gm5b = "Vm_2";
metadata(NB, page).channels.p2 = "Vm_3";
metadata(NB, page).channels.pdn = "IN 6";
metadata(NB, page).channels.lvn = "IN 5";
metadata(NB, page).channels.temp = 'Temp';
metadata(NB, page).tempValues = [11 14 17 21 24 27 31];
metadata(NB, page).files = [1 4 6 12 19 22 26];
metadata(NB, page).conditions = {"saline"};
metadata(NB, page).conditionStarts = [0];

%% HOT 2
NB = 992;
page = 80;

metadata(NB, page).acclimation = 18;
metadata(NB, page).channels.cpv1a = "Vm_1";
metadata(NB, page).channels.cpv4 = "Vm_2";
metadata(NB, page).channels.gm5b = "Vm_3";
metadata(NB, page).channels.lvn = "IN 6";
metadata(NB, page).channels.temp = 'Temp';
metadata(NB, page).tempValues = [14 17 21 25 31];
metadata(NB, page).files = [5 8 14 22 30];
metadata(NB, page).conditions = {"saline"};
metadata(NB, page).conditionStarts = [0];

%% COLD 1
NB = 992;
page = 58;

metadata(NB, page).acclimation = 4;
metadata(NB, page).channels.gm6 = "Vm_1";
metadata(NB, page).channels.p1 = "Vm_2";
metadata(NB, page).channels.gm5b = "Vm_3";
metadata(NB, page).channels.lvn = "IN 6";
metadata(NB, page).channels.temp = 'Temp';
metadata(NB, page).tempValues = [11 14 17 21 24 26.5];
metadata(NB, page).files = [7 11 14 21 25 28];
metadata(NB, page).conditions = {"saline"};
metadata(NB, page).conditionStarts = [0];

%% COLD 2
NB = 992;
page = 84;

metadata(NB, page).acclimation = 4;
metadata(NB, page).channels.gm5b = "Vm_1";
metadata(NB, page).channels.p1 = "Vm_2";
metadata(NB, page).channels.cpv4 = "Vm_3";
metadata(NB, page).channels.lvn = "IN 5";
metadata(NB, page).channels.temp = 'Temp';
metadata(NB, page).tempValues = [11 13 17 21 24];
metadata(NB, page).files = [13 16 18 21 23];
metadata(NB, page).conditions = {"saline"};
metadata(NB, page).conditionStarts = [0];

%% COLD 3
NB = 992;
page = 50;

metadata(NB, page).acclimation = 4;
metadata(NB, page).channels.p1 = "Vm_1";
metadata(NB, page).channels.cpv6 = "Vm_2";
metadata(NB, page).channels.lvn = "IN 6";
metadata(NB, page).channels.temp = 'Temp';
metadata(NB, page).tempValues = [11 14 17 21 24 25 11];
metadata(NB, page).files = [11 17 28 34 40 42 51];
metadata(NB, page).conditions = {"saline"};
metadata(NB, page).conditionStarts = [0];

%% COLD 3
NB = 992;
page = 76;

metadata(NB, page).acclimation = 18;

metadata(NB, page).channels.lvn = "IN 5";
metadata(NB, page).channels.pyn = "IN 6";
metadata(NB, page).channels.temp = 'Temp';
metadata(NB, page).tempValues = [14 17 21 24 27 31];
metadata(NB, page).files = [13 19 23 26 31 32];
metadata(NB, page).conditions = {"saline"};
metadata(NB, page).conditionStarts = [0];
%% DAN POWELL METADATA
NB = 901;
page = 80;

metadata(NB, page).acclimation = 11;
metadata(NB, page).channels.temp = 'Temp';
metadata(NB, page).channels.lgn = 'IN 5';
metadata(NB, page).tempValues = [7 11 15 19 21];
metadata(NB, page).files = [15 24 34 42 48];
%%
NB = 901;
page = 95;

metadata(NB, page).acclimation = 4;
metadata(NB, page).channels.temp = 'Temp';
metadata(NB, page).channels.lgn = 'IN 9';
metadata(NB, page).tempValues = [7 11 15 19 21];
metadata(NB, page).files = [17 22 32 60 65];

%%
NB = 901;
page = 98;

metadata(NB, page).acclimation = 18;
metadata(NB, page).channels.temp = 'Temp';
metadata(NB, page).channels.lgn = 'IN 5';
metadata(NB, page).tempValues = [7 11 15 19 21];
metadata(NB, page).files = [10 17 25 31 35];

%%
NB = 901;
page = 46;

metadata(NB, page).acclimation = 11;
metadata(NB, page).channels.temp = 'Temp';
metadata(NB, page).channels.lgn = 'IN 5';
metadata(NB, page).tempValues = [7 9 11 13 15 17 19 21 23];
metadata(NB, page).files = [7 16 27 42 54 63 84 72 79];

%%

%% ANANYA METADATA (HEART)
NB = 993;
page = 8;

metadata(NB, page).acclimation = 11;
metadata(NB, page).channels.heart = "Ch 9";
metadata(NB, page).channels.temp = 'Temp';
metadata(NB, page).tempValues = [11 16 20];
metadata(NB, page).files = [30 43 53];
metadata(NB, page).conditions = {"saline"};
metadata(NB, page).conditionStarts = [0];

metadata(NB, page).calibration = .395;

%% ANANYA METADATA (HEART)
NB = 993;
page = 9;

metadata(NB, page).acclimation = 11;
metadata(NB, page).channels.heart = "Ch 9";
metadata(NB, page).channels.temp = 'Temp';
metadata(NB, page).tempValues = [11 16 21];
metadata(NB, page).files = [30 40 55];
metadata(NB, page).conditions = {"saline"};
metadata(NB, page).conditionStarts = [0];

metadata(NB, page).calibration = .18;

%% ANANYA METADATA (HEART)
NB = 993;
page = 10;

metadata(NB, page).acclimation = 11;
metadata(NB, page).channels.heart = "Ch 9";
metadata(NB, page).channels.temp = 'Temp';
metadata(NB, page).tempValues = [11 16 21 24 26.5];
metadata(NB, page).files = [15 24 35 44 50];
metadata(NB, page).conditions = {"saline"};
metadata(NB, page).conditionStarts = [0];
metadata(NB, page).ignore = [59];

metadata(NB, page).calibration = .38;

%% ANANYA METADATA (HEART)
NB = 993;
page = 12;

metadata(NB, page).acclimation = 11;
metadata(NB, page).channels.heart = "Force";
metadata(NB, page).channels.temp = 'Temp';
metadata(NB, page).tempValues = [11 16 20 25];
metadata(NB, page).files = [26 33 40 48];
metadata(NB, page).conditions = {"saline"};
metadata(NB, page).conditionStarts = [0];

metadata(NB, page).calibration = .284;

%% ANANYA METADATA (HEART)
NB = 993;
page = 11;

metadata(NB, page).acclimation = 11;
metadata(NB, page).channels.heart = "Ch 9";
metadata(NB, page).channels.temp = 'Temp';
metadata(NB, page).tempValues = [11 16 20];
metadata(NB, page).files = [41 51 61];
metadata(NB, page).conditions = {"saline"};
metadata(NB, page).conditionStarts = [0];

metadata(NB, page).calibration = .3;
%%
NB = 995;
page = 5;
metadata(NB, page).acclimation = 11;
metadata(NB, page).channels.lvn = "IN 10";
metadata(NB, page).channels.pdn = "IN 12";
metadata(NB, page).channels.pyn = "IN 6";
metadata(NB, page).channels.temp = "Tmp";
metadata(NB, page).doseStarts = [01 08 60 81 86 91 96 101 106 111];
metadata(NB, page).doseNames = { ...
        'Baseline','Decentralization','CCAP 1nM', 'CCAP 3nM', 'CCAP 10nM', 'CCAP 30nM', 'CCAP 100nM', ...
        'CCAP 300nM', 'CCAP 1μM', 'Washout'};
% %% PAIRED HEART AND STG DATA
% NB = 986;
% page = 102;
% 
% metadata(NB, page).acclimation = 4;
% metadata(NB, page).channels.heart = "Ch 9";
% metadata(NB, page).channels.temp = 'Temp';
% metadata(NB, page).tempValues = [11 21];
% metadata(NB, page).files = [14 89];
% metadata(NB, page).conditions = {"saline"};
% metadata(NB, page).conditionStarts = [0];
% 
% metadata(NB, page).calibration = .3;

%%

NB = 992;
page = 68;

metadata(NB, page).acclimation = 4;
metadata(NB, page).channels.gm6 = "Vm_2";
metadata(NB, page).channels.temp = 'Temp';


%% JAMES CRAB CRASH DATA
NB = 986;
page = 92;

metadata(NB, page).acclimation = 11;
metadata(NB, page).channels.heart = "Ch 9";
metadata(NB, page).channels.temp = 'Temp';
metadata(NB, page).tempValues = [11 14 17 20 23 26];
metadata(NB, page).files = [15 45 62 71 81 96 130];
metadata(NB, page).conditions = {"saline"};
metadata(NB, page).conditionStarts = [0];

metadata(NB, page).calibration = .32;

%% JAMES CRAB CRASH DATA
NB = 986;
page = 110;

metadata(NB, page).acclimation = 18;
metadata(NB, page).channels.heart = "Ch 9";
metadata(NB, page).channels.temp = 'Temp';
metadata(NB, page).tempValues = [12 16 20 24 28];
metadata(NB, page).files = [97 110 120 131 141];
metadata(NB, page).conditions = {"saline"};
metadata(NB, page).conditionStarts = [0];

metadata(NB, page).calibration = .27;


%% JAMES CRAB CRASH DATA
NB = 986;
page = 112;

metadata(NB, page).acclimation = 18;
metadata(NB, page).channels.heart = "Ch 9";
metadata(NB, page).channels.temp = 'Temp';
metadata(NB, page).files = [7 21 29 35 50 57 63];
metadata(NB, page).tempValues = [11 16 20 24 28 32];
metadata(NB, page).conditions = {"saline"};
metadata(NB, page).conditionStarts = [0];

metadata(NB, page).calibration = .25;

%% JAMES CRAB CRASH DATA
NB = 986;
page = 116;

metadata(NB, page).acclimation = 4;
metadata(NB, page).channels.heart = "Ch 9";
metadata(NB, page).channels.temp = 'Temp';
metadata(NB, page).files = [5 18 23 29 46 ];
metadata(NB, page).tempValues = [11 13 16 20 24];
metadata(NB, page).conditions = {"saline"};
metadata(NB, page).conditionStarts = [0];

metadata(NB, page).calibration = .14;


%% JAMES CRAB CRASH DATA
NB = 986;
page = 120;

metadata(NB, page).acclimation = 18;
metadata(NB, page).channels.heart = "Ch 9";
metadata(NB, page).channels.temp = 'Temp';
metadata(NB, page).files = [20 34 43 50];
metadata(NB, page).tempValues = [11 16 20 23];
metadata(NB, page).conditions = {"saline"};
metadata(NB, page).conditionStarts = [0];

metadata(NB, page).calibration = .308;

%% JAMES CRAB CRASH DATA
NB = 986;
page = 124;

metadata(NB, page).acclimation = 18;
metadata(NB, page).channels.heart = "Ch 9";
metadata(NB, page).channels.temp = 'Temp';
metadata(NB, page).tempValues = [11 16 29];
metadata(NB, page).files = [33 52 68];
metadata(NB, page).conditions = {"saline"};
metadata(NB, page).conditionStarts = [0];

metadata(NB, page).calibration = .308;
%%

sonalMetadata

clear NB
clear page