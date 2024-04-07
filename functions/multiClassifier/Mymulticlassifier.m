% dataset is partitioned into training and test sets, classfier is a linear
% svm
function  [pdecodAll, fscoreAll,betaAll,fprAll,tprAll,aucAll] = Mymulticlassifier(set,setlabel,Params,info,thisses,numeventtypes,doshuffle)

ncells = info.ncells(thisses);
animal = info.animals{thisses};
%% options for linear SVM classifier
t_linear = templateSVM('KernelFunction','linear',...
    'BoxConstraint',1,...
    'KernelScale','auto',...
    'Standardize','off');

%% pre-set output variables
pdecodAll = cell(1,numel(Params.epochtypes));
fscoreAll = cell(1,numel(Params.epochtypes));
fprAll = cell(1,numel(Params.epochtypes));
tprAll = cell(1,numel(Params.epochtypes));
aucAll= cell(1,numel(Params.epochtypes));
betaAll = cell(1,numel(Params.epochtypes));

k = Params.smoteNeighbors; % number of neighbors for used in SMOTE, BE AWARE that in smote function k = k+1
poketypes = {'poke_1','poke_2','poke_3','poke_4','poke_5'};

for thisepochtype = 1:numel(Params.epochtypes)
    numframes = Params.frames.num(thisepochtype);

    y = setlabel;

    if thisepochtype == 2 % in the cue epoch, rmv premature trials (dataset for cue epoch does not include prematures)
        prematuresInd = sum(numeventtypes(1:3))+1:numel(y); % get ind for prematures
        y(prematuresInd) = [];
    end

    % remove omissions
    omissionInd = find(isundefined(y));
    y(omissionInd) = [];

    [numevents,classlbls] = groupcounts(y);
    nclasses = numel(numevents);
    sizetest = floor(Params.ratio*numel(y));

    if rem(sizetest,nclasses) % checks if sizetest is devidable by the number of classes (we want an equal distributed testgroup), if not subtract by the remainder (therefore <20%)
        %         sizetest = sizetest + (nclasses - rem(sizetest,nclasses));
        sizetest = sizetest - rem(sizetest,nclasses);
    end

    sizetest_class = sizetest/nclasses; % that is the event number for each class in the test set

    %%% check if there are enough events for each class to fill test set
    if any(numevents<=sizetest_class+1) % there needs to be at least 2 events left in the training set
        fprintf('not enough events for test set in session %s \n',info.animals{1})
        continue
    end
    
    
    if any(numevents-sizetest_class<=2) 
    continue
    end


    eventind = 1:numel(y);

    % pre-allocate output variables
    pdecod = nan(numframes,Params.MLiterations);
    fscore = nan(nclasses,numframes,Params.MLiterations);

    fpr = nan(nclasses,sizetest+1,numframes,Params.MLiterations);
    tpr = nan(nclasses,sizetest+1,numframes,Params.MLiterations);
    auc = nan(nclasses,numframes,Params.MLiterations);
    beta = nan(nclasses,ncells,numframes,Params.MLiterations);

    for thistimebin = 1:numframes
        thisset = set{thisepochtype,thistimebin};
        nanrows =  find(all(isnan(thisset),2));         % remove any rows with all nans (from not occuring trialtypes)
        thisset(nanrows,:) = [];

        thisset(omissionInd,:) = [];

        for i = 1:Params.MLiterations
            % =========================================================================
            %%  Partition by train/test split
            % =========================================================================

            %%% test set
            picktest = [];
            for thisclass = classlbls'
                indclass = find(ismember(y,thisclass));

                pick = indclass(sort(randperm(numel(indclass),sizetest_class)));
                picktest = [picktest; pick];
            end

            ytest = cellstr(y(picktest));
            xtest = thisset(picktest,:);

            %%% train set
            picktrain = eventind(~(ismember(eventind,picktest)))'; % select all these events that are not in the test set
            xtrain = thisset(picktrain,:);
            ytrain = cellstr(y(picktrain));

            if Params.dosmote
                %%% preparation for SMOTE upsampling of trainingset
                % do upsampling if for any class there are less events than neigbors
                xtrain_upsampled = xtrain;
                ytrain_upsampled = ytrain;

                [nC,~] = groupcounts(ytrain); % number of events for each class in this fold
                thisupsample = find(nC<=k);

                if ~isempty(thisupsample)
                    for e = thisupsample'

                        idx_upsample = ismember(ytrain_upsampled,classlbls(e)); % get indices of events of this class
                        thisx = xtrain_upsampled(idx_upsample,:);

                        samplefactor = floor((k+1) / nC(e));

                        [~,~,x_upsampled,~] = smote(thisx, samplefactor, nC(e)-1); 
                        xtrain_upsampled = [xtrain_upsampled;x_upsampled];
                        ytrain_upsampled = [ytrain_upsampled;repelem(classlbls(e),size(x_upsampled,1),1)];
                    end
                end

                %%% check if multiplication factor M is larger than k for any
                %%% eventtypes
                [nC,~] = groupcounts(ytrain_upsampled); % number of events for each class in this fold

                [~,minorclass] = min(nC);
                [~,majorclass] = max(nC);
                otherclasses = setdiff(1:nclasses,majorclass);
                Mall = nC(majorclass)./nC(otherclasses)-1;  % multiplication factor to even events of major and minor class
                thisupsample = otherclasses(Mall>k); % eventtypes for which upsampling will be done


                for r = thisupsample % do upsampling iteratively for each eventtype with M too high
                    M = nC(majorclass)./nC(r)-1;  % multiplication factor to even events of major and minor class

                    while M > k                 %%% upsample minor class until M is small enough

                        %% first try decrease M by upsampling minor class
                        idx_minorclass = ismember(ytrain_upsampled,classlbls(r)); % get indices of events of this class
                        x_minorclass = xtrain_upsampled(idx_minorclass,:);

                        % decide upsamling factor
                        if nC(r) < M % if minorclass smaller than M
                            samplefactor = nC(r);
                        else
                            samplefactor = floor(M);
                        end

                        nminor = numel(find(idx_minorclass));
                        newn = nminor * samplefactor + nminor;
                        if newn > nC(majorclass) % the sample factor must not create more events in minor class than in major class
                            samplefactor = floor((nC(majorclass) - nminor)/nminor);
                        end
                        [~,~,x_upsampled,~] = smote(x_minorclass, samplefactor, samplefactor); % probably in some instances will create more than major class, so make sure its not higher using multiplication factor M

                        xtrain_upsampled = [xtrain_upsampled;x_upsampled];
                        ytrain_upsampled = [ytrain_upsampled;repelem(classlbls(r),size(x_upsampled,1),1)];
                        nC = groupcounts(ytrain_upsampled);
                        M = nC(majorclass)/nC(r)-1;

                        if nC(r) > nC(majorclass)
                            error('minorclass has more events than majorclass after upsampling')
                        end
                    end
                end


                % SMOTE upsampling of training set to balance training set
                [ytrain_upsampled, thisidx] = sort(ytrain_upsampled);
                xtrain_upsampled = xtrain_upsampled(thisidx,:);
                [xtrain_smote,ytrain_smote,~,~] = smote(xtrain_upsampled,[],k,'Class',string(ytrain_upsampled));
                xtrain = xtrain_smote;
                ytrain = cellstr(ytrain_smote);
            end

            if doshuffle % random permutation of labels
                ytrain = ytrain(randperm(length(ytrain)));
            end

            %% training of multiclassifier
            svmmod = fitcecoc(xtrain,ytrain,...
                'Learners', t_linear, ...
                'ClassNames',unique(ytrain),...
                'Coding','onevsall');

            % =========================================================================
            %% prediction
            % =========================================================================
            [ypredict,~,pbscore] = predict(svmmod,xtest);
            [~,thisaccuracy,thisfscore] = confusionmatStats(ytest,ypredict); % also other measures available, eg. F-Score etc
            pdecod(thistimebin,i) = thisaccuracy;
            fscore(1:nclasses,thistimebin,i) = thisfscore;

            %%% get metrics for ROC curves and beta value for each
            %%% binary classifier
            fprClasses = nan(nclasses,numel(ytest)+1);
            tprClasses = nan(nclasses,numel(ytest)+1);
            thisauc = nan(nclasses,1);
            thisbeta = nan(nclasses,ncells);

            for thisclass = 1:nclasses  % iterate through classes
                realclass = ismember(poketypes,svmmod.ClassNames(thisclass)); % this is important to have the right order, when eventtypes are excluded
                betaval = svmmod.BinaryLearners{thisclass}.Beta;
                thisbeta(realclass,:) = betaval;

                if any(ismember(ypredict,poketypes(thisclass))) && ~all(ismember(ypredict,poketypes(thisclass))) &&...% if positive class is not predicted than roc curve can not be made for this instance
                        ~any(isnan(pbscore(:,thisclass))) % pbscore mustnt have nans
                    [thisfpr,thistpr,~,thisaucval] = perfcurve(ypredict,pbscore(:,thisclass),poketypes(thisclass));

                else
                    continue
                end
                if ~isequal(length(thisfpr),numel(ytest)+1)  % perfcurve output should have length Y_test+1, check if this is true
                    disp(['wrong size of roc fpr and tpr in session',...
                        num2str(thisses),'iteration',num2str(i)])
                    d = length(ytest)+1 - length(thisfpr);
                    thisfpr = [thisfpr;repmat(thisfpr(end),d,1)]; % the last values (normally 1) are repeated
                    thistpr =  [thistpr;repmat(thistpr(end),d,1)];
                    disp([num2str(d),'values added'])
                end
                thisauc(realclass,1) = thisaucval;
                fprClasses(realclass,:)= thisfpr';
                tprClasses(realclass,:) = thistpr';
            end

            fpr(:,:,thistimebin,i) = fprClasses;
            tpr(:,:,thistimebin,i) = tprClasses;

            auc(:,thistimebin,i) = thisauc;
            beta(:,:,thistimebin,i) = thisbeta;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
        if doshuffle
            curr_i_string = [' Classifying Permutation Session ' animal ' ' char(Params.epochtypes(thisepochtype)) ' for timebin ' num2str(thistimebin)  ' : ' num2str(Params.MLiterations) ' iterations'];
            fprintf('%s \n', curr_i_string)

        else
            curr_i_string = [' Classifying Session ' animal ' ' char(Params.epochtypes(thisepochtype)) ' for timebin ' num2str(thistimebin)  ' : ' num2str(Params.MLiterations) ' iterations'];
            fprintf('%s \n', curr_i_string)
        end
    end
    pdecodAll{thisepochtype} = pdecod;
    fscoreAll{thisepochtype} = fscore;
    aucAll{thisepochtype} = auc;
    fprAll{thisepochtype} = fpr;
    tprAll{thisepochtype} = tpr;
    betaAll{thisepochtype} = beta;
end
end