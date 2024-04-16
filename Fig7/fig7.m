% Fig.7 Encoding of reward and action in ACC depends on relative value and 
% presence of reward 
% Martin Jendryka
explist = {'cb800ms','cbDeval1','cbExt1','cbExt2'};
animals=[];
brainareas=[];
task=[];
cpd = [];
rewlatAll = [];
resplatAll = [];

%%% aggregate the decoding accuracies of the devaluation challenges into
%%% one table
baseline_ds = [{'regressAnalysis_4sbf7saf_dsTo_cbDeval1'},{'regressAnalysis_4sbf7saf_dsTo_cbExt1'},...
    {'regressAnalysis_4sbf7saf_dsTo_cbExt2'}];
thisarea =1;
thisepochtype = 3;
for thisexp = 1:numel(explist)
    thisexpname= explist{thisexp};
    dpath = Choosesavedir('outputvars');

    dpath2 = fullfile(dpath, 'getVars', thisexpname);
    load(fullfile(dpath2, ['getVars_4sbf7saf_' thisexpname '.mat']))

    if thisexp ~=1
        loadmatname2 = 'regressAnalysisPredMerged_4sbf7saf'; % mat file of classifier Analysis
        load(fullfile(dpath,'regressAnalysis', thisexpname , [loadmatname2 '_' thisexpname '.mat']))
    end

    animalselect = find(ismember(infovar.brainareas,Params.brainareas(thisarea)));

    rewlat = cellfun(@(x) mean(x,1,'omitnan'),beh.rewlat(animalselect),'UniformOutput',false);
    rewlat = median(cat(1,rewlat{:}),1,'omitnan');

    resplat = cellfun(@(x) mean(x,'omitnan'),beh.resplat(1,animalselect),'UniformOutput',false);
    resplat = median(cell2mat(resplat));
    rewlatAll(thisexp,:,thisarea) = rewlat;
    resplatAll(thisexp,thisarea) = resplat;

    if thisexp ==1
        for ind_chall_ds = 1:numel(baseline_ds) % load CPD for each downsampled baseline challenge
            loadmatname2 = [baseline_ds{ind_chall_ds}]; % mat file of classifier Analysis
            load(fullfile(dpath,'regressAnalysis', thisexpname , [loadmatname2 '_' thisexpname '.mat']))
            for thisanimal = animalselect
                cpd_cat=[];
                for i = 1:size( regressvar.cpd,1) % iterate across repetitions
                    cpd_cat(:,:,:,i) =  regressvar.cpd{i,thisanimal}{thisepochtype};
                end
                thiscpd_mean = mean(cpd_cat,4,'omitnan'); % take mean across iterations
                cpd_mean = squeeze(mean(thiscpd_mean,2,'omitnan')); % take mean across cells
                cpd = cat(3,cpd,cpd_mean);
            end
            animals = [animals,infovar.animals(animalselect)];
            brainareas=[brainareas,infovar.brainareas(animalselect)];
            task = [task,infovar.task(animalselect)];
        end
    else
        for thisanimal = 1:numel(animalselect)
            thiscpd = regressvar.cpd{thisepochtype,thisarea};
           
            cpd_mean = squeeze(mean(thiscpd,2,'omitnan')); % mean across cells
            cpd = cat(3,cpd,cpd_mean);
        end
        animals = [animals,infovar.animals(animalselect)];
        brainareas=[brainareas,infovar.brainareas(animalselect)];
        task = [task,infovar.task(animalselect)];
    end
end
tbl = array2table(sortrows([animals',task',brainareas'],[2,3,1]));
tbl.Properties.VariableNames(1:3)={'AnimalID','Task','Brainarea'};

Fig7A(tbl,Params,rewlatAll,resplatAll,thisepochtype,cpd)