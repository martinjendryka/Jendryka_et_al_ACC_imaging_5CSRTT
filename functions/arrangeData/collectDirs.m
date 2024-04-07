% select miniscope folder in popup window
function list = collectDirs(thispath)

delete(fullfile(thispath,'.DS_Store'));


d = dir(thispath);
d(1:2) = [];

list = {};

for i = 1:numel(d)
    expname = d(i).name;
    delete(fullfile(thispath,expname,'.DS_Store'));
    % d contains also two elements with '.' and '..'
    % returns logical vector wether elements of d are directories or not
    d2 = dir(fullfile(thispath,expname));
    d2name = {d2.name};
    idx =  contains(d2name,'traces'); % get traces files
    tracesdir = d2name(idx);
    namesplit = cellfun(@(x) strsplit(x,'_'),tracesdir,'UniformOutput',false);
    namesplit = cat(1,namesplit{:});
    animal = namesplit(:,3);
    dates = namesplit(:,4);
    rectime = namesplit(:,5);
    list = [list; tracesdir',namesplit(:,3),namesplit(:,4),namesplit(:,2)]; % dir_calciumfile | animal_id | date | experiment name
end
end