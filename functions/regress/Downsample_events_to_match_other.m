function [eventepochs_ds, numevents_ds, pokes_ds, numpokes_ds] = Downsample_events_to_match_other(Params, eventepochs, numevents, pokes, numpokes, numevents_otherExp, numpokes_otherExp)

% Initialize downsampled outputs
numevents_ds = numevents;
eventepochs_ds = eventepochs;
numpokes_ds = numpokes;
pokes_ds = pokes;

% Adjust the target number of omissions based on the other experiment, ensuring a minimum of 3


% Iterate over each event type excluding omissions
for thistrialtype = 1:numel(Params.trialtypes)
    if thistrialtype == 3 %%% downsampling for omissions
        continue % continue with next trialtype 
    end
    
    % Adjust the target events per poke hole based on the other experiment, ensuring a minimum of 3
    targetEvents = min(numpokes_otherExp(thistrialtype, :));
    if targetEvents <3
        targetEvents = 3;
    end
    % Adjust for each poke type
    for thispoke = 1:numel(Params.poketypes)
        % Calculate number of events to remove to match the target from the other experiment
        currentEvents = numpokes_ds(thistrialtype, thispoke);
        eventsToRemove = currentEvents - targetEvents;

        if eventsToRemove > 0
            poke_events = pokes_ds{thistrialtype};
            ind_poke = find(poke_events == Params.poketypes(thispoke));
            if numel(ind_poke) < eventsToRemove
                warning('Not enough events to remove to match the target.');
                continue;
            end
            ind = randsample(numel(ind_poke), eventsToRemove);
            indToRemove = ind_poke(ind);

            % Update pokes_ds
            poke_events(indToRemove) = [];
            pokes_ds{thistrialtype} = poke_events;

            % Downsample eventepochs by removing selected indices
            for thisepochtype = 1:numel(Params.epochtypes)
                if thisepochtype == 2 && thistrialtype == 4
                    continue
                else
                    currentEpochs = eventepochs_ds{thistrialtype, thisepochtype};
                    currentEpochs(:, :, indToRemove) = [];
                    eventepochs_ds{thistrialtype, thisepochtype} = currentEpochs;
                end
            end

            % Update counts
            numevents_ds(thistrialtype) = numevents_ds(thistrialtype) - eventsToRemove;
            numpokes_ds(thistrialtype, thispoke) = numpokes_ds(thistrialtype, thispoke) - eventsToRemove;
        end
    end
end

currentEvents = numevents_ds(3);
% targetOmissions = sum(numevents_ds([1,2,4]));
targetOmissions = numevents_otherExp(3);
if currentEvents > targetOmissions % if more events than in the other exp, downsample to the number of omissions of the other exp
    eventsToRemove = currentEvents - targetOmissions;
    indToRemove = randsample(currentEvents,eventsToRemove);
    for thisepochtype = 1:numel(Params.epochtypes)
        currentEpochs = eventepochs_ds{3, thisepochtype};
        currentEpochs(:, :, indToRemove) = [];
        eventepochs_ds{3, thisepochtype} = currentEpochs;
    end
    numevents_ds(3) = targetOmissions;
    pokes_ds{3}(indToRemove) = [];
end

end