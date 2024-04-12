function Fig6E_F(tbl, Params,rewlatAll,resplatAll,thisepochtype)
%%
% plots the decoding accuracy of binary classifiers trained and tested to predict
% the trialtype (Fig.6E:correct vs omission, Fig.6F:correct vs premature responses)
% dots above the plot  indicate if statstical significance
% was reached for that timepoint for the two ANOVA (bottom dots) or the
% one-sided ttest against 0 (upper dots, color-coded according to
% challenge)
%%
dpathexcel = Choosesavedir('excel');
dpath = Choosesavedir('figs');
dpath = fullfile(dpath,'Fig6');
mkdir(dpath)
mkdir(dpathexcel)
taskstrs = string(unique(tbl(:,2)));
colorlines = [0 0 0; 0 0 201; 200 0 0; 90 160 44]./  256;
A=[8 12 16]; % three sizes for p=0.05, p=0.01, p =0.001

numframes = Params.frames.num(thisepochtype);
xvals = 1:numframes;
bfeventframes = Params.frames.bfevent(thisepochtype);
afeventframes = Params.frames.afevent(thisepochtype);
timebinlength = Params.timebinlength;
zeroline = bfeventframes+1;

thisarea= 1;
for thiscomb = [2,3]
    da = tbl(ismember(tbl(:,3),Params.brainareas(thisarea)),[1:3,thiscomb+3]);
    emptycells = cell2mat(cellfun(@(x) isempty(x), da(:,end),'UniformOutput',false));
    da_new = da(~emptycells,:);
    vals = transpose(cat(2,da_new{:,end}));
    factor_numframes = repmat(transpose(1:numframes),size(da_new,1),1);
    factor_task = repelem(da_new(:,2),numframes,1);
    tbl_anova = array2table(vals);
    tbl_anova= [da_new(:,1),da_new(:,2),tbl_anova];
    tbl_anova.Properties.VariableNames(1:2)={'AnimalID','Task'};
    timeframes = table((1:numframes)',VariableNames="timeframes");
    rm = fitrm(tbl_anova,"vals1-vals56 ~ Task",WithinDesign = timeframes);
    anovatbl = ranova(rm,"WithinModel","timeframes");
    mc = multcompare(rm,"Task",'By','timeframes','ComparisonType','dunn-sidak');
    mc = mc(ismember(mc.Task_1,{'cb800ms'}),[1:3,6]);
    mkdir(dpathexcel)
    writetable(tbl_anova,fullfile(dpathexcel,'devalExpsFig6_RAW.xlsx'),"Sheet",strjoin(Params.trialtypes(Params.trialcombs(thiscomb,:))))
    writetable(mc,fullfile(dpathexcel,'devalexpsFig6_MULTC.xlsx'),"Sheet",strjoin(Params.trialtypes(Params.trialcombs(thiscomb,:))))
    writetable(anovatbl,fullfile(dpathexcel,'devalexpsFig6_ANOVA.xlsx'),"Sheet",strjoin(Params.trialtypes(Params.trialcombs(thiscomb,:))),"WriteRowNames",true)

    %%%plot
    figure
    hold on
    d = 0;
    for thistask = 1:numel(taskstrs)
        da_task = transpose(cat(2,da_new{ismember(da_new(:,2),taskstrs(thistask)),end}));
        if isempty(da_task)
            continue
        end
        daAvg = mean(da_task,1,'omitnan');
        daErr = std(da_task,1,'omitnan');
        daErr = daErr/sqrt(size(da_task,1));

        avg_traces = daAvg*100;
        errortype = daErr*100;

        errorPlus = avg_traces + errortype;
        errorMinus = avg_traces - errortype;

        inBetween = [errorPlus,fliplr(errorMinus)];

        fill([xvals, fliplr(xvals)],inBetween,colorlines(thistask,:),'linestyle', 'none',...
            'FaceAlpha',0.2)

        t(thistask)= plot(xvals,avg_traces,'LineWidth',2,'Color',colorlines(thistask,:));

        if thistask~=1

            thispvals = mc.pValue(mc.Task_2==taskstrs(thistask));
            pvals_sig = thispvals;

            pvals_sig(thispvals<0.05) = 0.05;
            pvals_sig(thispvals<0.01) = 0.01;
            pvals_sig(thispvals<0.001) = 0.001;
            y = 105 + d;

            plot(xvals(pvals_sig==0.05),y*ones(sum(pvals_sig==0.05),1),'.','MarkerSize',A(1),'Color',colorlines(thistask,:));
            plot(xvals(pvals_sig==0.01),y*ones(sum(pvals_sig==0.01),1),'.','MarkerSize',A(2),'Color',colorlines(thistask,:));
            plot(xvals(pvals_sig==0.001),y*ones(sum(pvals_sig==0.001),1),'.','MarkerSize',A(3),'Color',colorlines(thistask,:));
            d = d + 3;
        end
        lat1 = resplatAll(thistask,thisarea);
        lat2 = rewlatAll(thistask,1,thisarea);
        lat3 = lat2 + rewlatAll(thistask,2,thisarea);
        xline(zeroline)
        xline(zeroline-lat1/timebinlength,'LineWidth',1,'Color',colorlines(thistask,:))
        xline(zeroline+lat2/timebinlength,'LineWidth',1,'Color',colorlines(thistask,:))
        xline(zeroline+lat3/timebinlength,'LineWidth',1,'Color',colorlines(thistask,:))
    end

    title(Params.trialtypes(Params.trialcombs(thiscomb,:)))
    legend(t,taskstrs,'Location','northeastoutside')
    xlim([0 numframes])
    xticks(1:5:numframes)
    xticklabels(-bfeventframes*timebinlength/1000:afeventframes*timebinlength/1000)
    ylim([0,120])
    yticks(0:20:100)
    set(gca,'fontname','arial')
    set(gca,'linewidth',1.4)
    set(gca,'fontsize',12)
    set(gca,'TickDir','out');
    set(gca,'box','off')
    xlabel('Time (s)')
    ylabel('Decoding Accuracy (%)')

    if thiscomb ==2
        fname= fullfile(dpath,'Fig6E');
    else
        fname= fullfile(dpath,'Fig6F');
    end
    print(gcf,'-vector','-dsvg',[fname,'.pdf'])
end
end