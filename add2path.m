%% add2path 
% adds the repo folder containing the functions and scripts to the path
% selects the userpath as stated in 'userpath.txt'

currDir = pwd;
[~,lastfolder,~] = fileparts(currDir);
if strcmp(lastfolder,'Jendryka_et_al_ACC_imaging_5CSRTT')
    addpath(genpath(currDir))
else
    fprintf('Run script from within the repo folder Jendryka_et_al_ACC_imaging_5CSRTT \n')
    fprintf('Exiting...')
    return
end

userpath(fileread('userpath.txt'))

% create directories for inserting data manually
file_name = fullfile(userpath,"data","behavior","behavior.zip");
mkdir(fileparts(file_name)) 
expnames = {'varITI','cb800ms','cbDeval1','cbExt1','cbExt2','mixedChalls'};

for thisexp = 1:numel(expnames)
    file_name = fullfile(userpath,"data","miniscope",expnames{thisexp},[expnames{thisexp},'.zip']); 
    mkdir(fileparts(file_name))
end 

%% download data from G-node GIN repository (not working at the moment)
%%% behavioral data
% url = 'https://gin.g-node.org/KaetzelLab/Jendryka_et_al_ACC_imaging_5CSRTT_data/src/master/behavior/behavior.zip';
% h = waitbar(0,'Downloading and unzipping behavioral file...');
% unzip(url,fileparts(file_name))
% close(h);
% disp('Behavioral file downloaded successfully.')

%%% calcium imaging data (pre-processed)
% url_base = 'https://gin.g-node.org/KaetzelLab/Jendryka_et_al_ACC_imaging_5CSRTT_data/src/master/miniscope';

% for thisexp = 1:numel(expnames)
% %     url = fullfile(url_base,[expnames{thisexp},'.zip']);
%     file_name = fullfile(userpath,"data","miniscope",expnames{thisexp},[expnames{thisexp},'.zip']); 
%     mkdir(fileparts(file_name))
% %     h = waitbar(0,sprintf('Downloading and unzipping %s file...',expnames{thisexp}));
% % 
% %     unzip(url,folder_saveto)
% %     close(h)
% %     sprintf('%s file downloaded successfully.',expnames{thisexp})
% end 

clear all, clc