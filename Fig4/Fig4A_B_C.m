%% plotpeth_trialtypes
%% Fig.4A-C
% creates 4 figures, 
% Fig.4A,B: 5 tiles each corresponding to the averaged zscore activity around the timepoint when the CORRECT choice is made in one of 5 pokeholes for the ACC (Fig.4A) or mPFC
% (Fig.4B); neurons are sorted depending towards which poke they show highest responsiveness (i.e maximum AUC within 1 s before and after the poke is made) and sorted by peak latency
% upper and bottom plots show heatplots for odd and even trials, respectively; plots in the middle display  temporal correlations betweem upper and bootom heat plots
% Fig.4C: line plot displaying correlation of the zcsored activity between
% the average across even and odd trials

%%
function Fig4A_B_C(Params,infovar,eventepochs,thisepochtype)

dpath = Choosesavedir('figs');
dpath = fullfile(dpath, 'Fig4');
dpathexcel = Choosesavedir('excel');
dpathexcel = fullfile(dpathexcel, 'Fig4');
mkdir(dpath)
mkdir(dpathexcel)

r = [];
A=[8 12 16]; % three sizes for p=0.05, p=0.01, p =0.001
numframes = Params.frames.num(thisepochtype);
xvalues = 1:numframes;
bfeventframes = Params.frames.bfevent(thisepochtype);
afeventframes = Params.frames.afevent(thisepochtype);
zeroframe = bfeventframes+1;
rangeselect = zeroframe-5:zeroframe+5; % range required for calculating AUC to identify poketype-responsive neurons

