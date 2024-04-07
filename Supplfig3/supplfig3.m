% Supplementary Figure 3 Encoding of poking action and reward in the 
% population activity of the ACC and mPFC 

%% LOAD MAT FILE
thisexpname = 'varITILong'; % data from which challenge to load
dpath = Choosesavedir('outputvars');
dpath = fullfile(dpath, 'getVars', thisexpname);
load(fullfile(dpath, ['getVars_4sbf7saf_' thisexpname '.mat'])) %
dpath = Choosesavedir('outputvars');
load(fullfile(dpath,'regressAnalysis', thisexpname , ['regressAnalysis_4sbf7saf_' thisexpname '.mat']))

%% create Supplfig.3B_C
thisepochtype=3;
Supplfig3B_C(Params,infovar,regressvar,beh,thisepochtype) 