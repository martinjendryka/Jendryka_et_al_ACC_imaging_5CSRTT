%% Fig. 3 Decoding of behavioral choice from population activity in ACC and mPFC
% %%% Martin Jendryka, 2024

explist = {'varITI','mixedChalls'};

for thisexp = 1:numel(explist)
    thisexpname = explist{thisexp}; 
    dpath = Choosesavedir('outputvars');
    dpath = fullfile(dpath, 'getVars', thisexpname);
    load(fullfile(dpath, ['getVars_4sbf7saf_' thisexpname '.mat'])) % mat file created by getVars script loaded
    dpath = Choosesavedir('outputvars');
    load(fullfile(dpath,'binaryClassifier', thisexpname , ['binaryClassifier_4sbf7saf_' thisexpname '.mat'])) % mat file created by classifier script loaded

    % choose epochtype, 1-iti, 2-cue, 3-choice, 4-outcome (in Fig.3 the ITI and choice
    % epoch is shown)
    thisepochtype = 3;
    if thisexp ==1
        Fig3A_B(Params,infovar,classifier,beh,thisepochtype)
    else
        Fig3C(Params,infovar,classifier,beh,thisepochtype)
    end

    clearvars -except explist
end


