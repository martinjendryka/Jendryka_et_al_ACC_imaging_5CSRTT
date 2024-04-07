function [eventepochs_ds, numevents_ds, pokes_ds, numpokes_ds] = Downsample_events(Params, eventepochs, numevents, pokes, numpokes)

% Calculate total events per poke hole for each event type
totalEventsPerPoke = sum(numpokes, 2); % Sum across rows for each event type

% Initialize downsampled outputs
numevents_ds = numevents;
eventepochs_ds = eventepochs;
numpokes_ds = numpokes;
pokes_ds = pokes;

% Iterate over each event type
for thistrialtype = 1:numel(Params.trialtypes)
    % Skip if there are no events for this trial type or if numevents is zero
    if isempty(pokes{thistrialtype}) || numevents(thistrialtype) == 0
        continue;
    end

    % Determine the target number of events based on the minimum across poke holes for this event type
    targetEvents = min(numpokes_ds(thistrialtype, :));
    if targetEvents < 3 
        targetEvents = 3;
    end

    % Adjust for each poke type
    for thispoke = 1:numel(Params.poketypes)
        poke_events = pokes_ds{thistrialtype};
        ind_poke = find(poke_events == Params.poketypes(thispoke));

        numPokeEvents = numel(ind_poke);

        if numPokeEvents > targetEvents
            eventsToRemove = numPokeEvents - targetEvents;
            ind = randsample(numel(ind_poke), eventsToRemove);
            indToRemove = ind_poke(ind);

            % Remove events for this poke type
            poke_events(indToRemove) = [];
            pokes_ds{thistrialtype} = poke_events;

            % Downsample eventepochs by removing selected indices
            for thisepochtype = 1:numel(Params.epochtypes)
                if thisepochtype == 2 && thistrialtype ==4
                    % Skip downsampling for epochtype 2 if its for
                    % premature responses (since not existing)
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
targetOmissions = sum(numevents_ds([1,2,4]));
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