%% plotpeth_trialtypes
%% Supplmentary Fig.2A-C
% creates 4 figures,
% Fig.4A,B: 5 tiles each corresponding to the averaged zscore activity around the timepoint when the CORRECT choice is made in one of 5 pokeholes for the ACC (Fig.4A) or mPFC
% (Fig.4B); neurons are sorted depending towards which poke they show highest responsiveness (i.e maximum AUC within 1 s before and after the poke is made) and sorted by peak latency
% upper and bottom plots show heatplots for odd and even trials, respectively; plots in the middle display  temporal correlations betweem upper and bootom heat plots
% Fig.4C: line plot displaying correlation of the zcsored activity between
% the average across even and odd trials

%%
function Supplfig2A_B_C(Params,infovar,eventepochs,thisepochtype)

dpath = Choosesavedir('figs');
dpath = fullfile(dpath, 'Supplfig2');
dpathexcel = Choosesavedir('excel');
dpathexcel = fullfile(dpathexcel, 'Supplfig2');
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

    %%% make plots, correlations between odd and even trials
    figure
    t = tiledlayout(3,numel(Params.poketypes),'TileSpacing', 'compact', 'Padding', 'compact');
    xlabel(t,'Time from correct poke (s)')
    ylabel(t,'Cell ID')

    poke_epochs = [];
    cormat=[];
    for thispoketype = 1:numel(Params.poketypes)
        epochs_avgOdd=[];
        epochs_avgEven=[];

        for thisses = animalselect % iterate through sessions with same brain area

            epochs_ses = eventepochs{thisses}{1,thisepochtype}{thispoketype}; % get event activity for poketype and session
            if size(epochs_ses,3)< 2 % if there is <2 trials for the poketype, average across odd trials cannot be calculated, so put them nan (will be plotted grey in heatplot)
                epochs_ses_Odd = nan(size(epochs_ses,[1,2]));
                epochs_ses_Even =  nan(size(epochs_ses,[1,2]));
            else
                epochs_ses_Odd = mean(epochs_ses(:,:,1:2:end),3); % take average across odd trials
                epochs_ses_Even = mean(epochs_ses(:,:,2:2:end),3); % take average across even trials
            end
            epochs_avgOdd = cat(1,epochs_avgOdd,epochs_ses_Odd); % concatenate averages
            epochs_avgEven = cat(1,epochs_avgEven,epochs_ses_Even);
        end
        
        %% correlation between heatplots of odd and even trials
        %%% correlation between odd and even heat plots (required for SupplFig. 2C)

        [thisr,thisp] = corrcoef([epochs_avgOdd,epochs_avgEven],'rows','complete'); % excludes rows with nan values
        thisr2 = diag(thisr(numframes+1:numframes*2,1:numframes)); % select the required correlation values from the matrix
        thisp2 = diag(thisp(numframes+1:numframes*2,1:numframes)); % select the corresponding p values

        r{thispoketype,thisepochtype,thisarea} = thisr2;
        p{thispoketype,thisepochtype,thisarea} = thisp2;

        % required for correlation plot to identify neurons with temporal
        % responsiveness
        for thiscell = 1:size(epochs_avgEven,1) % get correlation for each cell between even and odd trials across timeframes
            cormat(thiscell,thispoketype)  =  corr(epochs_avgOdd(thiscell,rangeselect)',epochs_avgEven(thiscell,rangeselect)','rows','complete'); % include only 1 s bf and af poke
        end


         [~,maxidx] = max(epochs_avgOdd,[],2); % get peak latency
        [~,sortidx] = sort(maxidx); % sort peak latency

        epochs_avgOddSort = epochs_avgOdd(sortidx,:); % apply sort_idx on cells
        epochs_avgEvenSort = epochs_avgEven(sortidx,:);
        %% plot heatplots (SupplFig.2A,B)
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
            ['Supplfig2A' char(Params.epochtypes(thisepochtype))]);
    else
        fname = fullfile(dpath, ...
            ['Supplfig2B' char(Params.epochtypes(thisepochtype))]);
    end
    print(gcf,'-vector','-dpdf',[fname,'.pdf'])

    %% Fig.4C (correlation analysis)
    comb_pokes=  nchoosek(Params.poketypes,2); % combination of poketypes to do correlations against (eg. poketype 1-2, 1-3 etc)
    comb_pokesid = nchoosek(1:numel(Params.poketypes),2);
    thisr_poke = nan(numframes,size(comb_pokesid,1)); % pre-allocate
    thisp_poke = nan(numframes,size(comb_pokesid,1));% pre-allocate
    c = [
        0.68, 0.85, 0.90;  % Light Blue
        0 0 1; % blue
        0.63, 0.13, 0.94;  % Purple
        1.00, 0.00, 0.00;  % Red
        1.00, 0.50, 0.00;   % Orange
        0 1 0 % green
        ];

    figure
    t= tiledlayout(1,5);

    for thispoketype = 1:numel(Params.poketypes)
        y=1.1;

        thiscormat = cormat(:,thispoketype);
        includecells= thiscormat>median(thiscormat,'omitnan');

        for thiscomb = 1:size(comb_pokesid,1) % iterate through number of poketype combinations
            % only include cells with correlation higher than median

            heatplotA = poke_epochs(includecells,:,comb_pokesid(thiscomb,1));
            heatplotB = poke_epochs(includecells,:,comb_pokesid(thiscomb,2));

            % remove cells with nan due to lack of pokes
            nancellsA = find(all(isnan(heatplotA),2));
            nancellsB = find(all(isnan(heatplotB),2));
            heatplotA([nancellsA;nancellsB],:) = [];
            heatplotB([nancellsA;nancellsB],:) = [];

            % compute correlation
            [r_poke,p_poke] = corrcoef([heatplotA,heatplotB]);
            thisr_poke(:,thiscomb) = diag(r_poke(numframes+1:numframes*2,1:numframes)); % select the required correlation values from the matrix
            thisp_poke(:,thiscomb) = diag(p_poke(numframes+1:numframes*2,1:numframes)); % select the corresponding p values
        end

        % get all combinations with this poketype
        thispokeid = find(ismember(comb_pokes(:,1),Params.poketypes(thispoketype)) |  ...
            ismember(comb_pokes(:,2),Params.poketypes(thispoketype)));
        thiscomb = comb_pokes(thispokeid,:);
        r_pokes = thisr_poke(:,thispokeid);
        pvals = thisp_poke(:,thispokeid);
        pvals(pvals<0.05) = 0.05;
        pvals(pvals<0.01) = 0.01;
        pvals(pvals<0.001) = 0.001;
        nexttile
        hold on

        for i = 1:numel(thispokeid)
            pl(i) =  plot(r_pokes(:,i),'Color',c(i,:));
            plot(xvalues(pvals(:,i)==0.05),y*ones(sum(pvals(:,i)==0.05),1),'.','MarkerSize',A(1),'Color',c(i,:));
            plot(xvalues(pvals(:,i)==0.01),y*ones(sum(pvals(:,i)==0.01),1),'.','MarkerSize',A(2),'Color',c(i,:));
            plot(xvalues(pvals(:,i)==0.001),y*ones(sum(pvals(:,i)==0.001),1),'.','MarkerSize',A(3),'Color',c(i,:));
            y = y + 0.05;
        end
        ylabel('');  % Remove y-axis label
        xlabel('');

        if thispoketype~=1
            set(gca, 'YTickLabel', {});  % Remove y-axis tick labels
        end
        xticks(1:5:numframes)
        xlim([0,numframes])
        ylim([-0.2,1])
        set(gca,'fontname','arial')
        set(gca,'linewidth',0.8)
        set(gca,'fontsize',11)
        set(gca,'TickDir','out');
        set(gca,'box','off')
        xticklabels(-bfeventframes*Params.timebinlength/1000:afeventframes*Params.timebinlength/1000)
        grplbls = strcat(comb_pokes(thispokeid,1),{','}, comb_pokes(thispokeid,2));
        legend(pl,grplbls) %'Location','northeastoutside'
    end
    xlabel(t,'Time relative to correct choice poke (s)')
    ylabel(t,'Pearson correlation r')

    if thisarea==1
        fname= fullfile(dpath, 'Supplfig2C_ACC');
    else
        fname= fullfile(dpath, 'Suppplfig2C_mPFC');
    end

    print(gcf,'-vector','-dpdf',[fname,'.pdf'])

end
end