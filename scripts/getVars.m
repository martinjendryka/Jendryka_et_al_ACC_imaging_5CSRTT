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

            %--------- vars over all sessions -----------------------------------------
            animals = [animals,varlist.animalnames];
            expdates = [expdates,varlist.expdate];
            ncellsAll = [ncellsAll,varlist.ncells];
            brainareasAll = [brainareasAll,varlist.brainarea];
            taskAll = [taskAll,varlist.taskname];
            reclengthAll = [reclengthAll,size(varlist.casig{1},2)];
            eventlistAll = [eventlistAll,eventlist];
            casigAll = [casigAll,varlist.casig];

            %==========================================================================

            %%% get event numbers and latencies
            numevents = cellfun(@(x) size(x,1), eventlist.eventstrs,'UniformOutput',false);
            numevents = cat(1,numevents{:});
            beh.numevents(:,thisses) = numevents;
            resplat_type = {};
            pokes = cell(1,numel(Params.trialtypes)); % which poke the animal used

            for thistrialtype = 1:numel(Params.trialtypes)
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
                    pokes{thistrialtype} = categorical(eventlist.eventstrs{thistrialtype}(:,3),Params.poketypes);
                end

            end % end for-loop through Params.trialtypes
            beh.resplat(:,thisses) = resplat_type;
            beh.rewlat{:,thisses} = [rewlat,rewoutlat];
            beh.pokes(:,thisses) = pokes;

            a = cellfun(@(x) groupcounts(x,'IncludeEmptyGroups',true),pokes,'UniformOutput',false);
            a{3}= zeros(numel(Params.poketypes),1); % make omission zero cell with same length
            id = find (numevents == 0);
            if ~isempty(id)  && ~(id ==3)
                a{id} = zeros(numel(Params.poketypes),1);
            end
            beh.pokesnum(:,:,thisses) = transpose(cell2mat(a));

            %%% get traces epochs for each trialtype and epochtype
            [eventepochs,eventepochs_pokes] = Geteventepochs(varlist,Params,eventlist,pokes); % cellID X numframes X ntrials

            % for export to mat file
            eventepochsAll{thisses} = eventepochs;
            eventepochsAll_pokes{thisses} = eventepochs_pokes;
            fprintf('Session %s %s finished \n',varlist.animalnames{1}, explist{thisexp})
        end % end for-loop through sessions

        infovar.animals = animals;
        infovar.expdates = expdates;
        infovar.ncells = ncellsAll;
        infovar.brainareas = brainareasAll;
        infovar.reclength = reclengthAll;
        infovar.task = taskAll;
        infovar.casig = casigAll;
        infovar.info = [animals;expdates;brainareasAll;num2cell(reclengthAll);taskAll;num2cell(ncellsAll)];

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

clearvars -except explist
