% get traces for epochs (ie. iti,sp,choice and outcome) for each trial type
% (ie. correct, incorrect, omission, premature)
function [eventepochs,eventepochs_pokes] = Geteventepochs(varlist,Params,eventlist,pokes)
trialtypes = Params.trialtypes;
eventepochs = cell(numel(Params.trialtypes),numel(Params.epochtypes));
eventepochs_pokes =  cell(numel(Params.trialtypes),numel(Params.epochtypes));
casig = varlist.casig{1};
numcells = varlist.ncells;

for thistrialtype = 1:numel(trialtypes)
    for thisepochtype = 1:numel(Params.epochtypes)
        epoch = [];
        numframes = Params.frames.num(thisepochtype);
        d = 1:numframes;
        if isempty(eventlist.eventind{thistrialtype}) || ...
                thistrialtype == 4 && thisepochtype == 2
            epoch = nan(numcells,numframes,1);
        else
            eventid = eventlist.eventind{thistrialtype}(:,thisepochtype);

            numevents = numel(eventid);
            thisstart = eventid-Params.frames.bfevent(thisepochtype)-1; % we start from +1, therefore need to substract 1 from start event

            if ismember(thistrialtype,3) && thisepochtype == 3
                thisstart = eventid - Params.f*2; % take start of omission when stimulus light is off 2 sec before limited hold
            end

            eventwindow = thisstart + d;

            for thisevent = 1:numel(eventid)
                epoch(:,:,thisevent) = casig(:,eventwindow(thisevent,:));
            end

        end

        eventepochs{thistrialtype,thisepochtype} = epoch;

        %%% get signal for each poketype
        poke_labels = pokes{thistrialtype};
        if isempty(poke_labels) || isequal(thistrialtype,3) || thistrialtype == 4 && thisepochtype == 2
            continue
        else
            for thispoketype = 1:numel(Params.poketypes)
                idx_poketype = ismember(poke_labels,Params.poketypes(thispoketype));
                eventepochs_pokes{thistrialtype,thisepochtype}{thispoketype}  = epoch(:,:,idx_poketype); % cells X timebins X poketypes
            end
        end
    end
end
end