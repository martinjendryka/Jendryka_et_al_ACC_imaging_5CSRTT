% Fig.5 Encoding of poking action and reward in the population activity 
% of the ACC and mPFC
%% LOAD MAT FILE

thisexpname = 'varITI'; % data from which challenge to load
dpath = Choosesavedir('outputvars');
dpath = fullfile(dpath, 'getVars', thisexpname);
load(fullfile(dpath, ['getVars_4sbf7saf_' thisexpname '.mat'])) %
dpath = Choosesavedir('outputvars');
load(fullfile(dpath,'regressAnalysis', thisexpname , ['regressAnalysisPredmerged_4sbf7saf_' thisexpname '.mat']))
%% create Fig.5B_C
epochtype=3;
Fig5B_C(Params,infovar,regressvar,beh,epochtype)

