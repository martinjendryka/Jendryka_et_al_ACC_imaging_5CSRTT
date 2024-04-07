function cpdAll = LinearRegress(x,yAll,Params,numcells,labels)

cpdAll = cell(1,numel(Params.epochtypes));
numpred = numel(Params.predstrs);
xOR = x;

for thisepochtype = 1:numel(Params.epochtypes)
    y = yAll{thisepochtype};
    x = xOR;
    if thisepochtype == 2 % no prematures in cue epoch
        x(ismember(labels,{'premature'}),:) = [];
    end
    numframes = Params.frames.num(thisepochtype);

    cpd = zeros(numpred,numcells,numframes);
    for thistimebin= 1:numframes
        for thiscell = 1:numcells

            thisy = y(:,thiscell,thistimebin);

            [B,mdl] = lasso(x,thisy,'Intercept',true,'CV',10);
            MSE_full= mdl.MSE(mdl.IndexMinMSE); % get MSE for optimal Lambda

            for thispred = 1:numpred
                x_i= x;

                if isequal(thispred,2)
                    x_i(:,2:5) = [];
                elseif ismember(thispred,3:5)
                    continue
                else
                    x_i(:,thispred) = []; % remove single predictor to calculate reduced model
                end

                [~,mdlRed] = lasso(x_i,thisy,'Intercept',true,'CV',10);
                MSE_red= mdlRed.MSE(mdlRed.IndexMinMSE);
                cpd(thispred,thiscell,thistimebin) = (MSE_red - MSE_full)/MSE_red;
            end
        end
    end
    cpdAll{thisepochtype} = cpd;
end
end