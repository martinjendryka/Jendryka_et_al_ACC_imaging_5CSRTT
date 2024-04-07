function Fig7A(tbl,Params,rewlatAll,resplatAll,thisepochtype,cpd)
%% Fig.7A
% creates a figure with 9 tiles each showing the coefficient of partial determination (CPD) in % 
% during the time relative to the choice made. The CPD is shown for the baseline and devaluation (first column),
% first extinction (second column) and 2nd extinction (third column), respectively and for the predictor 
% active poke/omission (first row), spatial location (second row) and
% reward (correct) response (third row). 
% The dots above the plots correspond to whether for a specific timebin the
% statistical significance was reached in the 2-way ANOVA test (bottom dots
% in black) or the one-sided ttest (upper dots, color-coded according to the specific challenge)
%%

dpathexcel = Choosesavedir('excel');
dpath = Choosesavedir('figs');
dpath = fullfile(dpath,'fig7');
mkdir(dpath)
taskstrs= unique(tbl.Task);
taskstrs(1) = [];

colorlines= [0 0 1;1 0 0;0 1 0];
A=[1 3 5]; % three sizes for p=0.05, p=0.01, p =0.001
n_animals_bl = 10;
predselect = [1,2,6];
numframes = Params.frames.num(thisepochtype);
xvals = 1:numframes;
bfeventframes = Params.frames.bfevent(thisepochtype);
afeventframes = Params.frames.afevent(thisepochtype);
timebinlength = Params.timebinlength;
zeroline = bfeventframes+1;
thisarea=1;
figure
t= tiledlayout(3,3,'TileSpacing','tight');
xlabel(t,'Time (s)')
ylabel(t,'Coefficient of Partial Determination (%)')

