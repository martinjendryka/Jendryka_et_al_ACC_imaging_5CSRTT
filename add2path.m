%% add2path 
% adds the repo folder containing the functions and scripts to the path
% selects the userpath as stated in 'userpath.txt'

currDir = pwd;
[~,lastfolder,~] = fileparts(currDir);
if strcmp(lastfolder,'Jendryka_et_al_ACC_imaging_5CSRTT')
    addpath(genpath(currDir))
else
    fprintf('Run script from within Jendryka_et_al_ACC_imaging_5CSRTT repo \n')
    fprintf('Exiting...')
    return
end

userpath(fileread('userpath.txt'))
%% create folders where raw data is saved

expnames = {'varITI','cb800ms','cbDeval1','cbExt1','cbExt2','mixedChalls'};

for thisexp = 1:numel(expnames)
        mkdir(fullfile(userpath,"data","miniscope",expnames{thisexp})) % insert calcium imaging data into the folder matching the experiment name
end

mkdir(fullfile(userpath,"data","behavior")) % insert behavioral data into this folder

