%%% loads the trace files from pre-processing and removes data entries
%%% without calcium imaging files
function [varlist,datalist] = Loadrawsignal(datalist,thispath_scope)

[~, sortidx] = sort(datalist(:,2)); % sort by animal id
datalist = datalist(sortidx,:);
%% load calcium traces
% pre-allocate variables
varlist.casig = cell(1,size(datalist,1));
varlist.spatialmap = cell(1,size(datalist,1));

novarsessions = {};
missingsessions = {};
thisexp= unique(datalist(:,5));
for i = 1:numel(datalist(:,1))
    lastwarn('')
    sigfn = [];
    casig = [];
    tracefilename = fullfile(thispath_scope,thisexp,datalist(i,1));
    load(tracefilename{1},'traces','filters');
     %%% z-transformation of calcium signal along each cell's mean and std
            %%% xi(thiscell) - mean(thiscell)  / std(thiscell)           
    traces_norm = zscore(traces,[],2);
    
    varlist.casig(i) = {traces_norm};
    varlist.spatialmap(i) = {filters};
end

%%% add info
% animal names
varlist.animalnames = datalist(:,2)';

% exp dates
varlist.expdate = datalist(:,3)';

% task
varlist.taskname = datalist(:,4)';

% number of cells for each session
varlist.ncells = cellfun('size',varlist.casig,1);
varlist.brainarea = datalist(:,7)';
varlist.info = [varlist.animalnames;varlist.brainarea;varlist.taskname;varlist.expdate;num2cell(varlist.ncells)];

end