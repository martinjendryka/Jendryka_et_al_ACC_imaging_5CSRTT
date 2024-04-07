[filelist] = uigetdir2; % select the mat files of each animal created by createDatabase

elems    = regexp(filelist,'\');
recname = extractAfter(filelist,elems{1}(end));
elems    = regexp(recname,'_');
animals2 = extractBefore(recname,elems{1}(1));
animalPrl = ["8264","8271","8390","8394","8396","8400","6982","6983","6984",...
    "6985","B041","B043","B585","B611"];
animalCg = ["B013","8062","8592","6965","6997","A539","6998","A648","6964","6961","6963"]; % for all these animals histo was checked
animalCg1= ["A539","A602","A648","8263","8389","8393","8401","6964","6962","6963","1805",...
    "1804","1802","8503","8504","8508","8592","6998","6961"];
animalCg2= ["6996","6997","6960","B013","8062","6965"];
%%
cpd = {};
beta = {};
counter1= 1;
counter2= 1;
for i = 1:numel(filelist)
    load(filelist{i})

    thisanimal = animals2{i};

    if ismember(thisanimal,[animalCg1,animalCg2,animalCg])
        thisregion = {'cingulate'};
    else
        thisregion= {'prelimbic'};
    end
    
        if strcmp(thisregion,'cingulate')
            cpd(1,counter1) = {regressvar.cpd};
            beta(1,counter1) = {regressvar.beta};
            counter1 = counter1 + 1;
        else
            cpd(2,counter2) = {regressvar.cpd};
            beta(2,counter2) = {regressvar.beta};
            counter2 = counter2 + 1;
        end
end
% clear regressvar
regressvar.beta = beta;
regressvar.cpd = cpd;

save([userpath 'results\miniscope5csrtt\mat\output\PCAICA\zval\sorted\regressionAnalysis\varITIlong\' 'regressAnalysis2sbf1saf_varITILong.mat'],'regressvar')