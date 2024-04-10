%% SET ACCORDING TO PREVIOUS SCRIPT
loadmatname = 'getVars_4sbf7saf';

explist = {'cb800ms','cbExt1','cbExt2','cbDeval1'};

for thisexp = 1:numel(explist)
    
    thisexpname = explist{thisexp};
    dpath = Choosesavedir('outputvars');
    dpath = fullfile(dpath, 'getVars', thisexpname);
    load(fullfile(dpath, [loadmatname '_' thisexpname '.mat'])) %

    %%% dont change these parameters
    Params.MLiterations = 100;
    Params.ratio = 0.2; % 20% of trials make up test set
    Params.smoteNeighbors = 4; % number of neigbors SMOTE function uses for over-sampling events from minority class
    Params.mineventsClass = 6; % minimum trial number for one eventtype
    
    %%% pre-allocate variable
    pdecod = cell(numel(Params.epochtypes),size(Params.trialcombs,1),numel(infovar.animals));
    fscore = cell(numel(Params.epochtypes),size(Params.trialcombs,1),numel(infovar.animals));
    beta = cell(numel(Params.epochtypes),size(Params.trialcombs,1),numel(infovar.animals));
    auc = cell(numel(Params.epochtypes),size(Params.trialcombs,1),numel(infovar.animals));

    pdecodShuffled = cell(numel(Params.epochtypes),size(Params.trialcombs,1),numel(infovar.animals));
    fscoreShuffled = cell(numel(Params.epochtypes),size(Params.trialcombs,1),numel(infovar.animals));
    betaShuffled = cell(numel(Params.epochtypes),size(Params.trialcombs,1),numel(infovar.animals));
    aucShuffled = cell(numel(Params.epochtypes),size(Params.trialcombs,1),numel(infovar.animals));

    for thisses = 1:numel(infovar.animals) % start for-loop through sessions
        thisanimal = infovar.animals{thisses};
        thisregion = infovar.brainareas(thisses);
        
        if ismember(thisregion,Params.brainareas(2))
            continue
        end
        numevents = beh.numevents(:,thisses);
        eventepochs = eventepochsAll{thisses};

        %%% Make sets and setlabels for classification
        [thisset,setlabel] = TransformTrace_binaryclassifier(Params,eventepochs,numevents);

        %%% Run classifier
         
        [pdecod_thisses, fscore_thisses, beta_thisses,~,~,auc_thisses] = ...
            Mybinaryclassifier(thisset,setlabel,Params,infovar,thisses,0); % with true labels

        pdecod(:,:,thisses) = pdecod_thisses;
        fscore(:,:,thisses) = fscore_thisses;
        beta(:,:,thisses) = beta_thisses;
        auc(:,:,thisses)=auc_thisses;

        [pdecod_thisses, fscore_thisses, beta_thisses,~,~,auc_thisses] =  ... % with shuffled labels
        Mybinaryclassifier(thisset,setlabel,Params,infovar,thisses,1);

        pdecodShuffled(:,:,thisses) = pdecod_thisses;
        fscoreShuffled(:,:,thisses) = fscore_thisses;
        betaShuffled(:,:,thisses) = beta_thisses;
        aucShuffled(:,:,thisses)=auc_thisses;

        fprintf('%s %d out of %d finished \n',thisanimal,thisses,numel(infovar.animals))
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% FOR LOOP END through each session
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    classifier.pdecod = pdecod;
    classifier.pdecodShuffled = pdecodShuffled;
    classifier.fscore = fscore;
    classifier.fscoreShuffled = fscoreShuffled;
    classifier.beta = beta;
    classifier.betaShuffled = betaShuffled;
    classifier.auc = auc;
    classifier.aucShuffled= aucShuffled;
    dpath = Choosesavedir('outputvars');
    dpath = fullfile(dpath, 'binaryClassifier', thisexpname , ['binaryClassifier_', extractAfter(loadmatname,'_'),'_',thisexpname]);
    mkdir(dpath)
    save(fullfile([dpath ,'.mat']),'Params','classifier');
    fprintf('Experiment %s done \n',thisexpname)
    clearvars -except loadmatname explist
end