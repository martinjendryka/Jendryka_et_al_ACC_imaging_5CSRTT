clear,close all,clc

% explist = {'varITILong','cb800ms','cbDeval1','cbExt1','cbExt2','mixedChalls'};

events_otherexp = [];
eventsPoke_otherexp = [];
eventsAvg_otherexp = [];
eventsPokeAvg_otherexp = [];
events_ds = [];
eventsPokes_ds = [];
counter = 1;
for otherexp = {'cbDeval1','cbExt1','cbExt2'}

explist = {'cb800ms'};
loadmatname = 'getVars_4sbf7saf'; % mat file of descr Analysis

dpath = Choosesavedir('outputvars');
dpath = fullfile(dpath, 'getVars', otherexp{1});
load(fullfile(dpath, [loadmatname '_' otherexp{1} '.mat'])) %

%numevents_otherexp_ACC = floor(mean(beh.numevents(:,ismember(infovar.brainareas,{'cingulate'})),2));
%numevents_other= beh.numevents(:,ismember(infovar.brainareas,{'cingulate'}));
%numevents_otherexp_mPFC = floor(mean(beh.numevents(:,ismember(infovar.brainareas,{'prelimbic'})),2));

numpokes_otherexp_ACC = ceil(mean(cat(3,beh.pokesnum{ismember(infovar.brainareas,{'cingulate'})}),3));
numevents_otherexp_ACC = sum(numpokes_otherexp_ACC,2);
numevents_otherexp_ACC(3) = ceil(mean(beh.numevents(3,ismember(infovar.brainareas,{'cingulate'})),2));
numpokes_otherexp_mPFC = ceil(mean(cat(3,beh.pokesnum{ismember(infovar.brainareas,{'prelimbic'})}),3));
numevents_otherexp_mPFC = sum(numpokes_otherexp_mPFC,2);
numevents_otherexp_mPFC(3) = ceil(mean(beh.numevents(3,ismember(infovar.brainareas,{'prelimbic'})),2));

events_otherexp_ACC= beh.numevents(:,ismember(infovar.brainareas,{'cingulate'}));

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
        if ismember(brainarea,{'cingulate'})
            [eventepochs_ds,numevents_ds(:,thisses),pokes_ds,numpokes_ds(:,:,thisses)] =  Downsample_events_to_match_other(Params,eventepochs,numevents,pokes,numpokes,numevents_otherexp_ACC,numpokes_otherexp_ACC);
        else
            [eventepochs_ds,numevents_ds(:,thisses),pokes_ds,numpokes_ds(:,:,thisses)] =  Downsample_events_to_match_other(Params,eventepochs,numevents,pokes,numpokes,numevents_otherexp_mPFC,numpokes_otherexp_mPFC);

        end

    end %   FOR LOOP END through each session
    numpokesAll =   cat(3,beh.pokesnum{:}) ;
    %PlotEvents_dsOtherChall(Params,infovar,numpokesAll,numpokes_ds,beh.numevents(3,:),numevents_ds(3,:),otherexp{1})
    
    numeventsAll= beh.numevents(:,ismember(infovar.brainareas,{'cingulate'}));
    numeventsPokesAll = squeeze(sum(numpokes_ds,1));
    events_otherexp = cat(1,events_otherexp,events_otherexp_ACC); % number of events for each ACC session of the other exp
    eventsAvg_otherexp(:,counter) = numevents_otherexp_ACC; % sum of average of poke events for each trialtype
    events_ds = cat(1,events_ds,numevents_ds(:,ismember(infovar.brainareas,{'cingulate'}))); % number of events of baseline after downsampling
    eventsPokes_ds = cat(1,numeventsPokesAll(:,ismember(infovar.brainareas,{'cingulate'})));

    
    fprintf('Experiment %s done \n',thisexpname)
    clearvars -except loadmatname explist events_otherexp eventsAvg_otherexp events_ds counter
    counter = counter + 1;
    
end
end
    writematrix(events_otherexp,'sheetexp.xlsx','Sheet','otherexp')
    writematrix(eventsAvg_otherexp,'sheetexp.xlsx','Sheet','otherAvg')
    writematrix(events_ds,'sheetexp.xlsx','Sheet','eventsDS')