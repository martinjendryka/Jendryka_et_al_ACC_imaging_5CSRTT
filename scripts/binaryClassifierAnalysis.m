%% SET ACCORDING TO PREVIOUS SCRIPT
loadmatname = 'getVars_4sbf7saf';

for thisexp = 1:numel(explist)
    
    thisexpname = explist{thisexp};
    dpath = Choosesavedir('outputvars');
    dpath = fullfile(dpath, 'getVars', thisexpname);
    load(fullfile(dpath, [loadmatname '_' thisexpname '.mat'])) %

    %%% pre-allocate variable
    pdecod = cell(size(Params.trialcombs,1),numel(Params.epochtypes),numel(infovar.animals));
    fscore = cell(size(Params.trialcombs,1),numel(Params.epochtypes),numel(infovar.animals));
    beta = cell(size(Params.trialcombs,1),numel(Params.epochtypes),numel(infovar.animals));
    auc = cell(size(Params.trialcombs,1),numel(Params.epochtypes),numel(infovar.animals));

    pdecodShuffled = cell(size(Params.trialcombs,1),numel(Params.epochtypes),numel(infovar.animals));
    fscoreShuffled = cell(size(Params.trialcombs,1),numel(Params.epochtypes),numel(infovar.animals));
    betaShuffled = cell(size(Params.trialcombs,1),numel(Params.epochtypes),numel(infovar.animals));
    aucShuffled = cell(size(Params.trialcombs,1),numel(Params.epochtypes),numel(infovar.animals));

    for thisses = 1:numel(infovar.animals) % start for-loop through sessions
        thisanimal = infovar.animals{thisses};
        thisregion = infovar.brainareas(thisses);
        numevents = beh.numevents(:,thisses);
        eventepochs = eventepochsAll{thisses};

        %%% Make sets and setlabels for classification
        [thisset,setlabel] = TransformTrace_binaryclassifier(Params,eventepochs,numevents);

        %%% Run classifier
         
        [pdecod_thisses, fscore_thisses, beta_thisses,~,~,auc_thisses] = ...
            Mybinaryclassifier(thisset,setlabel,Params,infovar,thisses,epochtype,0); % with true labels

        pdecod(:,:,thisses) = pdecod_thisses;
        fscore(:,:,thisses) = fscore_thisses;
        beta(:,:,thisses) = beta_thisses;
        auc(:,:,thisses)=auc_thisses;

        [pdecod_thisses, fscore_thisses, beta_thisses,~,~,auc_thisses] =  ... % with shuffled labels
        Mybinaryclassifier(thisset,setlabel,Params,infovar,thisses,epochtype,1);

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
    mkdir(fileparts(dpath))
    save(fullfile([dpath ,'.mat']),'Params','classifier');
    fprintf('Experiment %s done \n',thisexpname)
    clearvars -except loadmatname explist epochtype
end