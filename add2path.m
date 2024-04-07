%% add2path 
% adds the repo folder containing the functions and scripts to the path
% selects the userpath as stated in 'userpath.txt'

currDir = pwd;
[~,lastfolder,~] = fileparts(currDir);
if strcmp(lastfolder,'manuscript')
    addpath(genpath(currDir))
else
    fprintf('Run script from within manuscript repo \n')
    fprintf('Exiting...')
    return
end

userpath(fileread('/Users/martinjendryka/Research/Projects/miniscope5csrtt/repo/miniscope5csrtt_final/userpath.txt'))
%% create folders where raw data is saved

expnames = {'varITILong','cb800ms','cbDeval1','cbExt1','cbExt2'};

for thisexp = 1:numel(expnames)
        mkdir(fullfile(userpath,"data","miniscope",expnames{thisexp})) % insert calcium imaging data into the folder matching the experiment name
end

mkdir(fullfile(userpath,"data","behavior")) % insert behavioral data into this folder

