%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DO NOT CHANGE VARIABLES BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Params.brainareas = {'ACC','mPFC'};
Params.trialtypes = {'correct', 'incorrect','omission', 'premature' };
Params.poketypes = {'poke_1','poke_2','poke_3','poke_4','poke_5'};
Params.responsetypes = {'correct', 'incorrect','omission', 'premature', 'reward' };
Params.epochtypes = categorical({'iti','cue','choice','outcome'},{'iti','cue','choice','outcome'});

Params.f = 5; % frame rate
Params.windowwidth = 5; % within 5 frames there can only be one peak
Params.maxlag = 20;
Params.tail = false;
Params.timebinlength = 1000/Params.f;
Params.times.bfevent = timebfevent;
Params.times.afevent = timeafevent;
Params.frames.bfevent = floor(Params.times.bfevent/Params.timebinlength);
Params.frames.afevent = floor(Params.times.afevent./Params.timebinlength);
Params.frames.num = zeros(1,numel(Params.epochtypes));
for thisepochtype = 1:numel(Params.epochtypes)
    if timebfevent(thisepochtype) == 0
        Params.frames.num(thisepochtype) = Params.frames.bfevent(thisepochtype)+Params.frames.afevent(thisepochtype);
    else % in this case you need an additional frame for the timepoint 0
        Params.frames.num(thisepochtype) = Params.frames.bfevent(thisepochtype)+Params.frames.afevent(thisepochtype)+1;
    end
end
%% k-means clustering 
Params.nCluster = 4;

%% classifier
Params.dosmote = 1;
Params.MLiterations = 100;
Params.ratio = 0.2;
Params.trialcombs = flip(combnk(1:numel(Params.trialtypes),2));
Params.smoteNeighbors = 4; % number of neigbors SMOTE function uses for over-sampling events from minority class
Params.mineventsClass = 6; % minimum trial number for one eventtype
%% linear regression
Params.predstrs = {'activePoke-omission','spatialLocation1','spatialLocation2','spatialLocation3','spatialLocation4','rewarded(correct)Response'};
Params.lasso_CV = 10; % k-fold cross-validation of lasso regression
Params.sampling_iterations = 100; % iterations for repeating downsampling of baseline challenge to devaluation experiments 

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DO NOT CHANGE VARIABLES ABOVE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%