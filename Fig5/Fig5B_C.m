function Fig5B_C(Params,varlist,regressvar,beh,thisepochtype)
%% 
% plots the coefficient of partial determination in % for each predictor
% (see Fig.5A).
% The dots above the plot correspond to the statistical significance
% reached for the one-sided ttest against 0 (color-coded according to 
% predictor). 


%%
dpath =Choosesavedir('figs');
dpath = fullfile(dpath, 'Fig5');
mkdir(dpath)
dpathexcel = Choosesavedir('excel');
dpathexcel = fullfile(dpathexcel, 'fig5');
mkdir(dpathexcel)
numpred = numel(Params.predstrs);
A=[8 12 16]; % three sizes for p=0.05, p=0.01, p =0.001

colorlines = [0,0,1;...
    1,0,0; 0,1,0; 0,0,0.1724;...
    1,0.1034,0.7241;1,0.8276,0;...
    0,0.3448,0];

 numframes = Params.frames.num(thisepochtype);
    bfeventframes = Params.frames.bfevent(thisepochtype);
    afeventframes = Params.frames.afevent(thisepochtype);

    xvals = 1:numframes;

for thisarea = 1:numel(Params.brainareas)
    animalselect = find(ismember(varlist.brainareas,Params.brainareas(thisarea)));
    cpdbrain = regressvar.cpd(animalselect);
    emptycells = cell2mat(cellfun(@(x) isempty(x),cpdbrain,'UniformOutput',false));
    animalselect(emptycells) = [];
    cpdbrain(emptycells) = [];
    animals = varlist.animals(animalselect);

    rewlat = median(vertcat(beh.rewlat{animalselect}),1,'omitnan');
    brainls = varlist.brainareas(animalselect);
    task = varlist.task(animalselect);
    tblexport = table(animals',task',brainls');

    figure
   
    thiscpd = cellfun(@(x) x{thisepochtype},cpdbrain,'UniformOutput',false);
    if unique(cell2mat(cellfun(@(x) isempty(x),thiscpd,'UniformOutput',false)))
        continue
    end
    cpdMean_cells = cellfun(@(x) squeeze(mean(x,2)),thiscpd,'UniformOutput',false); % mean across cells

    hold on
    pvals = [];
    d = 0;
    cpdMeanPredAll =[];

    for thispred = 1:numpred

        cpdMeanPred = cellfun(@(x) x(thispred,:),cpdMean_cells,'UniformOutput',false); % get CPD vals for one predictor for all animals for each time bin
        cpdMeanPred = cell2mat(cpdMeanPred');
        cpdMean = mean(cpdMeanPred,1);
        cpdErr = std(cpdMeanPred,[],1);
        cpdErr = cpdErr ./ sqrt(size(cpdMeanPred,1));
        cpdMeanPredAll = cat(3,cpdMeanPredAll,cpdMeanPred);
        tbl = [tblexport,array2table(cpdMeanPred)];

        if isequal(thispred,numpred+1)
            writetable(tbl,fullfile(dpathexcel,['rawfig9_',Params.brainareas{thisarea},'.xlsx']),'Sheet','R2_intercept')

        else
            writetable(tbl,fullfile(dpathexcel,['rawfig9_',Params.brainareas{thisarea},'.xlsx']),'Sheet',Params.predstrs{thispred})
        end

        pval= [];
        for thistimebin = 1:numframes % one-sample ttest for each timebin
            [~,pval(thistimebin)]  = ttest(cpdMeanPred(:,thistimebin),0,'tail','right'); % only CPD > 0 are relevant
        end

        %% plot line graphs with shaded error
        avg_traces = cpdMean*100';
        errortype = cpdErr*100';

        errorPlus = avg_traces + errortype;
        errorMinus = avg_traces - errortype;

        inBetween = [errorPlus,fliplr(errorMinus)];

        fill([xvals, fliplr(xvals)],inBetween,colorlines(thispred,:),'linestyle', 'none',...
            'FaceAlpha',0.2)

        h(thispred) = plot(xvals,avg_traces,'LineWidth',2,'Color',colorlines(thispred,:));

        if ~(thispred==numpred + 1)

            thispvals = pval;
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

            y = 10 + d;

            plot(xvals(pvals_sig==0.05),y*ones(sum(pvals_sig==0.05),1),'.','MarkerSize',A(1),'Color',colorlines(thispred,:));
            plot(xvals(pvals_sig==0.01),y*ones(sum(pvals_sig==0.01),1),'.','MarkerSize',A(2),'Color',colorlines(thispred,:));
            plot(xvals(pvals_sig==0.001),y*ones(sum(pvals_sig==0.001),1),'.','MarkerSize',A(3),'Color',colorlines(thispred,:));
            d = d + 0.5;
        end
    end

    lat1 = nan;
    lat2 = nan;
    lat3 = nan;

    if thisepochtype == 3
        resplat = median(catpad(2,beh.resplat{1,...
            animalselect}),[1,2],'omitnan');

        lat1 = resplat;
        lat2 = rewlat(1);
        lat3 = lat2 + rewlat(2);

    elseif thisepochtype == 1
        resplat = median(catpad(2,beh.resplat{4,...
            animalselect}),[1,2],'omitnan');
        lat1= resplat;
    end

    if bfeventframes ~= 0
        zeroline = bfeventframes+1;
    else
        zeroline=0;
    end

    xline(zeroline)

    if thisepochtype == 3
        xline(zeroline-lat1/Params.timebinlength,'LineWidth',1)
    else
        xline(zeroline+lat1/Params.timebinlength,'LineWidth',1)
    end
    xline(zeroline+lat2/Params.timebinlength,'LineWidth',1)
    xline(zeroline+lat3/Params.timebinlength,'LineWidth',1)

    xlim([0 numframes])
    xticks(1:5:numframes)
    xticklabels(-bfeventframes*Params.timebinlength/1000:afeventframes*Params.timebinlength/1000)
    ylim([-5,15])
    setFig
    xlabel('Time (s)')
    ylabel('Coefficient of Partial Determination (%)')

    legend(h([1,2,6]),Params.predstrs([1,2,6]),'Location','northeastoutside')

    if thisarea == 1
        fname= fullfile(dpath,['Fig5B_' char(Params.epochtypes(thisepochtype))]);
    else
        fname = fullfile(dpath,['Fig5C_' char(Params.epochtypes(thisepochtype))]);
    end
    print(gcf,'-vector','-dpdf',[fname,'.pdf'])

end
end