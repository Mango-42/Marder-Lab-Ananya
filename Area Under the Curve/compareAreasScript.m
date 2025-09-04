%% Get area comparison for one animal
targetNotebook = 988;
targetPage = 90;

% directory can be set to "auto" on mac if you're connected to the server
% otherwise supply raw data path

[a1, a2] = compareAreas("auto", targetNotebook, targetPage, "LG11_11", "LG11_21", 0);
%%
targetNotebook = [988, 988, 988, 991, 991, 988];
targetPage = [90, 116, 108, 10, 15, 120];

[a1, a2] = compareAreas("auto", targetNotebook, targetPage, "LG11_11", "LG11_21", 1);
%%
plotOverview("auto", 992, 40, "Real", 0, "full")

%%
