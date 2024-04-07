function dpath = Choosesavedir(whichdir)

% abfrage, welcher output: fig, variablen output nach createDatabase, variablen
% output nach classifier
if strcmp(whichdir,'figs')
    dpath = fullfile(userpath, 'results', 'figs');
    
elseif strcmp(whichdir,'outputvars')
   
        dpath = fullfile(userpath, 'results','mat');

elseif  strcmp(whichdir,'excel')
    dpath = fullfile(userpath,'results','excel');
end

end