%%% select times before and after each event (i.e. iti, cue, choice and outcome) for signal extraction
timebfevent = [0,0,4000,0]; %[ms]
timeafevent = [7000,1000,7000,1000];%[ms]

%% SET PARAMETERS ABOVE AS REQUIRED %%%%%%%%%%
setparams % do not change these variables

%% set the experiments you want to process
explist = {'varITILong','cb800ms','cbDeval1','cbExt1','cbExt2','mixedChalls'};

for thisexp = 1:numel(explist)
    %%% get files for loading
    dpath = Choosesavedir('outputvars');
    dpath = fullfile(dpath, 'arrangedData', explist{thisexp});
    filelist = dir(dpath);
    filelist = {filelist.name};
    filelist(ismember(filelist,{'.','..','.DS_store'})) = [];

    %%% pre-allocate variables
    animals = [];
    expdates = [];
    ncellsAll = [];
    brainareasAll = [];
    taskAll = [];
    reclengthAll = [];
    doseAll = [];
    eventlistAll = [];
    casigAll = [];
    eventepochsAll = {};
    eventepochsAll_pokes = {};

    if isempty(filelist)
        continue
    else
        for thisses = 1:numel(filelist)
            thisfile = fullfile(dpath, filelist{thisses});
            load(thisfile,'varlist','eventlist')

            setvars % set some variables from varlist
            setvarsforfunc % set some variables from Params
            %--------- vars over all sessions -----------------------------------------
            animals = [animals,thisanimal];
            expdates = [expdates,thisdate];
            ncellsAll = [ncellsAll,numcells];
            brainareasAll = [brainareasAll,cellstr(thisregion)];
            taskAll = [taskAll,string(thistask)];
            reclengthAll = [reclengthAll,ts];
            eventlistAll = [eventlistAll,eventlist];
            casigAll = [casigAll,{casig}];

            %==========================================================================

            %%% get event numbers and latencies
            numevents = cellfun(@(x) size(x,1), eventlist.eventstrs,'UniformOutput',false);
            numevents = cat(1,numevents{:});
            beh.numevents(:,thisses) = numevents;
            resplat_type = {};
            pokes = cell(1,numel(trialtypes)); % which poke the animal used

            for thistrialtype = 1:numel(trialtypes)
                %%% get behavior variables for each session
                responsetimes = eventlist.eventtime{thistrialtype};

                if ~isequal(thistrialtype,3)
                    resplat = responsetimes(:,3) - responsetimes(:,2);
                    resplat_type{thistrialtype,1} = resplat;
                end

                if isequal(thistrialtype,1)
                    rewlat = responsetimes(:,4) - responsetimes(:,3);
                    rewoutlat = responsetimes(:,5) - responsetimes(:,4);
                end

                if ~isempty(eventlist.eventstrs{thistrialtype})
                    pokes{thistrialtype} = categorical(eventlist.eventstrs{thistrialtype}(:,3),poketypes);
                end

            end % end for-loop through trialtypes
            beh.resplat(:,thisses) = resplat_type;
            beh.rewlat{:,thisses} = [rewlat,rewoutlat];
            beh.pokes(:,thisses) = pokes;

            a = cellfun(@(x) groupcounts(x,'IncludeEmptyGroups',true),pokes,'UniformOutput',false);
            a{3}= zeros(numel(poketypes),1); % make omission zero cell with same length
            id = find (numevents == 0);
            if ~isempty(id)  && ~(id ==3)
                a{id} = zeros(numel(poketypes),1);
            end
            beh.pokesnum(:,:,thisses) = transpose(cell2mat(a));

            %%% get traces epochs for each trialtype and epochtype
            [eventepochs,eventepochs_pokes] = Geteventepochs(varlist,Params,eventlist,pokes); % cellID X numframes X ntrials

            % for export to mat file
            eventepochsAll{thisses} = eventepochs;
            eventepochsAll_pokes{thisses} = eventepochs_pokes;
            fprintf('%s %s finished \n',thisanimal{1},thisdate{1})
        end % end for-loop through sessions

        infovar.animals = animals;
        infovar.expdates = expdates;
        infovar.ncells = ncellsAll;
        infovar.brainareas = brainareasAll;
        infovar.reclength = reclengthAll;
        infovar.task = taskAll;
        infovar.dose = doseAll;
        infovar.casig = casigAll;
        infovar.info = [animals;expdates;brainareasAll;reclengthAll;taskAll;doseAll;num2cell(ncellsAll)];

        % save outputs as mat files
        dpath = Choosesavedir('outputvars');
        dpath = fullfile(dpath, 'getVars',explist{thisexp});
        mkdir(dpath)
        fprintf('exporting to mat file... \n')
        save(fullfile(dpath ,['getVars_4sbf7saf' '_' explist{thisexp},'.mat']),'Params','infovar','beh',...
            'eventepochsAll','eventepochsAll_pokes','eventlistAll');
        fprintf('Experiment %s done \n',explist{thisexp})
        clearvars -except explist Params thisexp
    end
end