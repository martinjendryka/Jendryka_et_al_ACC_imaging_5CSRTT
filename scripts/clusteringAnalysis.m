
explist = {'varITI'};
for thisexp = 1:numel(explist)
    %% load mat file
    thisexpname = explist{thisexp}; % data from which challenge to load
    dpath = Choosesavedir('outputvars');
    dpath = fullfile(dpath, 'getVars', thisexpname);
    load(fullfile(dpath, ['getVars_4sbf7saf_' thisexpname '.mat'])) % mat files from descrAnalysis

    clusters = Kmeanclustering(Params,infovar,eventepochsAll);

    % save outputs as mat files
    dpath = Choosesavedir('outputvars');
    dpath = fullfile(dpath, 'clusters', thisexpname);
    mkdir(dpath)
    save(fullfile(dpath, ['clusters_4sbf7saf_' thisexpname '.mat']), 'clusters');
    fprintf('Experiment %s done \n',thisexpname)

    clearvars -except explist thisexp
end