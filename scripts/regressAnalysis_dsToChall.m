thisexpname = 'cb800ms';
loadmatname = 'getVars_4sbf7saf'; % mat file of descr Analysis

otherexp = 'cbDeval1';
dpath = Choosesavedir('outputvars');

dpath = fullfile(dpath, 'getVars', otherexp);
load(fullfile(dpath, [loadmatname '_' otherexp '.mat'])) %
numevents_otherexp_ACC = floor(mean(beh.numevents(:,ismember(infovar.brainareas,{'cingulate'})),2));
numpokes_otherexp_ACC = floor(mean(cat(3,beh.pokesnum{ismember(infovar.brainareas,{'cingulate'})}),3));

dpath = Choosesavedir('outputvars');
dpath = fullfile(dpath, 'getVars', thisexpname);
load(fullfile(dpath, [loadmatname '_' thisexpname '.mat'])) %

Params.matexportname = ['regressAnalysis_', extractAfter(loadmatname,'_')];

animals = infovar.animals;
expdates = infovar.expdates;
ncells = infovar.ncells;
brainareasAll = infovar.brainareas;
task = infovar.task;
reclength = infovar.reclength;

dpath = Choosesavedir('outputvars');
dpath = fullfile(dpath, 'regressAnalysis' ,thisexpname);
mkdir(dpath)

cpd = cell(sampling_iterations,numel(animals));

for thisses = 1:numel(animals)   % FOR LOOP START through each session
    thisregion = brainareasAll(thisses);
    if ismember(thisregion,Params.brainareas(2)
        continue
    end
    eventlist= eventlistAll(thisses);
    eventepochs = eventepochsAll{thisses};
    numevents = beh.numevents(:,thisses);
    pokes = beh.pokes(:,thisses);
    numpokes = beh.pokesnum{thisses};
    numcells = ncells(thisses);
    setlabel = repelem(Params.trialtypes',numevents); % repeats trialtypes names corresponding to event number (if 0 will be not repeated)
    brainarea = brainareasAll(thisses);

    for i = 1:sampling_iterations

        %%% downsample to match other challenge
         [eventepochs_ds,numevents_ds,pokes_ds,numpokes_ds] =  Downsample_events_to_match_other(Params,eventepochs,numevents,pokes,numpokes,numevents_otherexp_ACC,numpokes_otherexp_ACC);
     
        %%% Linear regression
        [thisx,thisy,Params,labels] = MakeRegressset(Params,eventepochs_ds,numevents_ds,pokes_ds); % get input data for regression

        if any(numevents(3)<=2) % if there are not enough omissions, model will be rank deficient due to activePoke predictor
            fprintf('%s %d out of %d not enough omissions \n',animals{thisses},thisses,numel(animals))
            continue
        end

        %%% Run Regression
        cpd_thisses{i,thisses} =  LinearRegressPredmerged(thisx,thisy,Params,numcells,labels);
        
        fprintf('ses %d: %d out of %d iterations finished \n',thisses,i,sampling_iterations)

    end
    fprintf('%s %d out of %d finished \n',animals{thisses},thisses,numel(animals))

end %   FOR LOOP END through each session

regressvar.cpd = cpd;
save(fullfile(dpath ,[Params.matexportname '_' thisexpname '.mat']),'Params','regressvar');
fprintf('Experiment %s done \n',thisexpname)
clearvars -except loadmatname explist