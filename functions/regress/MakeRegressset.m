function [X,y,Params,labels] = MakeRegressset(Params,eventepochs,numevents,pokes)
% Predictor Matrix
%trial		        active_poke	which_poke_3	which_poke_2	which_poke_3	which_poke_4	reward
%poke1_correct		1	        1	            0	            1	            -0.25	        1
%poke2_incorrect	1	        1	            0	            -1	            -0.25	        -1
%poke3_premature	1	        0	            0	            0	                1	        -1
%poke4_correct		1	        -1	            1	            0	            -0.25	        1
%poke5_premature	1	        -1	            -1	            0	            -0.25	        -1
%omission		    -1	        0	            0	            0	                0	        -1

Params.predstrs = {'activePoke/omission','spatialLocation1','spatialLocation2','spatialLocation3','spatialLocation4','rewarded(correct)Response'};

numpred = numel(Params.predstrs);
y = {};
labels = repelem(Params.trialtypes',numevents);
emptycell = cell2mat(cellfun(@(x) isempty(x),pokes,'UniformOutput',false));
labelsPoke = cat(1,pokes{~((emptycell))});
for thisepochtype = 1:numel(Params.epochtypes)
    epochsall = [];

    for thistrialtype = 1:numel(Params.trialtypes)

        if isequal(numevents(thistrialtype),0) || thisepochtype==2 && thistrialtype==4
            continue
        else

            thisepoch = permute(eventepochs{thistrialtype,thisepochtype},[3,1,2]); % trials X ncells X timepoints
            epochsall = cat(1,epochsall,thisepoch);

            y{thisepochtype} = epochsall;
        end
    end
end

X = ones(numel(labels),numpred);

%%% active response predictor
X(ismember(labels,{'omission'}),1) = -1; % active responses

% %%% PokeIdentity1 predictor (left-right directionality)
X(ismember(labelsPoke,{'poke_4','poke_5'}),2) = -1;
X(ismember(labelsPoke,{'poke_3'}),2) = 0;
%
% % %%% PokeIdentity2 predictor (poke discrimination right)
X(ismember(labelsPoke,{'poke_1','poke_2','poke_3'}),3) = 0;
X(ismember(labelsPoke,{'poke_5'}),3) = -1;
%
% % %%% PokeIdentity3 predictor (poke discrimination left)
X(ismember(labelsPoke,{'poke_3','poke_4','poke_5'}),4) = 0;
X(ismember(labelsPoke,{'poke_2'}),4) = -1;
%
% % %%%  PokeIdentitiy4 predictor (poke discrimination middle)
X(ismember(labelsPoke,{'poke_1','poke_2','poke_4','poke_5'}),5) = -0.25;

% %%% pokeIdentity predictors for omissions
X(ismember(labels,{'omission'}),[2:5]) = 0; %

%%% reward predictor
X(~ismember(labels,{'correct'}),6) = -1;
end