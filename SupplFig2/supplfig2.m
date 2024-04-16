%%% Supplementary Fig. 2 Activity in the ACC represents spatial action selection
%%% Martin Jendryka, 2024

thisexpname = 'varITI';
%% Suppl. Fig.2A-C
dpath = Choosesavedir('outputvars');
dpath2 = fullfile(dpath, 'getVars', thisexpname);
load(fullfile(dpath2, ['getVars_4sbf7saf_' thisexpname '.mat'])) % mat file created by getVars script loaded

epochtype = 3; % choose epochtype, 1-iti, 2-cue, 3-choice, 4-outcome

Supplfig2A_B_C(Params,infovar,eventepochsAll_pokes,epochtype)