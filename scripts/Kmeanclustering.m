%Kmeanclustering
% cluster event epochs (activity around choice averaged across trials) using k-means clustering
function clusters = Kmeanclustering(Params,infovar,eventepochs)

for thisarea = 1:numel(Params.brainareas)

    clusterid = [];
    cellid = [];

    animalselect = find(ismember(infovar.brainareas,Params.brainareas(thisarea)));

    for thisepochtype = 1:numel(Params.epochtypes)
        for thistrialtype = 1:numel(Params.trialtypes)
            
            epochs_avgOdd=[];

            for thisses = animalselect

                epochs_ses = eventepochs{thisses}{thistrialtype,thisepochtype};
                if size(epochs_ses,3)< 2 % if there is <2 trials, average across odd trials cannot be calculated, so put them nan (will be plotted grey in heatplot)
                    epochs_ses_Odd = nan(size(epochs_ses,[1,2]));
                else
                    epochs_ses_Odd = mean(epochs_ses(:,:,1:2:end),3); % take average across odd trials
                end
                epochs_avgOdd = cat(1,epochs_avgOdd,epochs_ses_Odd); % concatenate averages
            end
            if all(isnan(epochs_avgOdd),'all')
                continue
            else
            % kmean clustering
            [assignedClass,clusterCenters,s,d]  = kmeans(epochs_avgOdd,Params.nCluster,'Distance','cosine');  
            [thisclusterid,thiscellid] = sort(assignedClass);
            clusterid(:,thisepochtype,thistrialtype)= thisclusterid;
            cellid(:,thisepochtype,thistrialtype) = thiscellid;
            end
        end
    end
    clusters.clusterid(thisarea) = {clusterid};
    clusters.cellid(thisarea) = {cellid};
end
end