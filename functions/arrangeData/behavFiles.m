%% add dir name of behavioral file to datalist
% only one file for each animal must be in the date
% folder,
function list = behavFiles(inputList,behav)
% select folder behavior when window opens

animalPFC = ["8264","8271","8390","8394","8396","8400","6982","6983","6984",...
    "6985","B041","B043","B585","B611"];
animalACC = ["B013","8062","8592","6965","6997","A539","6998","A648","6964","6961","6963",...
    "A539","A602","A648","8263","8389","8393","8401","6964","6962","6963","1805",...
    "1804","1802","8503","8504","8508","8592","6998","6961"]; % for all these animals histo was checked
animalCg1= [];
animalCg2= [];

mydate = inputList(:,3);
mytask = inputList(:,4);
for i = 1: length(inputList(:,1))
    thisanimal = inputList{i,2};
    thisdate = inputList{i,3};
    thisexp = inputList(i,4);

    % change date format to yyyy-mm-dd as in  raw behavioral file
    thisdate2 = ['-',thisdate(1:4), '-', thisdate(5:6), '-',...
        thisdate(7:8)];
    ses = dir(fullfile(behav,sprintf('%s%s*.csv',thisanimal,thisdate2)));

    if ~isempty(ses)
        sesname = ses.name;
        behavfile = fullfile(behav,sesname);
        inputList(i,5) = {behavfile};
        % add brain area
        if ismember(thisanimal,animalPFC)
            inputList(i,6) = {'prelimbic'};
        elseif ismember(thisanimal,animalACC)
            inputList(i,6) = {'cingulate'};
        else
            error(['no brainarea for animal' thisanimal])
        end
    else
        error(['missing behavior file: ' inputList{i,1}])
    end

    list = inputList;
end