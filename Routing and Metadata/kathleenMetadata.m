
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
%%

NB = 992;
page = 68;

metadata(NB, page).acclimation = 4;
metadata(NB, page).channels.gm6 = "Vm_2";
metadata(NB, page).channels.temp = 'Temp';


%% 
NB = 998;
page = 24;

metadata(NB, page).acclimation = 11;
metadata(NB, page).channels.lvn = "IN 7";
metadata(NB, page).channels.force = "Force";
metadata(NB, page).channels.temp = "Temp";
metadata(NB, page).tempValues = [11 6 11 14 16 17 21 22 11 11 6 11 11];
metadata(NB, page).files = [90 101 115 119 124 127 134 138 153 160 164 171 190];
metadata(NB, page).conditions = {"saline", "CCAP 10-7"};
metadata(NB, page).conditionStarts = [90 153];

%%
NB = 998;
page = 28;

metadata(NB, page).acclimation = 11;
metadata(NB, page).channels.lvn = "IN 6";
metadata(NB, page).tempValues = [6 11 14 16 17 21 23 11 11 6 11 14 17 21 21 21 17];
metadata(NB, page).files = [6 16 20 26 30 36 38 82 85 96 104 109 113 117 124 128 130 135];
metadata(NB, page).conditions = {"saline", "CCAP 10-8"};
metadata(NB, page).conditionStarts = [6 85];


