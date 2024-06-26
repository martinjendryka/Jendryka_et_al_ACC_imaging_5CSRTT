% Fig.6 Decoding of behavioral choice from population activity in ACC
% during reward devaluation and extinction experiments
% Martin Jendryka
%% LOAD MAT FILE
explist = {'cb800ms','cbDeval1','cbExt1','cbExt2'};
animals=[];
brainareas=[];
task=[];
da_combAll = {};
rewlatAll = [];
resplatAll = [];

%%% aggregate the decoding accuracies of the devaluation challenges into
%%% one table
thisepochtype = 3; % select the epoch you want the figures for
for thisexp = 1:numel(explist)

    thisexpname = explist{thisexp}; % data from which challenge to load
    dpath = Choosesavedir('outputvars');
    dpath = fullfile(dpath, 'getVars', thisexpname);
    load(fullfile(dpath, ['getVars_4sbf7saf_' thisexpname '.mat'])) %
    dpath = Choosesavedir('outputvars');
    load(fullfile(dpath,'binaryClassifier', thisexpname ,['binaryClassifier_4sbf7saf_' thisexpname '.mat']))
    da_area={};
    thisarea=1;
    selectanimals = ismember(infovar.brainareas,Params.brainareas(thisarea));
    animals = [animals,infovar.animals(selectanimals)];
    brainareas =[brainareas,infovar.brainareas(selectanimals)];
    task = [task,infovar.task(selectanimals)];
    rewlat = cellfun(@(x) median(x,1,'omitnan'), beh.rewlat(selectanimals),'UniformOutput',false);
    rewlat = median(cat(1,rewlat{:}),1);
    resplat= cellfun(@(x) median(x,'omitnan'),beh.resplat(1,selectanimals),'UniformOutput',false);
    resplat = median(cell2mat(resplat));
    rewlatAll(thisexp,:,thisarea) = rewlat;
    resplatAll(thisexp,thisarea) = resplat;
    da_comb={};

    for thiscomb = 1:size(Params.trialcombs,1)
        da = cellfun(@(x) mean(x,2,'omitnan'), squeeze(classifier.pdecod(thisepochtype,thiscomb,selectanimals)),'UniformOutput',false); % mean across iterations
        da_comb(:,thiscomb) = da;
    end
    da_area =[da_area;da_comb];

    da_combAll = [da_combAll;da_area];
end
tbl = sortrows([animals',task',brainareas'],[2,3,1]);
tbl = [cellstr(tbl),da_combAll];
%% create plots for Fig6E_F
Fig6E_F(tbl,Params,rewlatAll,resplatAll,thisepochtype)