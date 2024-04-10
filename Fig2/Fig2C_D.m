function Fig2C_D(Params,varlist,eventepochs,clusters,beh,thisepochtype,selectTrialtype)

%% Fig.2 C,D
% creates a figure with 4 tiles each corresponding to one of the trialtypes (correct,incorrect, omission, premature) for the selected epoch
% zscored calcium activity is averaged across trials and displayed for each timebin for each cell from the ACC (Fig.2C) or mPFC
% (Fig.2D) neurons, sorted by peak latency and cluster id

%%

%%% set directory for storing figures
dpath = Choosesavedir('figs');
dpath = fullfile(dpath, 'Fig2');
numframes = Params.frames.num(thisepochtype);
bfeventframes = Params.frames.bfevent(thisepochtype);
afeventframes = Params.frames.afevent(thisepochtype);

for thisarea = 1:numel(Params.brainareas) % for-loop start through brainareas
    animalselect = find(ismember(varlist.brainareas,Params.brainareas(thisarea)));

    rewlat = median(vertcat(beh.rewlat{ismember(varlist.brainareas,Params.brainareas(thisarea))}),1,'omitnan'); % get the median reward latency for each session

    % get sorting indices corresponding to cluster id and peak latency
    thiscluster = clusters.clusterid{thisarea}(:,3,selectTrialtype);
    clustersortidx = clusters.cellid{thisarea}(:,3,selectTrialtype);
    ncellsCluster = groupcounts(thiscluster);
    epochs_avgOdd = [];
    for thisses = animalselect
        epochs_ses = eventepochs{thisses}{1,3};
        if size(epochs_ses,3)< 2 % if there is <2 trials, average across odd trials cannot be calculated, so put them nan (will be plotted grey in heatplot)
            epochs_ses_Odd = nan(size(epochs_ses,[1,2]));
        else
            epochs_ses_Odd = mean(epochs_ses(:,:,1:2:end),3); % take average across odd trials
        end
        epochs_avgOdd = cat(1,epochs_avgOdd,epochs_ses_Odd); % concatenate averages
    end
    %%% for each cluster, sort by peaklatency
    sortidx=[];
    for k = 1:Params.nCluster
        thiscells = clustersortidx(thiscluster==k);
        epochsMean_cluster=epochs_avgOdd(thiscells,:);
        [~,maxidx_cl] = max(epochsMean_cluster,[],2);
        [~,sortpeaklat_cl] = sort(maxidx_cl);
        sortidx = [sortidx;thiscells(sortpeaklat_cl)];
    end

    figure
    t = tiledlayout(1,numel(Params.trialtypes));
    xlabel(t,'Time from task event (s)')
    ylabel(t,'Cell ID')


    for thistrialtype = 1:numel(Params.trialtypes)
        epochs_avgEven = [];
        for thisses = animalselect
            epochs_ses = eventepochs{thisses}{thistrialtype,thisepochtype};
            if size(epochs_ses,3)< 2 % if there is <2 trials, average across odd trials cannot be calculated, so put them nan (will be plotted grey in heatplot)
                epochs_ses_Even =  nan(size(epochs_ses,[1,2]));
            else
                epochs_ses_Even = mean(epochs_ses(:,:,2:2:end),3); % take average across even trials
            end
            epochs_avgEven = cat(1,epochs_avgEven,epochs_ses_Even);
        end

        epochs_avgSort = epochs_avgEven(sortidx,:);

        h(thistrialtype) = nexttile;
        im = imagesc(h(thistrialtype),epochs_avgSort);
        set(im, 'AlphaData', ~isnan(epochs_avgSort))%%% required to plot nan values black
        set(gca, 'Color', [0.7,0.7, 0.7]) %%% required to plot nan values black
        box off
        set(gca,'TickDir','out');

        if ~(thistrialtype==1)
            yticklabels('')
        end
        yline(ncellsCluster(1),'LineWidth',2,'Color','g')
        yline(sum(ncellsCluster(1:2)),'LineWidth',2,'Color','g')
        yline(sum(ncellsCluster(1:3)),'LineWidth',2,'Color','g')

        caxis([-1 7])

        %%% get latencies depending on trial and epochtype
        lat1 = nan;
        lat2 = nan;
        lat3 = nan;

        if thisepochtype == 3 && thistrialtype==1
            resplat = cellfun(@(x) median(x,'omitnan'),beh.resplat(1,animalselect));
            resplat = median(resplat);
          
            lat1 = resplat;
            lat2 = rewlat(1);
            lat3 = lat2 + rewlat(2);
        elseif thisepochtype == 3   && thistrialtype == 2
            resplat = cellfun(@(x) median(x,'omitnan'),beh.resplat(thistrialtype,animalselect));
            resplat = median(resplat);
          
            lat1= resplat;
            lat3 = 5000;
        elseif thisepochtype == 3  && thistrialtype == 3
            lat1= 2000;
            lat3 = lat1 +5000;
        elseif thisepochtype == 1 && thistrialtype==4
            resplat = cellfun(@(x) median(x,'omitnan'),beh.resplat(thistrialtype,animalselect));
            resplat = median(resplat);

        elseif thisepochtype == 3 && thistrialtype==4
            lat3 = 5000;
        end

        if bfeventframes ~= 0
            zeroline = bfeventframes+1;
            xline(zeroline)
        else
            zeroline=0;
        end

        if thisepochtype == 3
            xline(zeroline-lat1/Params.timebinlength,'LineWidth',1)
        else
            xline(zeroline+lat1/Params.timebinlength,'LineWidth',1)
        end

        %% plot latencies into figures as solid vertical lines
        xline(zeroline+lat2/Params.timebinlength,'LineWidth',1)
        xline(zeroline+lat3/Params.timebinlength,'LineWidth',1)
        title(Params.trialtypes(thistrialtype))
        xticks(1:5:numframes)
        xticklabels(-bfeventframes*Params.timebinlength/1000:afeventframes*Params.timebinlength/1000)

        if thisarea==2
            yticks(0:20:size(epochs_avgSort,1))
        end
    end

    set(h,'Colormap',bluewhitered)
    colorbar
    if thisarea==1
        fname = fullfile(dpath , 'Fig2C');
    else
        fname = fullfile(dpath , 'Fig2D');
    end
    set(gcf, 'InvertHardCopy', 'off'); % so that grey is not inverted to white after saving graphics
    print(gcf,'-vector','-dpdf',[fname,'.pdf'])
end
end