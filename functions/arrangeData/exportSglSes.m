%%% %% generate mat file for each animal and for each experiment
function ExportSglSes(varlist2,eventlist2,dpath)
ex = varlist2;
ex2 = eventlist2;
% clear varlist eventlist

for i = 1:numel(ex.animalnames)

    for f=fieldnames(ex)'
        varlist.(f{1}) = ex.(f{1})(i);
    end

    for f=fieldnames(ex2)'
        eventlist.(f{1}) = ex2.(f{1})(:,i);
    end

    % save to mat file
    save(fullfile(dpath, [varlist.animalnames{1},'_',varlist.expdate{1},'_', varlist.taskname{1} '.mat']),'varlist','eventlist')
    clear varlist eventlist
end
end