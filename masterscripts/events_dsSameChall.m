clear,close all,clc

explist = {'cb800ms','cbDeval1','cbExt1','cbExt2'};

dpath = Choosesavedir('outputvars');

loadmatname = 'getVars_4sbf7saf'; % mat file of descr Analysis

for thisexp = 1:numel(explist)
    thisexpname = explist{thisexp}; % data from which challenge to load
    dpath = Choosesavedir('outputvars');
    dpath = fullfile(dpath, 'getVars', thisexpname);
    load(fullfile(dpath, [loadmatname '_' thisexpname '.mat'])) %

    animals = infovar.animals;
    brainareasAll = infovar.brainareas;

    dpath = Choosesavedir('figs');
    dpath = fullfile(dpath, 'fig5Suppl' ,thisexpname);
    mkdir(dpath)
    numevents_ds = zeros(numel(Params.trialtypes),numel(animals));
    numpokes_ds = zeros(numel(Params.trialtypes),numel(Params.poketypes),numel(animals));
    for thisses = 1:numel(animals)   % FOR LOOP START through each session
        eventepochs = eventepochsAll{thisses};
        numevents = beh.numevents(:,thisses);
        pokes = beh.pokes(:,thisses);
        numpokes = beh.pokesnum{thisses};
        brainarea = brainareasAll(thisses);

        %%% downsample to match other challenge
        [eventepochs_ds,numevents_ds(:,thisses),pokes_ds,numpokes_ds(:,:,thisses)] =  Downsample_events(Params, eventepochs, numevents, pokes, numpokes);

    end %   FOR LOOP END through each session

    PlotEvents_dsSameChall(Params,infovar,cat(3,beh.pokesnum{:}),numpokes_ds,beh.numevents(3,:),numevents_ds(3,:))

    fprintf('Experiment %s done \n',thisexpname)
    clearvars -except loadmatname explist
end
