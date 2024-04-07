%% Fig. 2 Event-locked activity of individual neurons in the variable ITI challenge
% %%% Martin Jendryka, 2024
%%%

%% 1. LOAD MAT FILE created in getVars.m
thisexpname = 'varITILong'; % name of challenge
dpath = Choosesavedir('outputvars'); % gets directory where mat files are stored
dpath = fullfile(dpath, 'getVars', thisexpname); % specifies which mat file from which challenge should be loaded
load(fullfile(dpath, ['getVars_4sbf7saf_' thisexpname '.mat'])) % loads mat file

%% 2, PLOT FIGURES 
% choose epochtype, 1-iti, 2-cue, 3-choice, 4-outcome (in Fig.2 choice
% epoch is shown)
epochtype = 3; 

Fig2A_B(Params,epochscat,epochtype)

%% select for which clusters to make plots
% 1: iti / correct; 2: cue / incorrect; 3: choice / omission; 4:
% outcome/ premature (Fig.2 C-F display heatplots for clusters of correct choices during choice epoch)

trialtype = 1;
Fig2C_D(Params,infovar,epochscat,clusters.allcells,beh,epochtype,trialtype) 
Fig2E_F(Params,infovar,eventlistAll,epochscat,clusters.allcells,beh,epochSessionid,epochtype)
%Fig2E_F_allCells(Params,infovar,eventlistAll,epochscat,clusters.allcells,beh,epochSessionid,epochtype) % this plots the single-trial activity of all cells, takes some time 
