clear,close all,clc

%% LOAD MAT FILE
loadmatname1 = 'getVars_4sbf7saf'; % mat file of descr Analysis
explist = {'varITILong','cb800ms','cbDeval1','cbExt1','cbExt2','mixedChalls'};
animals=[];
brainareas=[];
task=[];
numevents = [];
numpokes = [];
rewlatAll = [];
resplatAll = [];
expnames = [];
for thisexp = 1:numel(explist)
    thisexpname = explist{thisexp}; % data from which challenge to load
    dpath = Choosesavedir('outputvars');
    dpath = fullfile(dpath, 'getVars', thisexpname);
    load(fullfile(dpath, [loadmatname1 '_' thisexpname '.mat'])) %

    animals = [animals,infovar.animals];
    brainareas=[brainareas,infovar.brainareas];
    task = [task,infovar.task];
    expnames = [expnames,repelem(cellstr(thisexpname),1,numel(infovar.animals))];
    numevents =  [numevents,beh.numevents];
    pokes = cellfun(@(x) groupcounts(x,'IncludeEmptyGroups',true),beh.pokes,'UniformOutput',false);
    pokesAll = [];

    for thistrialtype = [1,2,4]
        pokesAll(:,:,thistrialtype) = catpad(2,pokes{thistrialtype,:});
    end

    numpokes = cat(2,numpokes,pokesAll);

    resplatMean = cell2mat(cellfun(@(x) median(x),beh.resplat,'UniformOutput',false));
    resplatMean(3,:) = [];
    resplatAll = [resplatAll,resplatMean];

    rewlatMean = cell2mat(cellfun(@(x) median(x,1),beh.rewlat,'UniformOutput',false));
    rewlatMean = reshape(rewlatMean,2,[]);
    rewlatAll = [rewlatAll,rewlatMean];
end

tbl = array2table(sortrows([animals',expnames',task',brainareas',...
    numevents',numpokes(:,:,1)',numpokes(:,:,2)',numpokes(:,:,4)',...
    resplatAll',rewlatAll'],[2,4,1]));

tbl.Properties.VariableNames={'AnimalID','Expname','Task','Brainarea','Corrects',...
    'Incorrects','Omissions','Prematures',...
    'poke1_corrects','poke2_corrects','poke3_corrects','poke4_corrects','poke5_corrects',...
    'poke1_incorrects','poke2_incorrects','poke3_incorrects','poke4_incorrects','poke5_incorrects',...
    'poke1_prematures','poke2_prematures','poke3_prematures','poke4_prematures','poke5_prematures',...
    'correct_resplat','incorrect_resplat','premature_resplat','rewardlatIn','rewardlatOut'};

tbl.Corrects = str2double(tbl.Corrects);
tbl.Incorrects = str2double(tbl.Incorrects);
tbl.Prematures = str2double(tbl.Prematures);
tbl.Omissions = str2double(tbl.Omissions);

tbl.Accuracy = round((tbl.Corrects./(tbl.Corrects + tbl.Incorrects)) * 100,2);
tbl.Omission_percent = round((tbl.Omissions./(tbl.Corrects+tbl.Incorrects+tbl.Prematures+tbl.Omissions)) * 100,2);
tbl.Premature_percent = round((tbl.Prematures./(tbl.Corrects+tbl.Incorrects+tbl.Prematures+tbl.Omissions)) * 100,2);

dpath = Choosesavedir('excel');
for thisexp = 1:numel(explist)
    writetable(tbl(tbl.Expname==explist{thisexp},:),fullfile(dpath,'behavior_tbl.xlsx'),'Sheet',explist{thisexp},'WriteMode','overwritesheet')
end