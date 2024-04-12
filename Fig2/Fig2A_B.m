function Fig2A_B(Params,infovar,eventepochs, thisepochtype)

%% Fig.2 A,B
% creates a figure with 4 tiles each corresponding to one of the Params.trialtypes (correct,incorrect, omission, premature) for the selected epoch 
% zscored calcium activity is averaged across trials and displayed for each timebin for each cell from the ACC (Fig.2A) or mPFC
% (Fig.2B) neurons, sorted by peak latency
% upper and bottom plots show heatplots for odd and even trials,
% respectively; plots in the middle display to temporal correlations
% betweem upper and bootom heat plots

%%
%%% set directory for storing figures
dpath = Choosesavedir('figs');
dpath = fullfile(dpath, 'Fig2');
mkdir(dpath)
numframes = Params.frames.num(thisepochtype);
bfeventframes = Params.frames.bfevent(thisepochtype);
afeventframes = Params.frames.afevent(thisepochtype);

r = []; % pre-allocate variable for correlation values 
for thisarea = 1:numel(Params.brainareas) % loop through brain areas
    animalselect = find(ismember(infovar.brainareas,Params.brainareas(thisarea)));
   
    figure
    t = tiledlayout(3,numel(Params.trialtypes),'TileSpacing', 'compact', 'Padding', 'compact');
    xlabel(t,'Time from task event (s)')
    ylabel(t,'Cell ID')
    
    for thistrialtype = 1:numel(Params.trialtypes) % loop-start through Params.trialtypes
        epochs_avgOdd = [];
        epochs_avgEven = [];
        for thisses = animalselect % iterate through sessions with same brain area

            epochs_ses = eventepochs{thisses}{thistrialtype,thisepochtype}; % get event activity for session, trialtype and epochtype
            if size(epochs_ses,3)< 2 % if there is <2 trials, average across odd trials cannot be calculated, so put them nan (will be plotted grey in heatplot)
                epochs_ses_Odd = nan(size(epochs_ses,[1,2]));
                epochs_ses_Even =  nan(size(epochs_ses,[1,2]));
            else
                epochs_ses_Odd = mean(epochs_ses(:,:,1:2:end),3); % take average across odd trials
                epochs_ses_Even = mean(epochs_ses(:,:,2:2:end),3); % take average across even trials
            end
            epochs_avgOdd = cat(1,epochs_avgOdd,epochs_ses_Odd); % concatenate averages
            epochs_avgEven = cat(1,epochs_avgEven,epochs_ses_Even);
        end
        
        %%% sort cells by peak latency
        [~,maxidx] = max(epochs_avgOdd,[],2);         
        [~,sortidx] = sort(maxidx);
        nancells = find(all(isnan(epochs_avgOdd),2));   % find nan rows corresponding to Params.trialtypes not existing for cells
        sortidx(ismember(sortidx,nancells)) = [];
        sortidx = [nancells;sortidx]; % put nan rows on top of heatplots
        epochs_avgOddSort = epochs_avgOdd(sortidx,:);
        epochs_avgEvenSort = epochs_avgEven(sortidx,:);

        %% correlation between odd and even heat plots
        epochs_avgOdd2 = reshape(epochs_avgOdd(~isnan(epochs_avgOdd)),[],numframes);
        epochs_avgEven2 = reshape(epochs_avgEven(~isnan(epochs_avgEven)),[],numframes);
        [thisr,thisp] = corrcoef([epochs_avgOdd2,epochs_avgEven2]); % correlation between odd and even heat plots
        thisr2 = diag(thisr(numframes+1:numframes*2,1:numframes)); % select the required correlation values from the matrix
        thisp2 = diag(thisp(numframes+1:numframes*2,1:numframes)); % select the corresponding p values
        r{thistrialtype,thisarea} = thisr2;
        p{thistrialtype,thisarea} = thisp2;


        %% plot heatplots
        %%% for odd trials
        ax(1,thistrialtype) = nexttile(thistrialtype);
        imAlpha=ones(size(epochs_avgOddSort));
        imAlpha(isnan(epochs_avgOddSort))=0;

        imagesc(ax(1,thistrialtype),epochs_avgOddSort,'AlphaData',~isnan(epochs_avgOddSort))
        caxis([-1 7])

        %%% for r values
        pos = numel(Params.trialtypes)+thistrialtype;
        ax(2,thistrialtype) = nexttile(pos);
        imagesc(ax(2,thistrialtype),thisr2');
        caxis([0 1])

        %%% for even trials
        pos = numel(Params.trialtypes)*2+thistrialtype;
        ax(3,thistrialtype) = nexttile(pos);
        imAlpha=ones(size(epochs_avgEvenSort));
        imAlpha(isnan(epochs_avgEvenSort))=0;
        imagesc(ax(3,thistrialtype),epochs_avgEvenSort,'AlphaData',~isnan(epochs_avgEvenSort))
        caxis([-1 7])

    end
    %% edit plots
    
    titles = {'oddTrials','r','evenTrials'};

    for i = 1:size(ax,1)
        for ii = 1:numel(Params.trialtypes)
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
                title(ax(i,ii),Params.trialtypes{ii})
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

            if isequal(ii,4)
                colorbar(ax(i,ii))
            end

        end
    end
    
    %%% specify saving directory
    if thisarea ==1
        fname = fullfile(dpath, ...
            ['Fig2A_' char(Params.epochtypes(thisepochtype))]);
    else
        fname = fullfile(dpath, ...
            ['Fig2B_' char(Params.epochtypes(thisepochtype))]);
    end
    set(gcf, 'InvertHardCopy', 'off'); % so that grey is not inverted to white after saving graphics
    print(gcf,'-vector','-dpdf',[fname,'.pdf']) % save as pdf
end
 % export r and p to excel file
    dpath = Choosesavedir('excel');
    dpath = fullfile(dpath, 'Fig2');
    mkdir(dpath)
    fname = fullfile(dpath,  ['heatmapCorr_Fig2A_B'   '.xlsx' ]);
   
    writecell(squeeze(r(:,1)),fname,'Sheet',['r_ACC'])
    writecell(squeeze(p(:,1)),fname,'Sheet',['p_ACC'])
    writecell(squeeze(r(:,2)),fname,'Sheet',['r_mPFC'])
    writecell(squeeze(p(:,2)),fname,'Sheet',['p_mPFC'])