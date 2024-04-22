function Fig4D(Params,varlist,classifier_alltrials,classifier_corrects,beh,thisepochtype)

%% Fig.4D
% creates a figure with 2 tiles (left:ACC, right:mPFC) each with two line
% plots showing the performance in correctly prediciting the poketype
% label for a classifier (black) trained and tested including all trials and a
% classifier (blue) trained and tested including only correct trials


%%
dpath = Choosesavedir('figs');
dpath = fullfile(dpath, 'Fig4');
dpathexcel = Choosesavedir('excel');
dpathexcel = fullfile(dpathexcel, 'Fig4');

mkdir(dpath)
mkdir(dpathexcel)

pdecod_alltrials = classifier_alltrials.pdecod; % epochtypes x thisses
pdecodShuffled_alltrials = classifier_alltrials.pdecodShuffled;
pdecod_corrects= classifier_corrects.pdecod; % epochtypes x thisses
pdecodShuffled_corrects = classifier_corrects.pdecodShuffled;

numframes = Params.frames.num(thisepochtype);
bfeventframes = Params.frames.bfevent(thisepochtype);
afeventframes = Params.frames.afevent(thisepochtype);
xvalues=1:numframes;

if bfeventframes ~= 0
    zeroline = bfeventframes+1;
else
    zeroline=0;
end

xvalue_std = [xvalues, fliplr(xvalues)];

A=[8 12 16]; % three sizes for p=0.05, p=0.01, p =0.001, p= 0.0001
clrs_lines = [0 0 0;... % black -> classifier included all trials
    0 0.4470 0.7410;... % blue -> classifier included only correct trials
    ];

tiledlayout(1,2)

for thisarea = 1:numel(Params.brainareas)
    thisareastr = Params.brainareas{thisarea};
    animalselect= find(ismember(varlist.brainareas,Params.brainareas(thisarea)));

    %%% plot averages
    nexttile
    hold on
    d=0;

    for i =1:2
        if i==1
            pdecod_epoch = pdecod_alltrials(thisepochtype,animalselect); %  timebins X iterations
            pdecod_epochShuffled = pdecodShuffled_alltrials(thisepochtype,animalselect);

        else
            pdecod_epoch = pdecod_corrects(thisepochtype,animalselect); %  timebins X iterations
            pdecod_epochShuffled = pdecodShuffled_corrects(thisepochtype,animalselect);
        end

        emptyses =  cell2mat(cellfun(@(x) isempty(x),pdecod_epoch,'UniformOutput',false));
        animalselect_noempty = find(~emptyses); % remove empty cells
        pdecod_epoch =  pdecod_epoch (animalselect_noempty);
        pdecod_epochShuffled = pdecod_epochShuffled(animalselect_noempty); %  timebins X iterations

        da = cellfun(@(x) mean(x,2),pdecod_epoch,'UniformOutput',false); % average across iterations
        da = cat(2,da{:});
        daShuffled = cellfun(@(x) mean(x,2),pdecod_epochShuffled,'UniformOutput',false); % average across iterations
        daShuffled = cat(2,daShuffled{:});

        daAvg = mean(da,2); % average across animals
        daErr = std(da,[],2);
        daErr = daErr/sqrt(size(da,2));
        daAvgShuffled = mean(daShuffled,2);
        daErrShuffled = std(daShuffled,[],2);
        daErrShuffled = daErrShuffled/sqrt(size(daAvgShuffled,2));

        avg_traces = daAvg';
        errortype = daErr';

        errorPlus = avg_traces + errortype;
        errorMinus = avg_traces - errortype;

        inBetween = [errorPlus,fliplr(errorMinus)];

        fill(xvalue_std,inBetween,clrs_lines(i,:),'linestyle', 'none',...
            'FaceAlpha',0.2);
        plot(xvalues,avg_traces,'LineWidth',1,'Color',clrs_lines(i,:));

        % shuffled data
        avg_traces = daAvgShuffled';
        errortype = daErrShuffled';

        errorPlus = avg_traces + errortype;
        errorMinus = avg_traces - errortype;

        inBetween = [errorPlus,fliplr(errorMinus)];

        fill(xvalue_std,inBetween,clrs_lines(i,:),'linestyle', 'none',...
            'FaceAlpha',0.2);
        plot(xvalues,avg_traces,'LineWidth',1,'Color',clrs_lines(i,:),'LineStyle','--');


        %%% ttest between real and shuffled accuracies for each
        %%% epochtype, multiple comparison using benjamini hochberg
        %%% across timebins
        [~,pvals]= ttest(da,daShuffled,'Dim',2);

        thispvals = pvals';

        %%% Benjamini-Hochberg multiple comparison procedure
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

        y = 1 + d;

        plot(xvalues(pvals_sig==0.05),y*ones(sum(pvals_sig==0.05),1),'.','MarkerSize',A(1),'Color',clrs_lines(i,:));
        plot(xvalues(pvals_sig==0.01),y*ones(sum(pvals_sig==0.01),1),'.','MarkerSize',A(2),'Color',clrs_lines(i,:));
        plot(xvalues(pvals_sig==0.001),y*ones(sum(pvals_sig==0.001),1),'.','MarkerSize',A(3),'Color',clrs_lines(i,:));

        d = d + 0.025;
    end

    ylim([0 1.1])
    yticks(0:0.2:1)
    xticks(1:5:numframes)
    xlim([0,numframes])

    % add latencies as vertical lines to plot
    rewlat = cellfun(@(x) median(x,1,'omitnan'),beh.rewlat(animalselect(~emptyses)),'UniformOutput',false);
    rewlat = median(cat(1,rewlat{:}),1);

    lat1 = nan;
    lat2 = nan;
    lat3 = nan;

    if thisepochtype == 3
        resplat = cellfun(@(x) median(x,'omitnan'),beh.resplat(1,animalselect(~emptyses)),'UniformOutput',false);
        resplat = median(cell2mat(resplat));

        lat1 = resplat;
        lat2 = rewlat(1);
        lat3 = lat2 + rewlat(2);

    elseif thisepochtype == 1
        resplat = cellfun(@(x) median(x,'omitnan'),beh.resplat(4,animalselect(~emptyses)),'UniformOutput',false);
        resplat = median(cell2mat(resplat));
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

    xticklabels(-bfeventframes*Params.timebinlength/1000:afeventframes*Params.timebinlength/1000)
    set(gca,'fontname','arial')
    set(gca,'linewidth',0.8)
    set(gca,'fontsize',11)
    set(gca,'TickDir','out');
    set(gca,'box','off')

    xlabel('Time relative to task event (s)')
    ylabel('Decoding accuracy (%)')
    title(sprintf('%s',thisareastr))
end
fname= fullfile(dpath,['Fig4D',char(Params.epochtypes(thisepochtype))]);
print(gcf,'-vector','-dsvg',[fname,'.pdf'])