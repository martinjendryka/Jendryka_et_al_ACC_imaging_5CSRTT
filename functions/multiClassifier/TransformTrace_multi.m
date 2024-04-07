function tb_set = TransformTrace_multi(Params,eventepochs)


for thisepochtype = 1:numel(Params.epochtypes)
    numframes = Params.frames.num(thisepochtype);
    % concat traces of trials
    dataset = catpad(3,eventepochs{:,thisepochtype});

    % re-arrange array -> numevents x numbins x numcells
    dataset = permute(dataset,[3,2,1]);
    
    %     arrange so that each cell corresponds to one timebin containing a
    %     matrix trials x cells
    for thistimebin = 1: numframes
        tb_set(thisepochtype,thistimebin) = {permute(dataset(:,thistimebin,:),[1,3,2])};
    end
end
end