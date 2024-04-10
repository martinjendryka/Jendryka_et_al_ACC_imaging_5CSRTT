explist = {'varITILong'};
loadmatname = 'getVars_4sbf7saf'; % mat file of descr Analysis

for thisexp = 1:numel(explist)
    thisexpname = explist{thisexp}; % data from which challenge to load
    dpath = Choosesavedir('outputvars');
    dpath = fullfile(dpath, 'getVars', thisexpname);
    load(fullfile(dpath, [loadmatname '_' thisexpname '.mat'])) %

    animals = infovar.animals;
    expdates = infovar.expdates;
    ncells = infovar.ncells;
    brainareasAll = infovar.brainareas;
    task = infovar.task;
    reclength = infovar.reclength;

    dpath = Choosesavedir('outputvars');
    dpath = fullfile(dpath, 'regressAnalysis' ,thisexpname);
    mkdir(dpath)
    cpd = cell(numel(Params.epochtypes),numel(animals));

    for thisses = 1:numel(animals)   % FOR LOOP START through each session
        eventlist= eventlistAll(thisses);
        eventepochs = eventepochsAll{thisses};
        numevents = beh.numevents(:,thisses);
        pokes = beh.pokes(:,thisses);
        numpokes = beh.pokesnum{thisses};
        numcells = ncells(thisses);
        thisregion = brainareasAll(thisses);
        setlabel = repelem(Params.trialtypes',numevents); % repeats trialtypes names corresponding to event number (if 0 will be not repeated)

        %%% Linear regression
        [thisx,thisy,Params,labels] = MakeRegressset(Params,eventepochs,numevents,pokes); % get input data for regression

        if any(numevents(3)<=2) % if there are not enough omissions, model will be rank deficient due to activePoke predictor
            fprintf('%s %d out of %d not enough omissions \n',animals{thisses},thisses,numel(animals))
            continue
        end

        %%% Run Regression
        if dopredmerge
        cpd_thisses =  LinearRegressPredmerged(thisx,thisy,Params,numcells,labels);
        else
        cpd_thisses =  LinearRegress(thisx,thisy,Params,numcells,labels);
        end
        cpd(:,thisses) = cpd_thisses;
        fprintf('%s %d out of %d finished \n',animals{thisses},thisses,numel(animals))
    end %   FOR LOOP END through each session

    regressvar.cpd = cpd;
    save(fullfile(dpath,['regressAnalysis_', extractAfter(loadmatname,'_'),'_',thisexpname '.mat']),'Params','regressvar');
    fprintf('Experiment %s done \n',thisexpname)
    clearvars -except loadmatname explist thisexp
end