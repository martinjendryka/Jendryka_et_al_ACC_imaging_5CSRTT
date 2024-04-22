add2path

explist = {'varITI','cb800ms','cbExt1','cbExt2','cbDeval1','mixedChalls'};

%% 1. arrange the raw data into a mat file 
arrangeData

%% select times before and after each event (i.e. iti, cue, choice and outcome) for signal extraction
%%% dont change to reproduce figures of paper
timebfevent = [0,0,4000,0]; %[ms]
timeafevent = [4000,1000,7000,1000];%[ms]

setparams % do not change these variables
%% 2. get variables for plotting  
%%% 2. extract calcium traces at set time windows relative to the trial type
% (i.e. correct, incorrect, omission and premature responses) epoch
% types (i.e. iti, cue presentation, choice poke, outcome) 
getVars

%% k-mean clustering
explist = {'varITI'};
clusteringAnalysis

%% Fig. 2 Event-locked activity of individual neurons in the variable ITI challenge
fig2

%% Binary classification 
epochtype= [1,3];
explist = {'varITI','mixedChalls'}; % required for fig3
binaryClassifierAnalysis 

%% Fig. 3 Decoding of behavioral choice from population activity in ACC and mPFC
fig3

%% Multi-classification of poke hole 
includecorrectsonly = 0;
epochtype=3;
explist = {'varITI'};
multiClassifierAnalysis
includecorrectsonly = 1;
multiClassifierAnalysis % required for fig4

%% Fig. 4 Activity in the ACC represents spatial action selection
fig4

%% Encoding analysis
explist={'varITI','cbExt1','cbExt2','cbDeval1'}; % required for Fig5 and Fig7
dopredmerge = 1;
epochtype=3;
regressAnalysis
explist={'varITI'}; % required for Supplfig.3
dopredmerge = 0;
regressAnalysis
%% Fig.5 Encoding of poking action and reward in the population activity 
fig5
%% Binary classification of devaluation experiments
explist = {'cb800ms','cbExt1','cbExt2','cbDeval1'};

binaryClassification_deval % required for Fig6

%% Fig.6 Decoding of behavioral choice from population activity in ACC
fig6

%% Encoding analysis of devaluation experiments
explist = {'cb800ms','cbDeval1','cbExt1','cbExt2'};
epochtype =3;
regressAnalysis_dsToChall

%% Fig.7 Encoding of reward and action in ACC depends on relative value and  
fig7 

%% Supplementary figures
supplfig2 
supplfig3 