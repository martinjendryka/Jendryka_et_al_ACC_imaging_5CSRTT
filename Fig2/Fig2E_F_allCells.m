%% plotpeth_singleCells
function Fig2E_F_allCells(Params,infovar,eventlistAll,epochscat,clusters,beh,epochSessionid,thisepochtype)
%% Fig.2 E,F
% creates plots for all cells showing the zscored calcium activity for single trials for different trialtypes (correct,incorrect, omission, premature) during the pre-defined epochtype
% for the ACC or mPFC

%%
dpath = Choosesavedir('figs');
dpath = fullfile(dpath,'Fig2');
rewlat = beh.rewlat;

for thisarea = 1:numel(Params.brainareas)
    animalselect = find(ismember(infovar.brainareas,Params.brainareas(thisarea)));
    ncells = infovar.ncells(animalselect);
    sesid = repelem(animalselect,ncells); % tells me from which session each cell comes from
   
    cell_id_ses = arrayfun(@(n) 1:n, ncells, 'UniformOutput', false);
    cell_id_ses = cat(2,cell_id_ses{:});

    clusterid = clusters.clusterid{thisarea}(:,3);
    cellid = clusters.cellid{thisarea}(:,3);
    sesid = epochSessionid{thisarea};

    numframes = Params.frames.num(thisepochtype);
    bfeventframes = Params.frames.bfevent(thisepochtype);
    afeventframes = Params.frames.afevent(thisepochtype);

    for thiscluster = 1:Params.nCluster
        cells_cluster = cellid(clusterid==thiscluster);
        counter = 1;

        for thiscellid = 1:numel(cells_cluster)
            if ismember(thiscellid,1:4:numel(cells_cluster))
                figure
                t = tiledlayout(4,4,'TileSpacing', 'compact', 'Padding', 'compact');
                xlabel(t,'Time from task event (s)')
                ylabel(t,'Trials')
                allcells=[];
                c=1;
            end
            thiscell = cells_cluster(thiscellid);
            allcells = [allcells;thiscell];

            % which session does this cell belong to
            thissesid = sesid(thiscell,1);
            thisrewlat = rewlat{thissesid};
            thiseventtime = cellfun(@(x) x(:,3), eventlistAll(thissesid).eventtime,'UniformOutput',false);
            thiseventtime = cat(1,thiseventtime{:});
            thisevents = repelem(trialtypes',beh.numevents(:,thissesid)');
            [~,sortidx] = sort(thiseventtime(~isnan(thiseventtime)));
            thiseventsSorted = thisevents(sortidx);

            for thistrialtype = 1:numel(trialtypes)
                resplat = beh.resplat(thistrialtype,:);
                thislat = resplat{thissesid};

                thisepochs = epochscat{thistrialtype,thisepochtype,thisarea};

                thistrialidx = find(ismember(thiseventsSorted,trialtypes(thistrialtype)));

                thisepochs_cell = squeeze(thisepochs(thiscell,:,:))';
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

            if isequal(c,4) || thiscellid == numel(cells_cluster)
                for i = 1:size(ax,1)
                    axes(ax(i,4))
                    xlims = get(ax(i,4), 'XLim');
                    ylims = get(ax(i,4), 'YLim');
                    text(xlims(2) + (diff(xlims) * 0.05), mean(ylims), ['cellID ' num2str(allcells(i))], 'Rotation', 270,'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');

                    for ii = 1:numel(trialtypes)
                        set(ax(i,ii),'Box','off')
                        set(ax(i,ii),'TickDir','out')
                        set(ax(i,ii), 'Color', [0.7,0.7, 0.7]) %%% required to plot nan values black
                        set(ax(i,ii),'XTickLabel','')
                        set(ax(i,ii),'Colormap',bluewhitered)

                        if isequal(i,1)
                            title(ax(1,ii),trialtypes{ii})
                        end

                        if isequal(i,size(ax,1))
                            set(ax(i,ii),'XTick',1:5:numframes)
                            set(ax(i,ii),'XTickLabel',-bfeventframes*timebinlength/1000:afeventframes*timebinlength/1000)
                        end
                    end
                end
                cbh =colorbar(ax(end));
                cbh.Layout.Tile = 'south';
                if thisarea==1
                    fname = fullfile(dpath ,'Fig2E',['Fig2E_cluster', num2str(thiscluster), '_' ,num2str(counter),...
                        char(epochtypes(thisepochtype))]);
                else
                    fname = fullfile(dpath ,'Fig2F',['Fig2Fcluster', num2str(thiscluster), '_' ,num2str(counter),...
                        char(epochtypes(thisepochtype))]);
                end
                mkdir(fileparts(fname))
                set(gcf, 'InvertHardCopy', 'off'); % so that black is not inverted to white after saving graphics
                Printfig(fname)
                close(gcf)
                counter = counter + 1;
                clear ax
            end
            c = c +1;
        end
    end
end