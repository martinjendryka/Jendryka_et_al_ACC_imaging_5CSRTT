% binary classification of event combinations (eg. OM and CR) for each
% timebin  of the event trace and each epoch using neural cells as predictors, minor class
% is upsampled using SMOTE, SVM classifier
%%
function  [pdecodAll, fscoreAll,betaAll,fprAll,tprAll,aucAll] = ...
    Mybinaryclassifier(set,setlabel,Params,info,thisses,epochtype,doshuffle)

ncells = info.ncells(thisses);
animal = info.animals{thisses};

%% pre-set output variables
pdecodAll = cell(numel(Params.epochtypes),size(Params.trialcombs,1));
fscoreAll = cell(numel(Params.epochtypes),size(Params.trialcombs,1));
fprAll = cell(numel(Params.epochtypes),size(Params.trialcombs,1));
tprAll = cell(numel(Params.epochtypes),size(Params.trialcombs,1));Params.trialtypes
aucAll= cell(numel(Params.epochtypes),size(Params.trialcombs,1));
betaAll = cell(numel(Params.epochtypes),size(Params.trialcombs,1));

k = Params.smoteNeighbors; % number of neighbors for used in SMOTE

for thisepochtype = epochtype 
    numframes = Params.frames.num(thisepochtype);

    for thisbinaryclassifier = 1: size(Params.trialcombs,1)
        if ismember(thisepochtype,2) && any(ismember(thisbinaryclassifier,[3,5,6])) % combs with prematures in cue phase
            continue
        end
        classlbls = Params.trialtypes(Params.trialcombs(thisbinaryclassifier,:));
        onlyclasslbls = ismember(setlabel,classlbls);
        y = setlabel(onlyclasslbls);

        if ~isequal(numel(unique(y)),2) % if there are no two classes
            continue
        end

        eventind = 1:numel(y);

        % number of events of minor class
        numevents = groupcounts(y);
        [~,minorclassid] = min(numevents);
        majorclassid = find([1,2] ~= minorclassid);

        sizetest = floor(Params.ratio*sum(numevents));
        sizetest_class = round(sizetest/2);
        yminor = find(ismember(y,classlbls(minorclassid)));
        ymajor = find(ismember(y,classlbls(majorclassid)));

        %%% check if animal has minimum of required events per class, if
        %%% not, skip
        if numel(ymajor)<Params.mineventsClass || numel(yminor)<Params.mineventsClass
            sprintf('not enough %s events ( %d ) for test set for animal %s',char(Params.trialtypes(minorclassid)),numevents(minorclassid),animal)
            continue
        end

        %%% check if there are enough obs for each event to fill test set
        if numel(ymajor)<sizetest_class+2 || numel(yminor)<sizetest_class+2 % +2 since there needs to be at least 2 events left for the training set
            new_sizetestclass = numel(yminor) - 2;
            n_newYmajor = (2* new_sizetestclass / Params.ratio) - numel(yminor);
            % rmv labels from major class to decrease test size
            rmvevents = sort(ymajor(randperm(numel(ymajor),numel(ymajor) - n_newYmajor))); % randomly choose events for test set
            newYmajor = ymajor(~(ismember(ymajor,rmvevents)));
            ymajor = newYmajor;
            eventind = sort([yminor;ymajor]);
            sizetest = floor(Params.ratio*(numel(yminor)+numel(ymajor)));
            sizetest_class = floor(sizetest/2);
        end

        % iterate through each timebin
        pdecod = [];
        fscore = zeros(2,numframes,Params.MLiterations);
        beta =[];
        fpr = [];
        tpr = [];
        auc = [];


        for thistimebin = 1:numframes % start for-loop through timebins
            thisset = set{thisepochtype,thistimebin}(onlyclasslbls,:);

            for i = 1:Params.MLiterations % start for-loop through classification iterations
                %%% test set
                picktestminor = sort(yminor(randperm(numel(yminor),sizetest_class))); % randomly choose events for test set
                picktestmajor = sort(ymajor(randperm(numel(ymajor),sizetest_class)));
                picktest = sort([picktestminor;picktestmajor]);
                xtest = thisset(picktest,:);
                ytest = cellstr(y(picktest));

                % train set
                picktrain = eventind(~(ismember(eventind,picktest)))'; % select all these events that are not in the test set
                xtrain = thisset(picktrain,:);
                ytrain = cellstr(y(picktrain));

                %%% preparation for SMOTE upsampling of trainingset
                nC = groupcounts(ytrain); % number of events for each class in this fold
                [minevents,minorclass] = min(nC);
                majorclass = find([1,2] ~= minorclass);

                M = nC(majorclass)/nC(minorclass)-1;  % multiplication factor to even events of major and minor class

                ytrain_upsampled = ytrain;
                xtrain_upsampled = xtrain;

                %%% SMOTE DOES WORK WHEN k is smaller
                %%% than the event number of the minorclass OR the size
                %%% of x is greater than k

                while M > k   || nC(minorclass) <= k             %%% upsample minor class until M is small enough

                    %% first try decrease M by upsampling minor class
                    idx_minorclass = ismember(ytrain_upsampled,classlbls(minorclass)); % get indices of events of this class
                    x_minorclass = xtrain_upsampled(idx_minorclass,:);

                    % decide upsamling factor
                    if nC(minorclass) < M % if minorclass smaller than M
                        samplefactor = nC(minorclass)-1;
                    elseif M < 1
                        samplefactor= 1;
                    else
                        samplefactor = floor(M);
                    end

                    nminor = numel(find(idx_minorclass));
                    newn = nminor * samplefactor + nminor;
                    if newn > nC(majorclass) && ~(isequal(samplefactor,1))  % the sample factor must not create more events in minor class than in major class
                        samplefactor = floor((nC(majorclass) - nminor)/nminor);
                    end

                    if isequal(samplefactor,size(x_minorclass,1)) && ~(isequal(samplefactor,1))
                        samplefactor = samplefactor -1;
                    end

                    [~,~,x_upsampled,~] = smote(x_minorclass, samplefactor, samplefactor); % probably in some instances will create more than major class, so make sure its not higher using multiplication factor M

                    xtrain_upsampled = [xtrain_upsampled;x_upsampled];
                    ytrain_upsampled = [ytrain_upsampled;repelem(classlbls(minorclass),size(x_upsampled,1),1)];
                    nC = groupcounts(ytrain_upsampled);
                    M = nC(majorclass)/nC(minorclass)-1;
                    minevents = nC(minorclass);
                end

                % SMOTE upsampling of training set to balance training set
                % k must not be higher than the events of the minor
                % class
                [xtrain_smote,ytrain_smote,~,~] = smote(xtrain_upsampled,[],k,'Class',string(ytrain_upsampled));
                xtrain = xtrain_smote;
                ytrain = cellstr(ytrain_smote);


                if doshuffle % random permutation of labels in SMOTE training set
                    ytrain = ytrain(randperm(length(ytrain)));
                end

                % =========================================================================
                %% classifier training
                % =========================================================================

                %%% change with myclassifiers to use other classifiers
                trainedModel = cl_linearSVM(array2table(xtrain), ytrain);

                % =========================================================================
                %% prediction
                % =========================================================================

                [ypredict,~,pbscore] = trainedModel.predictFcn(xtest);
                [~,thisaccuracy,thisfscore] = confusionmatStats(ytest,ypredict); % also other measures available, eg. F-Score etc

                pdecod(thistimebin,i) = thisaccuracy;
                fscore(:,thistimebin,i) = thisfscore;
                beta(:,thistimebin,i) = trainedModel.classModel.Beta;
                fprClasses = nan(numel(classlbls),numel(ytest)+1);
                tprClasses = nan(numel(classlbls),numel(ytest)+1);
                thisauc = nan(numel(classlbls),1);
                for thisclass = 1:numel(classlbls)

                    if numel(unique(ypredict)) == 2 % check if there are predicted events for this class, if not roc curve cannot be plotted
                        [thisfpr,thistpr,~,thisaucval] = perfcurve(ypredict,pbscore(:,thisclass),classlbls(thisclass));
                    else
                        continue
                    end

                    if ~isequal(length(thisfpr),numel(ytest)+1)  % perfcurve output should have length Y_test+1, check if this is true
                        d = length(ytest)+1 - length(thisfpr);
                        thisfpr = [thisfpr;repmat(thisfpr(end),d,1)]; % the last values (normally 1) are repeated
                        thistpr =  [thistpr;repmat(thistpr(end),d,1)];
                    end
                    thisauc(thisclass,1) = thisaucval;
                    fprClasses(thisclass,:)= thisfpr';
                    tprClasses(thisclass,:) = thistpr';
                end
                fpr(:,:,thistimebin,i) = fprClasses;
                tpr(:,:,thistimebin,i) = tprClasses;
                auc(:,thistimebin,i) = thisauc;
            end
            if doshuffle
                curr_i_string = [' Classifying Permutation Session ' animal ' ' char(Params.epochtypes(thisepochtype)) ' ' classlbls{1} '-' classlbls{2} ' for timebin ' num2str(thistimebin) ' : ' num2str(Params.MLiterations) ' iterations' ];
                fprintf([curr_i_string '\n']);

            else
                curr_i_string = [' Classifying Session ' animal ' ' char(Params.epochtypes(thisepochtype)) ' ' classlbls{1} '-' classlbls{2} ' for timebin ' num2str(thistimebin)  ' : ' num2str(Params.MLiterations) ' iterations'];
                fprintf([curr_i_string '\n']);
            end
        end

        pdecodAll{thisepochtype,thisbinaryclassifier} = pdecod;
        fscoreAll{thisepochtype,thisbinaryclassifier} = fscore;
        betaAll{thisepochtype,thisbinaryclassifier} = beta;
        aucAll{thisepochtype,thisbinaryclassifier} = auc;
        fprAll{thisepochtype,thisbinaryclassifier} = fpr;
        tprAll{thisepochtype,thisbinaryclassifier} = tpr;
    end
end
end