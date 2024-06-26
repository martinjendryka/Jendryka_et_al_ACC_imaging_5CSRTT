thisexpname = explist{1};
loadmatname = 'getVars_4sbf7saf'; % mat file of descr Analysis

dpath = Choosesavedir('outputvars');
dpath = fullfile(dpath, 'getVars', thisexpname);
load(fullfile(dpath, [loadmatname '_' thisexpname '.mat'])) %

thisarea=1;

animalselect = find(ismember(infovar.brainareas,Params.brainareas(thisarea)));
dpath_save = Choosesavedir('outputvars');
dpath_save = fullfile(dpath_save, 'regressAnalysis' ,thisexpname); % where mat files are stored
mkdir(dpath_save)

for otherexp_idx = 1:numel(explist)
    otherexp = explist{otherexp_idx};
    dpath = Choosesavedir('outputvars');

    dpath = fullfile(dpath, 'getVars', otherexp);
    beh_otherexp = load(fullfile(dpath, [loadmatname '_' otherexp '.mat']),'beh');
    infovar_otherexp = load(fullfile(dpath, [loadmatname '_' otherexp '.mat']),'infovar');
    selectanimals = find(ismember(infovar_otherexp.infovar.brainareas,Params.brainareas(thisarea)));
    numevents_otherexp_ACC = floor(mean(beh_otherexp.beh.numevents(:,selectanimals),2));
    numpokes_otherexp_ACC = floor(mean(beh_otherexp.beh.pokesnum(:,:,selectanimals),3));

    matexportname = ['regressAnalysis_', extractAfter(loadmatname,'_'),'_dsTo_',otherexp];
    
    cpd_all = cell(Params.sampling_iterations,numel(Params.epochtypes),numel(animalselect));
    
    for thisses = animalselect   % FOR LOOP START through each session

        eventlist= eventlistAll(thisses);
        eventepochs = eventepochsAll{thisses};
        numevents = beh.numevents(:,thisses);
        pokes = beh.pokes(:,thisses);
        numpokes = beh.pokesnum(:,:,thisses);
        numcells = infovar.ncells(thisses);
        setlabel = repelem(Params.trialtypes',numevents); % repeats trialtypes names corresponding to event number (if 0 will be not repeated)

        for i = 1:Params.sampling_iterations

            %%% downsample to match other challenge
            [eventepochs_ds,numevents_ds,pokes_ds,numpokes_ds] =  Downsample_events_to_match_other(Params,eventepochs,numevents,pokes,numpokes,numevents_otherexp_ACC,numpokes_otherexp_ACC);

            %%% Linear regression
            [thisx,thisy,Params,labels] = MakeRegressset(Params,eventepochs_ds,numevents_ds,pokes_ds); % get input data for regression

            if any(numevents(3)<=2) % if there are not enough omissions, model will be rank deficient due to activePoke predictor
                fprintf('%s %d out of %d not enough omissions \n',infovar.animals{thisses},thisses,numel(animalselect))
                continue
            end

            %%% Run Regression
            cpd_thisses =  LinearRegressPredmerged(thisx,thisy,Params,numcells,labels,epochtype);
            cpd_all(i,:,thisses) = cpd_thisses;

            fprintf('ses %d: %d out of %d iterations finished \n',thisses,i,Params.sampling_iterations)

        end
        fprintf('%s %d out of %d finished \n',infovar.animals{thisses},thisses,numel(animalselect))

    end %   FOR LOOP END through each session

    regressvar.cpd = cpd_all;
    save(fullfile(dpath_save ,[matexportname '_' thisexpname '.mat']),'Params','regressvar');
    fprintf('Experiment %s done \n',thisexpname)
end
clear all