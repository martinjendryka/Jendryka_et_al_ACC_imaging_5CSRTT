%Kmeanclustering
% cluster event epochs (activity around choice averaged across trials) using k-means clustering
function clusters = Kmeanclustering(Params,infovar,eventepochs)
rng('default')
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
                    epochs_ses_Odd = mean(epochs_ses(:,:,1:2:end),3,'omitnan'); % take average across odd trials
                end
                epochs_avgOdd = cat(1,epochs_avgOdd,epochs_ses_Odd); % concatenate averages
            end

            if all(isnan(epochs_avgOdd),'all')
                continue
            else
                % kmean clustering
                [assignedClass,~,~,~]  = kmeans(epochs_avgOdd,Params.nCluster,'Replicates',100,'Distance','cosine'); %
                %%% give clusters new ids corresppnding to peak latencies
                %%% (essiantial to get same order in heatplots as in paper)
                assignedClass_new = assignedClass;
                if thisarea==1
                    assignedClass_new(assignedClass==2) = 3;
                    assignedClass_new(assignedClass==3) = 2;
                else
                    assignedClass_new(assignedClass==1) = 4;
                    assignedClass_new(assignedClass==2) = 1;
                    assignedClass_new(assignedClass==3) =2;
                    assignedClass_new(assignedClass==4) =3;
                end
                [thisclusterid,thiscellid] = sort(assignedClass_new);
                clusterid(:,thistrialtype,thisepochtype)= thisclusterid;
                cellid(:,thistrialtype,thisepochtype) = thiscellid;
            end
        end
    end
    clusters.clusterid(thisarea) = {clusterid};
    clusters.cellid(thisarea) = {cellid};
end
end