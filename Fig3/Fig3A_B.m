function Fig3A_B(Params,varlist,classifier,beh,thisepochtype)

%% Fig.3 A,B
% plots the decoding accuracy for binary classifiers in predicting the
% trialtype (eg. corrects vs omissions) for each timebin during the
% selected epoch type for the ACC(Fig.3A) or mPFC(Fig.3B)

%%
% specify  directory to save figures in
dpath = Choosesavedir('figs');
dpath = fullfile(dpath, 'Fig3');
dpathexcel = Choosesavedir('excel');
dpathexcel = fullfile(dpathexcel, 'Fig3');

mkdir(dpath)
mkdir(dpathexcel)

pdecod = classifier.pdecod;
pdecodShuffled = classifier.pdecodShuffled;

% required for plotting significance dots and color of line plots
A=[8 12 16]; % three sizes for p=0.05, p=0.01, p =0.001, p= 0.0001
clrsEpochs = [0 0 0;... % black
    1 0 1;... % magenta
    ];

numframes = Params.frames.num(thisepochtype);
bfeventframes = Params.frames.bfevent(thisepochtype);
afeventframes = Params.frames.afevent(thisepochtype);
for thisarea = 1:numel(Params.brainareas) % for-loop through brain areas
    animalselect = find(ismember(varlist.brainareas,Params.brainareas(thisarea))); % get indices for animals with same brain area
    rewlat = cellfun(@(x) median(x,1,'omitnan'),beh.rewlat(animalselect),'UniformOutput',false);
    rewlat = median(cat(1,rewlat{:}),1); % reward latencies
    szAnimals = [];

    figure
    hold on
    counter2 = 1;
    allcmbstrs = [];
    d=0;

    for thisbinaryclassifier = [2,3] % for-loop thorough binary classifiers (Correct vs omission and correct vs premature responses
        cmbstr = horzcat(Params.trialtypes{Params.trialcombs(thisbinaryclassifier,:)});
        allcmbstrs = [allcmbstrs,cellstr(cmbstr)];
        daCat=[];
        daCatShuffled = [];

        xvalues=1:numframes;

        if bfeventframes ~= 0
            zeroline = bfeventframes+1;
        else
            zeroline=0;
        end

        xvalue_std = [xvalues, fliplr(xvalues)];

        thisepochstrs = char(Params.epochtypes(thisepochtype));
       

        da_comb = squeeze(pdecod(thisbinaryclassifier,thisepochtype,animalselect));
        da_combShuffled = squeeze(pdecodShuffled(thisbinaryclassifier,thisepochtype,animalselect));
        emptyses = cell2mat(cellfun(@(x) isempty(x),da_comb,'UniformOutput',false));

        da = cellfun(@(x) mean(x,2), da_comb(~emptyses),'UniformOutput',false);
        da = cat(2,da{:});
        daShuffled = cellfun(@(x) mean(x,2), da_combShuffled(~emptyses),'UniformOutput',false);
        daShuffled = cat(2,daShuffled{:});
        animalsExport = varlist.animals(animalselect(~emptyses));
        brainExport = varlist.brainareas(animalselect(~emptyses));
        taskExport = cellstr(varlist.task(animalselect(~emptyses)));

        %%% stores the decoding accuracies in a table and exports it to
        %%% excel
        true_shuffle_label = [repelem({'real'},numel(animalsExport),1);...
            repelem({'shuffle'},numel(animalsExport),1)];
        tbl_ = table(repmat(animalsExport,1,2)',repmat(taskExport,1,2)',repmat(brainExport,1,2)',true_shuffle_label,'VariableNames',{'animals','task','brainarea','real/shuffle'});
        tblexport = [tbl_,array2table([da';daShuffled'])];
        writetable(tblexport,fullfile(dpathexcel,['Fig3A_B_'  '.xlsx']),'Sheet',[char(join(Params.trialtypes(Params.trialcombs(thisbinaryclassifier,:)))),Params.brainareas{thisarea}])

        %%% make line plots with shaded errors

        daAvg = mean(da,2,'omitnan'); % average across animals
        daErr = std(da,[],2,'omitnan');
        daErr = daErr/sqrt(size(da,2)); % calculate sem
        daAvgShuffled = mean(daShuffled,2,'omitnan');
        daErrShuffled = std(daShuffled,[],2,'omitnan');
        daErrShuffled = daErrShuffled/sqrt(size(daAvgShuffled,2));

        avg_traces = daAvg';
        errortype = daErr';

        errorPlus = avg_traces + errortype;
        errorMinus = avg_traces - errortype;

        inBetween = [errorPlus,fliplr(errorMinus)];
        fill(xvalue_std,inBetween,clrsEpochs(counter2,:),'linestyle', 'none',...
            'FaceAlpha',0.2);
        h(counter2) = plot(xvalues,avg_traces,'LineWidth',1,'Color',clrsEpochs(counter2,:));

        % shuffled data
        avg_traces = daAvgShuffled';
        errortype = daErrShuffled';

        errorPlus = avg_traces + errortype;
        errorMinus = avg_traces - errortype;

        inBetween = [errorPlus,fliplr(errorMinus)];

        fill(xvalue_std,inBetween,clrsEpochs(counter2,:),'linestyle', 'none',...
            'FaceAlpha',0.2);
        h(counter2+2) = plot(xvalues,avg_traces,'LineWidth',1,'Color',clrsEpochs(counter2,:),'LineStyle','--');


        %%% ttest between real and shuffled accuracies for each
        %%% epochtype
        [~,pvals]= ttest(da,daShuffled,'Dim',2);

        thispvals = pvals';

        %%% Benjamini-Hochberg multiple comparison across timebins
        [~,pvalsRank] = sort(thispvals);

        bjh = pvalsRank/numframes*0.05; % benjamini-hochberg critical value = (rank/number of pvals)*FDR
        criticalValue = max(thispvals(bjh>thispvals));
        pvals_sig = thispvals;

        if ~isempty(criticalValue)
            pvals_sig(thispvals<=criticalValue & thispvals<0.05) = 0.05;
            pvals_sig(thispvals<=criticalValue & thispvals<0.01) = 0.01;
            pvals_sig(thispvals<=criticalValue & thispvals<0.001) = 0.001;
        else
            pvals_sig(thispvals<0.05) = 0.05;
            pvals_sig(thispvals<0.01) = 0.01;
            pvals_sig(thispvals<0.001) = 0.001;
        end

        y = 1.2 + d; % required to set where significance dots are plotted

        plot(xvalues(pvals_sig==0.05),y*ones(sum(pvals_sig==0.05),1),'.','MarkerSize',A(1),'Color',clrsEpochs(counter2,:));
        plot(xvalues(pvals_sig==0.01),y*ones(sum(pvals_sig==0.01),1),'.','MarkerSize',A(2),'Color',clrsEpochs(counter2,:));
        plot(xvalues(pvals_sig==0.001),y*ones(sum(pvals_sig==0.001),1),'.','MarkerSize',A(3),'Color',clrsEpochs(counter2,:));

        d = d + 0.02; % required to prevent significance dots being plotted on top of each other

        counter2 = counter2 +1;
    end
    ylim([0 1.4])
    yticks(0:0.2:1)
    xticks(1:5:numframes)
    xlim([0,numframes])

    % add latencies to plot as vertical lines
    lat1 = nan;
    lat2 = nan;
    lat3 = nan;

    if thisepochtype == 3
        resplat = cell2mat(cellfun(@(x) median(x,'omitnan'),beh.resplat(1,animalselect),'UniformOutput',false));
        resplat = median(resplat);

        lat1 = resplat;
        lat2 = rewlat(1);
        lat3 = lat2 + rewlat(2);

    elseif thisepochtype == 1
        resplat = cell2mat(cellfun(@(x) median(x,'omitnan'),beh.resplat(4,animalselect),'UniformOutput',false));
        resplat = median(resplat);

        lat1= resplat;
    end

    xline(zeroline)

    if thisepochtype == 3
        xline(zeroline-lat1/Params.timebinlength,'LineWidth',1)
    else
        xline(zeroline+lat1/Params.timebinlength,'LineWidth',1)
    end


    xline(zeroline+lat2/Params.timebinlength,'LineWidth',1)
    xline(zeroline+lat3/Params.timebinlength,'LineWidth',1)
    if bfeventframes==0
        xticklabels(bfeventframes*Params.timebinlength/1000:afeventframes*Params.timebinlength/1000)

    else
        xticklabels(-bfeventframes*Params.timebinlength/1000:afeventframes*Params.timebinlength/1000)
    end
    legend(h,repmat(allcmbstrs,1,2),'Location','northeastoutside')

    set(gca,'fontname','arial')
    set(gca,'linewidth',0.8)
    set(gca,'fontsize',11)
    set(gca,'TickDir','out');
    set(gca,'box','off')
    xlabel('Time relative to task event (s)')
    ylabel('Decoding accuracy (%)')
    if thisarea ==1
        fname= fullfile(dpath,['Fig3A_',char(Params.epochtypes(thisepochtype))]);
    else
        fname= fullfile(dpath,['Fig3B_',char(Params.epochtypes(thisepochtype))]);
    end
    print(gcf,'-vector','-dpdf',[fname,'.pdf'])
end
end