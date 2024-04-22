%%% Fig. 4 Activity in the ACC represents spatial action selection
%%% Martin Jendryka, 2024

thisexpname = 'varITI';
%% Fig.4A-C
dpath = Choosesavedir('outputvars');
dpath2 = fullfile(dpath, 'getVars', thisexpname);
load(fullfile(dpath2, ['getVars_4sbf7saf_' thisexpname '.mat'])) % mat file created by getVars script loaded

epochtype = 3; % choose epochtype, 1-iti, 2-cue, 3-choice, 4-outcome

Fig4A_B_C(Params,infovar,eventepochsAll_pokes,epochtype)

%% Fig.4D
dpath = Choosesavedir('outputvars');
load(fullfile(dpath,'multiclassifier', thisexpname , ['multiClassifierAlltrials_4sbf7saf' '_' thisexpname '.mat']),'classifier') % mat file created by classifier script loaded 
classifier_alltrials = classifier;
load(fullfile(dpath,'multiclassifier', thisexpname , ['multiClassifierOnlyCorrects_4sbf7saf' '_' thisexpname '.mat']),'classifier') % mat file created by classifier script loaded 
classifier_corrects= classifier;
Fig4D(Params,infovar,classifier_alltrials,classifier_corrects,beh,epochtype)
clear all