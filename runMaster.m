add2path

explist = {'varITI','cb800ms','cbExt1','cbExt2','cbDeval1','mixedChalls'};

%% 1. arrange the raw data into a mat file 
arrangeData

%% 2. get variables for plotting  
%%% 2. extract calcium traces at set time windows relative to the trial type
% (i.e. correct, incorrect, omission and premature responses) epoch
% types (i.e. iti, cue presentation, choice poke, outcome) 
getVars

%% k-mean clustering
clusteringAnalysis

%% Fig. 2 Event-locked activity of individual neurons in the variable ITI challenge
fig2

%% Binary classification 
epochtype= [1,3];
binaryClassifierAnalysis

%% Fig. 3 Decoding of behavioral choice from population activity in ACC and mPFC
fig3

%% Multi-classification of poke hole 
includecorrectsonly = 0;
epochtype=3;
multiClassifierAnalysis
includecorrectsonly = 1;
multiClassifierAnalysis

%% Fig. 4 Activity in the ACC represents spatial action selection
fig4

%% Encoding analysis
dopredmerge = 1;
regressAnalysis
dopredmerge = 0;
regressAnalysis
%% Fig.5 Encoding of poking action and reward in the population activity 
fig5
%% Binary classification of devaluation experiments
binaryClassification_deval

%% Fig.6 Decoding of behavioral choice from population activity in ACC
fig6

%% Encoding analysis of devaluation experiments
regressAnalysis_dsToChall

%% Fig.7 Encoding of reward and action in ACC depends on relative value and  
fig7

%% Supplementary figures
supplfig2
supplfig3