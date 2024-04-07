function [varlist,eventlist]= Extractevents(thisdatalist,varlist,eventlist)
% pre-allocate output variables
eventlist.eventstrs= cell(4,size(thisdatalist,1)); % 4 for four trial types
eventlist.eventtime = cell(4,size(thisdatalist,1));
eventlist.eventind =  cell(4,size(thisdatalist,1)); % indices for events in dattime
eventlist.eventdattime= cell(4,size(thisdatalist,1));
pycoeventstrs = {'Correct_response','Incorrect_response','omission','Premature_response'}; % dont change, PyCo strings

for thisses = 1:size(thisdatalist,1)
    casig = varlist.casig{thisses};
    if isnan(casig)
        sprintf('%s traces missing',thisdatalist{thisses,1})
        continue
    end
    thisdt = varlist.dt{thisses};
     % delete rows before first and after last trial (to remove open end)
    ind_iti = find(ismember(thisdt.Eventname,{'iti_start_time'}));
    rmvtrial = ind_iti(1)-2; % rmw all rows before first iti
    thisdt(1:rmvtrial,:)=[];
    ind_iti = find(ismember(thisdt.Eventname,{'iti_start_time'}));
    rmvtrial = ind_iti(end)-1; % remove all rows after last iti
    thisdt(rmvtrial:size(thisdt,1),:)=[];
    
    unwantedstrs2 = thisdt.Eventname(contains(string(thisdt.Eventname),[":","frame"]));
    thisdt(ismember(thisdt.Eventname,unwantedstrs2),:) = [];
    dattime = varlist.ts{thisses};
        
    % the frame difference between response and ITI start or stimulus
    % presentation is not constant, need to filtered by finding closes
    % value to respective response
    ind_alliti = find(ismember(thisdt.Eventname,'iti_start_time'))-1;
    ind_allstimulus = find(ismember(thisdt.Eventname,'Sample_state'));
    
    %%% for loop start
    %
    c=1;
    strs_all={};
    timepoints_all = {};
    for thisstr =  string(pycoeventstrs)
        ind_thisstr = find(ismember(thisdt.Eventname,thisstr)); % indices with event strings

        if isempty(ind_thisstr)
            eventlist.eventstrs(c,thisses) = {repmat('',1,5)};
            eventlist.eventtime(c,thisses) = {nan(1,5)};
            eventlist.eventdattime(c,thisses) = {nan(1,5)};
            c = c + 1;
            continue
        end
        
        %filter ITIs and Sample_state for the respective trial type
        closestind =[];
        closestind2 =[];
        closestind3 =[];
        for i = 1: numel(ind_thisstr)
            % for ITI
            closestind(i)= Findclosestval(ind_alliti,ind_thisstr(i),1);
            
            % for stimulus
            if ~ismember(thisstr,{'Premature_response'})
                closestind2(i)= Findclosestval(ind_allstimulus,ind_thisstr(i),1);
                ind_stimulus = ind_allstimulus(closestind2);
                strs_stimulus = thisdt.Eventname(ind_stimulus);
                timepoints_stimulus = thisdt.Eventtime(ind_stimulus);
            end
        end
        
        % ITI
        ind_iti = ind_alliti(closestind);
        strs_iti = thisdt.Eventname(ind_iti);
        timepoints_iti = thisdt.Eventtime(ind_iti);
        
        % no stimulus presentation in premature trials, instead vectors are
        % filled with iti strings and timepoints
        if ismember(thisstr,{'Premature_response'})
            strs_stimulus = strs_iti;
            timepoints_stimulus = timepoints_iti;
        end
        
        % choice (pokes or omissions)
        if ismember(thisstr,{'omission'})
            ind_choice = ind_thisstr;
        else
            ind_choice = ind_thisstr -1;
        end
        strs_choice = thisdt.Eventname(ind_choice);
        timepoints_choice = thisdt.Eventtime(ind_choice);
  
        % outcome (rewards or penalties) 
        if ismember(thisstr,{'Correct_response'})
            ind_outcome = find(ismember(thisdt.Eventname,'Reward_taken'))-1;
            ind_outcomeend = find(ismember(thisdt.Eventname,'Reward_taken'))+1;
        else % in penalties outcome is same as choice
            ind_outcome = ind_choice; % in penalty trials timeout occurs simultaneously at choice
            for i = 1:numel(ind_outcome) % find index for iti_start following timeout
                closestind3(i)= Findclosestval(ind_alliti,ind_outcome(i),-1);
            end
            ind_outcomeend= ind_alliti(closestind3);
        end

        strs_outcome = [thisdt.Eventname(ind_outcome),...
            thisdt.Eventname(ind_outcomeend)];
        timepoints_outcome = [thisdt.Eventtime(ind_outcome),...
            thisdt.Eventtime(ind_outcomeend)];
        % merge all together
        strs_merged = [strs_iti,strs_stimulus,strs_choice,strs_outcome];
        timepoints_merged = [timepoints_iti,timepoints_stimulus,...
            timepoints_choice,timepoints_outcome];
        
        %%% check for errors
        %
        %%% a) erroneous latencies
        % eg. exclude if difference is too low or if reward latency is larger than 5000ms
        
        difftime = diff(timepoints_merged,[],2);

        % no times must be negative
        if strcmp(thisstr,'Correct_response') % for correct trials
            rmvind = difftime<=200 | difftime(:,3)>=5000; % delete trials with response latencies <200ms and reward latencies >5000ms
        else % all other trials
            % column 3 of difftime is always zero since choice and outcome have same timepoint,
            %in prematures column 1 is always zero since iti and stimulus presentation were given same timepoint
            rmvind = difftime<0 | difftime(:,2)<=200 | difftime(:,4)>=5010 | difftime(:,4)<=4990; % mustnt be: response latency <200ms, timeout < 4990ms or >5010
        end
        
        [wrongdiffs_ind,~,~] = find(rmvind); % give me row index of difftimes that are erroneous
        
        timepoints_merged(unique(wrongdiffs_ind),:)=[];
        strs_merged(unique(wrongdiffs_ind),:) = [];
        
        if  ~isequal(size(timepoints_merged,2),5) % there should be always 5 values
            error('timepoints miss states')
        end
        
        % find for each PyControl timepoint the corresponding DAQtime
        % timepoint
        w = size(timepoints_merged,2);
        l = size(timepoints_merged,1);
        ind_dattime = nan(l,w);
        
        for i = 1: w
            for ii = 1:l
                ind_dattime(ii,i) = Findclosestval(dattime,timepoints_merged(ii,i),0); % this is the event index
            end
        end
        
        dattimeevents = dattime(ind_dattime);
        dattimeevents(ind_dattime==1)= nan;
        if isempty(dattimeevents)
            dattimeevents = nan;
        end
        % if there is only one trial, indexing into the matrix makes a
        % column vector (we need a row vector)
        if  ~isequal(size(dattimeevents,2),5)
            dattimeevents = dattimeevents';
        end
        %%% b) erroneous timestamp differences between DAQ and PyCo
        % caused by frame drops in DAQ timestamp, also in some sessions DAQ
        % timestamps are less frequent than PyCo timestamps(likely caused by
        % LED issues)
        % update from 5.8.2021: shouldnt occur anymore since dropped frames are filled
        
        difftime = abs(dattimeevents - timepoints_merged);
        
        [difftimeexclude,~,~]=find(difftime>200);
        if ~isempty(difftimeexclude)
            error('there are still dropped frames')
        end
        
        eventlist.eventstrs(c,thisses) = {strs_merged};
        eventlist.eventtime(c,thisses) = {timepoints_merged};
        eventlist.eventind(c,thisses) = {ind_dattime};
        eventlist.eventdattime(c,thisses) = {dattimeevents};        
        c = c +1;
        
    end % loop for each trial type
end
end