for thispred = 1:numel(predselect)

    cpd_pred = squeeze(cpd(predselect(thispred),:,:))';

    %%%plot
    shiftn = 1;
    tbl_bl = tbl(1:n_animals_bl,:);
    c=1;
    for thistask = 1:numel(taskstrs)
        ti(thistask,thispred)= nexttile;
        hold on
        d = 0;
        % twoway ANOVA
        tbl_task = tbl(ismember(tbl.Task,taskstrs(thistask)) & ismember(tbl.Brainarea,Params.brainareas(thisarea)),:);
        cpd_task = cpd_pred(ismember(tbl.Task,taskstrs(thistask)) & ismember(tbl.Brainarea,Params.brainareas(thisarea)),:);
        cpd_bl  = cpd_pred(shiftn:n_animals_bl+shiftn-1,:);
        tbl_anova= [[tbl_bl;tbl_task],array2table([cpd_bl;cpd_task])];
        tbl_anova.AnimalID(1:n_animals_bl) = string(tbl.AnimalID(1:n_animals_bl));
        timeframes = table((1:numframes)',VariableNames="timeframes");
        rm = fitrm(tbl_anova,"Var1-Var56 ~ Task",WithinDesign = timeframes);
        anovatbl = ranova(rm,"WithinModel","timeframes");
        mc = multcompare(rm,"Task",'By','timeframes','ComparisonType','dunn-sidak');
        mc = mc(ismember(mc.Task_1,{'cb800ms'}),[1:3,6]);
        thisdpath = fullfile(dpathexcel,char(Params.brainareas(thisarea)));
        mkdir(thisdpath)
        writetable(tbl_anova,fullfile(thisdpath,'Fig7_RAW.xlsx'),"Sheet",Params.predstrs{thispred})
        writetable(mc,fullfile(thisdpath,'Fig7_MULTC.xlsx'),"Sheet",Params.predstrs{thispred})
        writetable(anovatbl,fullfile(thisdpath,'Fig7_ANOVA.xlsx'),"Sheet",Params.predstrs{thispred},"WriteRowNames",true)

        for i = 1:2
            if i ==1
                cpd_task = cpd_pred(shiftn:n_animals_bl+shiftn-1,:);
                shiftn = shiftn + n_animals_bl;
            else
                cpd_task = cpd_pred(ismember(tbl.Task,taskstrs(thistask)) & ismember(tbl.Brainarea,Params.brainareas(thisarea)),:);
            end

            cpdMean = mean(cpd_task,1,'omitnan');
            cpdErr = std(cpd_task,1,'omitnan');
            cpdErr = cpdErr/sqrt(size(cpd_task,1));

            avg_traces = cpdMean*100;
            errortype = cpdErr*100;

            errorPlus = avg_traces + errortype;
            errorMinus = avg_traces - errortype;

            inBetween = [errorPlus,fliplr(errorMinus)];
            if i==1
                fill([xvals, fliplr(xvals)],inBetween,[0 0 0],'linestyle', 'none',...
                    'FaceAlpha',0.2)

                t(thistask)= plot(xvals,avg_traces,'LineWidth',2,'Color',[0 0 0]);
            else 
                fill([xvals, fliplr(xvals)],inBetween,colorlines(c,:),'linestyle', 'none',...
                    'FaceAlpha',0.2)

                t(thistask)= plot(xvals,avg_traces,'LineWidth',2,'Color',colorlines(c,:));
            end

            if i ==1

                thispvals = mc.pValue;
                pvals_sig = thispvals;

                pvals_sig(thispvals<0.05) = 0.05;
                pvals_sig(thispvals<0.01) = 0.01;
                pvals_sig(thispvals<0.001) = 0.001;
                y = 8.5 + d;

                plot(xvals(pvals_sig==0.05),y*ones(sum(pvals_sig==0.05),1),'.','MarkerSize',A(1),'Color',[0 0 0]);
                plot(xvals(pvals_sig==0.01),y*ones(sum(pvals_sig==0.01),1),'.','MarkerSize',A(2),'Color',[0 0 0]);
                plot(xvals(pvals_sig==0.001),y*ones(sum(pvals_sig==0.001),1),'.','MarkerSize',A(3),'Color',[0 0 0]);
            end

            %%% ttest against zero with Benjamini-Hochberg multiple comparison procedure

            pval= [];
            for thistimebin = 1:numframes % one-sample ttest for each timebin

                [~,pval(thistimebin)]  = ttest(cpd_task(:,thistimebin),0,'tail','right'); % only CPD > 0 are relevant
            end
            thispvals = pval;

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

            y2 = 9.5 + d;

            if i ==1
                lat1 = resplatAll(1,thisarea);
                lat2 = rewlatAll(1,1,thisarea);
                lat3 = lat2 + rewlatAll(1,2,thisarea);

                plot(xvals(pvals_sig==0.05),y2*ones(sum(pvals_sig==0.05),1),'.','MarkerSize',A(1),'Color',[0 0 0]);
                plot(xvals(pvals_sig==0.01),y2*ones(sum(pvals_sig==0.01),1),'.','MarkerSize',A(2),'Color',[0 0 0]);
                plot(xvals(pvals_sig==0.001),y2*ones(sum(pvals_sig==0.001),1),'.','MarkerSize',A(3),'Color',[0 0 0]);

                xline(zeroline-lat1/timebinlength,'LineWidth',1,'Color',[0 0 0])
                xline(zeroline+lat2/timebinlength,'LineWidth',1,'Color',[0 0 0])
                xline(zeroline+lat3/timebinlength,'LineWidth',1,'Color',[0 0 0])
                xline(zeroline)
            else
                lat1 = resplatAll(thistask+1,thisarea);
                lat2 = rewlatAll(thistask+1,1,thisarea);
                lat3 = lat2 + rewlatAll(thistask+1,2,thisarea);

                plot(xvals(pvals_sig==0.05),y2*ones(sum(pvals_sig==0.05),1),'.','MarkerSize',A(1),'Color',colorlines(c,:));
                plot(xvals(pvals_sig==0.01),y2*ones(sum(pvals_sig==0.01),1),'.','MarkerSize',A(2),'Color',colorlines(c,:));
                plot(xvals(pvals_sig==0.001),y2*ones(sum(pvals_sig==0.001),1),'.','MarkerSize',A(3),'Color',colorlines(c,:));

                xline(zeroline-lat1/timebinlength,'LineWidth',1,'Color',colorlines(c,:))
                xline(zeroline+lat2/timebinlength,'LineWidth',1,'Color',colorlines(c,:))
                xline(zeroline+lat3/timebinlength,'LineWidth',1,'Color',colorlines(c,:))
                c=c+1;
            end
            d = d + 0.3;
            set(t,"LineWidth",1)
            set(gca,'fontname','arial')
            set(gca,'linewidth',0.8)
            set(gca,'fontsize',11)
            set(gca,'TickDir','out');
            set(gca,'box','off')
        end

        if ismember(numel(ti),[3,6,9])
            text(max(xlim), max(ylim)/2, sprintf(Params.predstrs{predselect(thispred)}), 'FontSize', 10, 'HorizontalAlignment', 'center', 'Rotation', 270);
        end

        if ismember(numel(ti),[1,2,3])
            title(sprintf('%s vs baseline',taskstrs(thistask)))
        end
        xlim([0 numframes])
        xticks(1:5:numframes)
        xticklabels(-bfeventframes*timebinlength/1000:afeventframes*timebinlength/1000)
        ylim([-2,10])
        yticks(-2:2:10)
    end
end

fname= fullfile(dpath,'Fig7');
print(gcf,'-vector','-dpdf',[fname,'.pdf'])