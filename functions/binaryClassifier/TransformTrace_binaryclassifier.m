function [tb_set,setlabel] = TransformTrace_binaryclassifier(Params,eventepochs,numevents)
%% re-arranges calcium signal arrays so that each timebin contains an array with dimension trials x cells
%% outputs re-arranged array and labels for each trial

for thisepochtype = 1:numel(Params.epochtypes)
    numframes = Params.frames.num(thisepochtype);
    
    setlabel = repelem(Params.trialtypes',numevents); % repeats trialtypes names corresponding to event number (if 0 will be not repeated)
    
    dataset = cat(3,eventepochs{:,thisepochtype});    % concat traces of trials
    dataset = permute(dataset,[3,2,1]);   % re-arrange array -> numevents x numbins x numcells
    nanrow = all(isnan(dataset),[2,3]);  % find nan rows corresponding to trialtypes with no events
    dataset(nanrow,:,:) = [];
   
    for thistimebin = 1: numframes  %     arrange so that each cell corresponds to one timebin containing a
                                    %     matrix trials x cells
       x =  dataset(:,thistimebin,:);
       tb_set(thisepochtype,thistimebin) = {permute(x,[1,3,2])};
    end
end
end