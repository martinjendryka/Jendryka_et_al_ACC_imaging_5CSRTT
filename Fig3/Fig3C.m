function Fig3C(Params,varlist,classifier,beh,thisepochtype)
%% Fig.3 C
% same as Fig3A-B, plots the decoding accuracy for binary classifiers in predicting the
% trialtype (eg. corrects vs omissions) for each timebin during the
% selected epoch type for the ACC(Fig.3C), mPFC not used due to lack of
% sessions with required trial number

%%
dpath = Choosesavedir('figs');
dpath = fullfile(dpath, 'Fig3');
dpathexcel = Choosesavedir('excel');
dpathexcel = fullfile(dpathexcel, 'Fig3');

mkdir(dpath)
mkdir(dpathexcel)

pdecod = classifier.pdecod;
pdecodShuffled = classifier.pdecodShuffled;

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

thisepochstrs = char(epochtypes(thisepochtype));

A=[8 12 16]; % three sizes for p=0.05, p=0.01, p =0.001, p= 0.0001
clrsEpochs = [0 1 0;... % green
    ];
thisarea = 1:numel(brainareas);
animalselect = find(ismember(varlist.brainareas,Params.brainareas(thisarea))); % get indices for animals with same brain area

rewlat = median(vertcat(beh.rewlat{animalselect}),1,'omitnan');

animals= varlist.animals(animalselect);
areas= varlist.brainareas(animalselect);
task= varlist.task(animalselect);

figure
hold on
counter2 = 1;
allcmbstrs = [];
d=0;

thisbinaryclassifier = 1; % correct vs incorrect classifier
cmbstr = horzcat(trialtypes{trialcombs(thisbinaryclassifier,:)});
allcmbstrs = [allcmbstrs,cellstr(cmbstr)];
daCat=[];
daCatShuffled = [];


da = [];
daShuffled = [];
counter =1;
animalsExport ={};
brainExport = {};
taskExport = {};

for thisanimal = 1:size(pdecod{thisarea},3)
    thisda = pdecod{thisarea}{thisepochtype,thisbinaryclassifier,thisanimal}; % thisses X timebins X iterations
    thisdaShuffled = pdecodShuffled{thisarea}{thisepochtype,thisbinaryclassifier,thisanimal};

    if ~isempty(thisda)
        animalsExport(counter) = animals(thisanimal);
        brainExport(counter) = areas(thisanimal);
        taskExport(counter) = cellstr(task(thisanimal));
        da(:,:,counter) = mean(thisda,2); % average across iterations
        daShuffled(:,:,counter) = mean(thisdaShuffled,2);
        counter = counter +1;
    end
end

if isempty(da)
    counter2= counter2 + 1;

else
    tblexport = table(animalsExport',taskExport',brainExport','VariableNames',{'animals','task','brainarea'});
    tblexport = [tblexport,array2table((squeeze(da))')];
    writetable(tblexport,fullfile(dpathexcel,['Fig3A_B_'  '.xlsx']),'Sheet',[char(join(trialtypes(trialcombs(thisbinaryclassifier,:)))),brainareas{thisarea}])

    da = squeeze(da);
    daShuffled= squeeze(daShuffled);

    %%% plot averages
    daAvg = mean(da,2,'omitnan'); % average across animals
    daErr = std(da,[],2,'omitnan');
    daErr = daErr/sqrt(size(da,2));
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
    h(counter2+1) = plot(xvalues,avg_traces,'LineWidth',1,'Color',clrsEpochs(counter2,:),'LineStyle','--');


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
        pvals_sig(thispvals<0.0001) = 0.0001;
    end

    y = 1.2 + d;

    plot(xvalues(pvals_sig==0.05),y*ones(sum(pvals_sig==0.05),1),'.','MarkerSize',A(1),'Color',clrsEpochs(counter2,:));
    plot(xvalues(pvals_sig==0.01),y*ones(sum(pvals_sig==0.01),1),'.','MarkerSize',A(2),'Color',clrsEpochs(counter2,:));
    plot(xvalues(pvals_sig==0.001),y*ones(sum(pvals_sig==0.001),1),'.','MarkerSize',A(3),'Color',clrsEpochs(counter2,:));

    d = d + 0.02;

    counter2 = counter2 +1;
end

ylim([0 1.4])
yticks(0:0.2:1)
xticks(1:5:numframes)
xlim([0,numframes])

lat1 = nan;
lat2 = nan;
lat3 = nan;

if thisepochtype == 3
    resplat = median(catpad(2,beh.resplat{1,...
        ismember(varlist.brainareas,brainareas(thisarea))}),[1,2],'omitnan');

    lat1 = resplat;
    lat2 = rewlat(1);
    lat3 = lat2 + rewlat(2);

elseif thisepochtype == 1
    resplat = median(catpad(2,beh.resplat{4,...
        ismember(varlist.brainareas,brainareas(thisarea))}),[1,2],'omitnan');
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

xticklabels(-bfeventframes*timebinlength/1000:afeventframes*timebinlength/1000)
legend(h,repmat(cellstr(cmbstr),1,2),'Location','northeastoutside')

set(gca,'fontname','arial')
set(gca,'linewidth',0.8)
set(gca,'fontsize',11)
set(gca,'TickDir','out');
set(gca,'box','off')

xlabel('Time relative to task event (s)')
ylabel('Decoding accuracy (%)')

fname= fullfile(dpath,['Fig3C_',char(epochtypes(thisepochtype))]);

print(gcf,'-vector','-dpdf',[fname,'.pdf'])

end