%% arrangeData %%
% arranges the behavioral and calcium imaging data files into mat files for subsequent analysis
% before running this script, make sure that the behavioral files and
% calcium imaging data files are stored in the respective folders
%% ================================= get directories of calcium traces and behavioral files ==================
thispath = fullfile(userpath, 'data');
thispath_scope = fullfile(thispath, 'miniscope'); % store the calcium imaging data here
thispath_beh = fullfile(thispath, 'behavior'); % store the behavioral files here
% collect the directories of the data and arrange it into a cell array
% holding information about the animal, experiment date and other details
datalist = collectDirs(thispath_scope); 
datalist = behavFiles(datalist,thispath_beh);

for i = 1:numel(explist)
    thisexpname = explist(i);
    thisdatalist = datalist(ismember(datalist(:,5),thisexpname),:);

    %% ================================= Load calcium traces ==================
    [varlist,thisdatalist]=Loadrawsignal(thisdatalist,thispath_scope);

    %% ================================= load behavioral data and temporally align with calcium data ==================

    varlist = Arrangebehavior(thisdatalist,varlist,thispath_scope);

    %% ================================= extract calcium signal for timestamps of behavioral events ==================

    [varlist,eventlist]= Extractevents(thisdatalist,varlist);

    % %% save all workspace variables per experiment
    dpath = Choosesavedir('outputvars');
    dpath = fullfile(dpath, 'arrangedData', thisexpname{1});
    mkdir(dpath)

    ExportSglSes(varlist,eventlist,dpath)
    fprintf('Experiment %s done \n',explist{i})
    clearvars -except explist datalist thisexpname thispath_scope

end
clearvars -except explist
