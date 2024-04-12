function Fig2E_F(Params,infovar,eventlistAll,eventepochs,clusters,beh,thisepochtype)

%% Fig.2 E,F
% creates a figure showing the zscored calcium activity of example cells for single trials for different trialtypes (correct,incorrect, omission, premature) during the pre-defined epochtype
% for the ACC (Fig.2E) or mPFC
% (Fig.2F)

%%

dpath = Choosesavedir('figs');
dpath = fullfile(dpath,'Fig2');
rewlat = beh.rewlat; % reward latencies

example_cells = [32,430,116,97;
    45,167,141,84]; % example cells as shown in Fig.2E,F
numframes = Params.frames.num(thisepochtype);
bfeventframes = Params.frames.bfevent(thisepochtype);
afeventframes = Params.frames.afevent(thisepochtype);

for thisarea = 1:numel(Params.brainareas) % for-loop through brain areas
    animalselect = find(ismember(infovar.brainareas,Params.brainareas(thisarea)));
    ncells = infovar.ncells(animalselect);
    sesid = repelem(animalselect,ncells); % tells me from which session each cell comes from
    
    cell_id_ses = arrayfun(@(n) 1:n, ncells, 'UniformOutput', false);
    cell_id_ses = cat(2,cell_id_ses{:});

    figure
    t = tiledlayout(4,4,'TileSpacing', 'compact', 'Padding', 'compact');
    xlabel(t,'Time from task event (s)')
    ylabel(t,'Trials')
    c=1;
    allcells=[];
    
    cell_id_cluster = clusters.cellid{thisarea}(:,1,3);
    cluster_id = clusters.clusterid{thisarea}(:,1,3);
    cluster_exampleCells = [];
    for i = 1:size(example_cells,2)
    cluster_exampleCells(i) = cluster_id(cell_id_cluster==example_cells(thisarea,i));
    end
    
    for i_cell = 1:Params.nCluster % for-loop through number of clusters
            thiscell = example_cells(thisarea,i_cell);
            thiscluster = cluster_id(cell_id_cluster == thiscell);
            % get latwhich session does this cell belong to
            thissesid = sesid(thiscell);
            thisrewlat = rewlat{thissesid};
            thiseventtime = cellfun(@(x) x(:,3), eventlistAll(thissesid).eventtime,'UniformOutput',false); % get latencies for the cells
            thiseventtime = cat(1,thiseventtime{:});
            thisevents = repelem(Params.trialtypes',beh.numevents(:,thissesid)');
            [~,sortidx] = sort(thiseventtime(~isnan(thiseventtime)));
            thiseventsSorted = thisevents(sortidx);

            for thistrialtype = 1:numel(Params.trialtypes) % for-loop through trialtypes

                thisepochs = eventepochs{thissesid}{thistrialtype,thisepochtype}; % get event activity for session, trialtype and epochtype
                thistrialidx = find(ismember(thiseventsSorted,Params.trialtypes(thistrialtype)));
                
                thisepochs_cell = squeeze(thisepochs(cell_id_ses(thiscell),:,:))';
                thisepochs_cell(all(isnan(thisepochs_cell),2),:) = []; % remove all missing trials

                ax(c,thistrialtype) = nexttile;

                im = imagesc(thisepochs_cell);

                set(im, 'AlphaData', ~isnan(thisepochs_cell))%%% required to plot nan values black
                set(gca, 'Color', [0.7, 0.7, 0.7]) %%% required to plot nan values black

                if bfeventframes==0
                    zeroline = 0;
                else
                    zeroline = bfeventframes+1;
                    xline(zeroline,'LineWidth',1,'Color','k')
                end
  
                resplat = beh.resplat(thistrialtype,:);
                thislat = resplat{thissesid};
                
                if ismember(thistrialtype,[1,2])
                    for thistrial = 1:size(thisepochs_cell,1)
                        prevIdx = thistrialidx(thistrial)-1;
                        outcomecolor = 'k';

                        thisx = zeroline-thislat(thistrial)/Params.timebinlength;
                        line([thisx,thisx],[thistrial+0.5,thistrial-0.5],'Color',outcomecolor,'LineWidth',1)

                        if thistrialtype==1
                            thisx = zeroline+thisrewlat(thistrial,1)/Params.timebinlength;
                            line([thisx,thisx],[thistrial+0.5,thistrial-0.5],'Color',outcomecolor,'LineWidth',1)
                            thisx = zeroline+thisrewlat(thistrial,2)/Params.timebinlength;
                            line([thisx,thisx],[thistrial+0.5,thistrial-0.5],'Color',outcomecolor,'LineWidth',1)
                        end
                    end

                elseif thisepochtype==1 && thistrialtype ==4
                    for thistrial= 1:size(thisepochs_cell,1)
                        thisx = zeroline+thislat(thistrial)/Params.timebinlength;
                        line([thisx,thisx],[thistrial+0.5,thistrial-0.5],'Color',outcomecolor,'LineWidth',1)
                    end
                end
                caxis([-1 7])
            end
        c = c +1;
    end
    cbh =colorbar(ax(end));
    cbh.Layout.Tile = 'south';
    for i = 1:size(ax,1)
        axes(ax(i,4))
        xlims = get(ax(i,4), 'XLim');
        ylims = get(ax(i,4), 'YLim');
        text(xlims(2) + (diff(xlims) * 0.05), mean(ylims), ['cellID ' num2str(example_cells(thisarea,i)), ' cluster' num2str(cluster_exampleCells(i))], 'Rotation', 270,'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');

        for ii = 1:numel(Params.trialtypes)
            set(ax(i,ii),'Box','off')
            set(ax(i,ii),'TickDir','out')
            set(ax(i,ii), 'Color', [0.7,0.7, 0.7]) %%% required to plot nan values black
            set(ax(i,ii),'XTickLabel','')
            set(ax(i,ii),'Colormap',bluewhitered)

            if isequal(i,1)
                title(ax(1,ii),Params.trialtypes{ii})
            end

            if isequal(i,size(ax,1))
                set(ax(i,ii),'XTick',1:5:numframes)
                set(ax(i,ii),'XTickLabel',[-bfeventframes*Params.timebinlength/1000:1:afeventframes*Params.timebinlength/1000],'XTickLabelRotation',45)
            end
        end
    end

    if thisarea==1
        fname = fullfile(dpath ,['Fig2E_cluster',...
            char(Params.epochtypes(thisepochtype))]);
    else
        fname = fullfile(dpath ,['Fig2Fcluster',...
            char(Params.epochtypes(thisepochtype))]);
    end
    mkdir(fileparts(fname))
    set(gcf, 'InvertHardCopy', 'off');
    print(gcf,'-vector','-dpdf',[fname,'.pdf'])
    clear ax
end
end