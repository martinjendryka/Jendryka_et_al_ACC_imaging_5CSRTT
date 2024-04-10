loadmatname = 'getVars_4sbf7saf'; %SET ACCORDING TO PREVIOUS SCRIPT
if includecorrectsonly 
    exportname = 'multiClassifier';
else
    exportname='multiClassifierOnlyCorrects';
end
explist = {'varITILong'};
for thisexp = 1:numel(explist)
    %% LOAD MAT FILE: descrAnalysis.mat
    thisexpname = explist{thisexp};
    dpath = Choosesavedir('outputvars');
    dpath = fullfile(dpath, 'getVars', thisexpname);
    load(fullfile(dpath, [loadmatname '_' thisexpname '.mat'])) %

    %%% dont change these parameters
    Params.dosmote = 1;
    Params.MLiterations = 100;
    Params.ratio = 0.2;
    Params.smoteNeighbors = 4;
    Params.mineventsClass = 6; % minimum trial number for one eventtype

    %%% pre-allocate variable
    pdecod = cell(numel(Params.epochtypes),numel(infovar.animals));
    fscore = cell(numel(Params.epochtypes),numel(infovar.animals));
    beta = cell(numel(Params.epochtypes),numel(infovar.animals));
    auc = cell(numel(Params.epochtypes),numel(infovar.animals));

    pdecodShuffled = cell(numel(Params.epochtypes),size(Params.trialcombs,1),numel(infovar.animals));
    fscoreShuffled = cell(numel(Params.epochtypes),size(Params.trialcombs,1),numel(infovar.animals));
    betaShuffled = cell(numel(Params.epochtypes),size(Params.trialcombs,1),numel(infovar.animals));
    aucShuffled = cell(numel(Params.epochtypes),size(Params.trialcombs,1),numel(infovar.animals));

    for thisses = 1:numel(infovar.animals) % start for-loop through sessions
        thisanimal = infovar.animals{thisses};
        thisregion = infovar.brainareas(thisses);
        numevents = beh.numevents(:,thisses);
        eventepochs = eventepochsAll{thisses};
        numpokes = beh.pokes(:,thisses);

        %%% supervised machine-learning using classifier
        %%% Make sets and setlabels
        thisset = TransformTrace_multi(Params,eventepochs,numpokes);
        setlabel = vertcat(numpokes{:});
        if includecorrectsonly
            setlabel = numpokes{1};
        end
        % file name accordingly in line 79
        %%% Run classifier
        [pdecod_thisses, fscore_thisses, beta_thisses,~,~,auc_thisses] = ...
            Mymulticlassifier(thisset,setlabel,Params,infovar,thisses,numevents,0); % with true labels

        pdecod(:,thisses) = pdecod_thisses;
        fscore(:,thisses) = fscore_thisses;
        beta(:,thisses) = beta_thisses;
        auc(:,thisses)=auc_thisses;

        [pdecod_thisses, fscore_thisses, beta_thisses,~,~,auc_thisses] =  ... % with shuffled labels
            Mymulticlassifier(thisset,setlabel,Params,infovar,thisses,numevents,1);

        pdecodShuffled(:,thisses) = pdecod_thisses;
        fscoreShuffled(:,thisses) = fscore_thisses;
        betaShuffled(:,thisses) = beta_thisses;
        aucShuffled(:,thisses)=auc_thisses;

        sprintf('%s %d out of %d finished',thisanimal,thisses,numel(infovar.animals))
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% FOR LOOP END through each session
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% arrange output structures for export to mat file

    classifier.pdecod = pdecod;
    classifier.pdecodShuffled = pdecodShuffled;
    classifier.fscore = fscore;
    classifier.fscoreShuffled = fscoreShuffled;
    classifier.beta = beta;
    classifier.betaShuffled = betaShuffled;
    classifier.auc = auc;
    classifier.aucShuffled = aucShuffled;

    dpath = Choosesavedir('outputvars');
    dpath = fullfile(dpath, 'multiclassifier', thisexpname,[exportname,extractAfter(loadmatname,'_')]);
    mkdir(dpath)
    save(fullfile([dpath,'.mat']),'Params','classifier');
    fprintf('Experiment %s done \n',thisexpname)
end