for thisarea = 1:numel(Params.brainareas) % iterate through brain areas
    animalselect = find(ismember(infovar.brainareas,Params.brainareas(thisarea)));
    auc_pokes = [];
    epochsOdd_all = [];
    epochsEven_all = [];
    for thispoketype = 1:numel(Params.poketypes) % iterate through poketypes

        epochsOdd=[];
        epochsEven = [];
        for thisses = animalselect % iterate through sessions with same brain area

            epochs_ses = eventepochs{thisses}{1,3}{thispoketype}; % get event activity for poketype and session
            if size(epochs_ses,3)< 2 % if there is <2 trials for the poketype, average across odd trials cannot be calculated, so put them nan (will be plotted grey in heatplot)
                epochs_ses_Odd = nan(size(epochs_ses,[1,2]));
                epochs_ses_Even =  nan(size(epochs_ses,[1,2]));
            else
                epochs_ses_Odd = mean(epochs_ses(:,:,1:2:end),3); % take average across odd trials
                epochs_ses_Even = mean(epochs_ses(:,:,2:2:end),3); % take average across even trials
            end
            epochsOdd = cat(1,epochsOdd,epochs_ses_Odd); % concatenate averages
            epochsEven = cat(1,epochsEven,epochs_ses_Even);
        end
        %%% get the AUC from 1s before and after the correct poke to
        %%% indicate poke responsiveness of each cell
        epochsOdd_range = epochsOdd(:,rangeselect); % use only odd trials, later apply on even trials
        auc_pokes(:,thispoketype) = abs(trapz(epochsOdd_range,2));
        epochsOdd_all(:,:,thispoketype) = epochsOdd;
        epochsEven_all(:,:,thispoketype) = epochsEven;
    end

    [~,resp_pokes] = max(auc_pokes,[],2); % get max AUC for each cell
    [resp_pokes,sortidx_pokes] = sort(resp_pokes);
    numPoketypes = groupcounts(resp_pokes);

    %%% within each poketype responsive cell group, sort by peak latency
    sortidx = [];
    for thispoketype = 1:numel(Params.poketypes)
        epochsOdd = epochsOdd_all(:,:,thispoketype); % only use odd trials and apply later on even trials
        thisresppokes = sortidx_pokes(resp_pokes==thispoketype); % get cells for a certain poketype
        epochs_poketype = epochsOdd(thisresppokes,:); % get traces for the cells responsive to poketype

        [~,maxidx] = max(epochs_poketype,[],2); % get peak latency
        [~,thissortidx] = sort(maxidx); % sort peak latency

        sortidx_pokesNew = thisresppokes(thissortidx);
        sortidx = [sortidx;sortidx_pokesNew]; % idx which sorts cells by poke responsiveness and peak latency
    end

    %%% make plots, correlations between odd and even trials
    figure
    t = tiledlayout(3,numel(Params.poketypes),'TileSpacing', 'compact', 'Padding', 'compact');
    xlabel(t,'Time from correct poke (s)')
    ylabel(t,'Cell ID')

    poke_epochs = [];

    for thispoketype = 1:numel(Params.poketypes)
        epochs_avgOdd= epochsOdd_all(:,:,thispoketype);
        epochs_avgEven= epochsEven_all(:,:,thispoketype);
        epochs_avgOddSort = epochs_avgOdd(sortidx,:); % apply sort_idx on cells
        epochs_avgEvenSort = epochs_avgEven(sortidx,:);

        %% correlation between heatplots of odd and even trials
  
        [thisr,thisp] = corrcoef([epochs_avgOdd,epochs_avgEven]);
        thisr2 = diag(thisr(numframes+1:numframes*2,1:numframes)); % select the required correlation values from the matrix
        thisp2 = diag(thisp(numframes+1:numframes*2,1:numframes)); % select the corresponding p values

        r{thispoketype,thisepochtype,thisarea} = thisr2;
        p{thispoketype,thisepochtype,thisarea} = thisp2;

        %% plot heatplots (Fig.4A,B)
        %%% for odd trials

        ax(1,thispoketype) = nexttile(thispoketype);
        imAlpha=ones(size(epochs_avgOddSort));
        imAlpha(isnan(epochs_avgOddSort))=0;

        imagesc(ax(1,thispoketype),epochs_avgOddSort,'AlphaData',~isnan(epochs_avgOddSort))
        caxis([-1 7])

        %%% for r values
        pos = numel(Params.poketypes)+thispoketype;
        ax(2,thispoketype) = nexttile(pos);
        imagesc(ax(2,thispoketype),thisr2');
        caxis([0 1])

        %%% for even trials
        pos = numel(Params.poketypes)*2+thispoketype;
        ax(3,thispoketype) = nexttile(pos);
        imAlpha=ones(size(epochs_avgEvenSort));
        imAlpha(isnan(epochs_avgEvenSort))=0;
        imagesc(ax(3,thispoketype),epochs_avgEvenSort,'AlphaData',~isnan(epochs_avgEvenSort))
        caxis([-1 7])

        poke_epochs(:,:,thispoketype) = epochs_avgEvenSort; % later needed for correlations
    end

    %% edit plots
    for i = 1:size(ax,1)
        for ii = 1:numel(Params.poketypes)
            set(ax(i,ii),'Box','off')
            set(ax(i,ii),'TickDir','out')
            set(ax(i,ii), 'Color', [0.7,0.7, 0.7]) %%% required to plot nan values black

            a = numPoketypes(1);
            for q = 1:numel(Params.poketypes)-1
                yline(ax(i,ii),a,'LineWidth',2,'Color','g')
                a=a+numPoketypes(q+1);
            end

            if bfeventframes ~= 0
                xline(ax(i,ii),bfeventframes+1)
            end

            if ismember(i,[1,2])
                set(ax(i,ii),'XTickLabel','')
            end

            if isequal(i,1)
                title(ax(i,ii),Params.poketypes{ii})
            end

            if isequal(i,2)
                set(ax(i,ii),'YTickLabel','')
            end

            if isequal(i,3)
                set(ax(i,ii),'XTick',1:5:numframes)
                set(ax(i,ii),'XTickLabel',-bfeventframes*Params.timebinlength/1000:afeventframes*Params.timebinlength/1000)
            end

            if ismember(i,[1,3])
                set(ax(i,ii),'Colormap',bluewhitered)
            end

            if isequal(ii,numel(Params.poketypes))
                colorbar(ax(i,ii))
            end
        end
    end
    %%% export figure to directory
    if thisarea ==1
        fname = fullfile(dpath, ...
            ['Fig4A' char(Params.epochtypes(thisepochtype))]);
    else
        fname = fullfile(dpath, ...
            ['Fig4B' char(Params.epochtypes(thisepochtype))]);
    end
    print(gcf,'-vector','-dpdf',[fname,'.pdf'])

    %% Fig.4C (correlation analysis)
    comb_pokes=  nchoosek(Params.poketypes,2); % combination of poketypes to do correlations against (eg. poketype 1-2, 1-3 etc)
    comb_pokesid = nchoosek(1:numel(Params.poketypes),2);
    thisr_poke = nan(numframes,size(comb_pokesid,1)); % pre-allocate
    thisp_poke = nan(numframes,size(comb_pokesid,1));% pre-allocate
    c = [
    0.68, 0.85, 0.90;  % Light Blue
    0.63, 0.13, 0.94;  % Purple
    1.00, 0.00, 0.00;  % Red
    1.00, 0.50, 0.00   % Orange
    ];
   
    for thiscomb = 1:size(comb_pokesid,1) % iterate through number of poketype combinations
        heatplotA = poke_epochs(:,:,comb_pokesid(thiscomb,1));
        heatplotB = poke_epochs(:,:,comb_pokesid(thiscomb,2));

        nancellsA = find(all(isnan(heatplotA),2)); % remove cells with nan due to lack of pokes
        nancellsB = find(all(isnan(heatplotB),2));
        heatplotA([nancellsA;nancellsB],:) = [];
        heatplotB([nancellsA;nancellsB],:) = [];

        [r_poke,p_poke] = corrcoef([heatplotA,heatplotB]);
        thisr_poke(:,thiscomb) = diag(r_poke(numframes+1:numframes*2,1:numframes)); % select the required correlation values from the matrix
        thisp_poke(:,thiscomb) = diag(p_poke(numframes+1:numframes*2,1:numframes)); % select the corresponding p values
    end

    % indices of combinations with same distance
    dist0 = [1,5,8,10];
    dist1 = [2,6,9];
    dist2 = [3,7];
    dist3 = 4;

    % take mean across correlations with same distance
    r_avg0 = mean(thisr_poke(:,dist0),2);
    r_avg1 = mean(thisr_poke(:,dist1),2);
    r_avg2 = mean(thisr_poke(:,dist2),2);
    r_avg3 = mean(thisr_poke(:,dist3),2);
    r_pokes = [r_avg0,r_avg1,r_avg2,r_avg3];

    % plot correlations
    figure
    hold on

    pl2 =  plot(r_pokes);
    pl2(1).Color =  c(1,:);
    pl2(2).Color =  c(2,:);
    pl2(3).Color =  c(3,:);
    pl2(4).Color =  c(4,:);

    xticks(1:5:numframes)
    xlim([0,numframes])
    grplbls = {'dist0','dist1','dist2','dist3'};
    legend(pl2,grplbls,'Location','northeastoutside')
    xticklabels(-bfeventframes*Params.timebinlength/1000:afeventframes*Params.timebinlength/1000)
    ylim([-0.2,1])
    set(gca,'fontname','arial')
    set(gca,'linewidth',0.8)
    set(gca,'fontsize',11)
    set(gca,'TickDir','out');
    set(gca,'box','off')

    xlabel('Time relative to correct choice poke (s)')
    ylabel('Pearson correlation r')

    if thisarea==1
        fname= fullfile(dpath, 'Fig4C_ACC');
    else
        fname= fullfile(dpath, 'Fig4C_mPFC');
    end

    print(gcf,'-vector','-dpdf',[fname,'.pdf'])

    %%% statistics
    %%% RM ANOVA
    data = r_pokes(rangeselect,:);
    % Convert data to table with variable names for each group
    T = array2table(data);
    T.Properties.VariableNames = {'dist0', 'dist1', 'dist2', 'dist3'};

    % Add a row for subjects (assuming each row in original data represents the same subject across conditions)
    T.Subject = (1:numel(rangeselect))';

    % Create repeated measures model, assuming 'Time' as within-subject factor
    rm = fitrm(T, 'dist0-dist3 ~ 1', 'WithinDesign', {'dist0', 'dist1', 'dist2', 'dist3'});
    ranovaResults = ranova(rm);

    % Perform multi comparison
    cmpResults = multcompare(rm,'Time','ComparisonType','Dunn-Sidak');
    cmpResults = cmpResults([1,5,9],:);
    %%% excel table for anova
    fname = fullfile(dpathexcel,['Fig4_anova' '.xlsx']);
    writetable(ranovaResults,fname,'Sheet',['RMANOVA',Params.brainareas{thisarea} '_' char(Params.epochtypes(thisepochtype))],'WriteMode','overwritesheet','WriteRowNames',true)
    writetable(cmpResults,fname,'Sheet',['SidakPosthoc',Params.brainareas{thisarea} '_' char(Params.epochtypes(thisepochtype))],'WriteMode','overwritesheet')
    tbl = array2table(thisr_poke);
    tbl.Properties.VariableNames = strcat(comb_pokes(:,1),comb_pokes(:,2));
    tbl.frame = (1:numframes)';
    tbl.timestamp = (-bfeventframes*Params.timebinlength/1000:0.2:afeventframes*Params.timebinlength/1000)';
    writetable(tbl,fname,'Sheet',['RAW_', Params.brainareas{thisarea} '_' char(Params.epochtypes(thisepochtype))],'WriteMode','overwritesheet') % RAW data
end
end