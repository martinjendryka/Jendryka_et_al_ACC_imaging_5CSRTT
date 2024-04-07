% function [value1,TP,FP,TN,FN,accuracy,precision,sensitivity,specificity,f_score,...
%     mcc] = confusionmatStats(group,grouphat)
function [value1,accuracy,f_score,sensitivity,FPR] = confusionmatStats(group,grouphat)


% http://www.mathworks.com/matlabcentral/fileexchange/46035-confusion-matrix--accuracy--precision--specificity--sensitivity--recall--f-score
%
% INPUT
% group = true class labels
% grouphat = predicted class labels
%
% OR INPUT
% stats = confusionmatStats(group);
% group = confusion matrix from matlab function (confusionmat)
%
% OUTPUT
% stats is a structure array
% stats.confusionMat
%               Predicted Classes
%                    p'    n'
%              ___|_____|_____| 
%       Actual  p |     |     |
%      Classes  n |     |     |
%
% stats.accuracy = (TP + TN)/(TP + FP + FN + TN) ; the average accuracy is returned
% stats.precision = TP / (TP + FP)                  % for each class label
% stats.sensitivity = TP / (TP + FN)                % for each class label
% stats.specificity = TN / (FP + TN)                % for each class label
% stats.recall = sensitivity                        % for each class label
% stats.Fscore = 2*TP /(2*TP + FP + FN)            % for each class label
% stats.mcc = TP*TN-FP*FN/sqrt((TP+FP)*(TP+FN)*(TN+FP)*(TN+FN)) % for each class label
% TP: true positive, TN: true negative, 
% FP: false positive, FN: false negative

field1 = 'confusionMat';
if nargin < 2
    value1 = group;
else
    value1 = confusionmat(group,grouphat);
end

numOfClasses = size(value1,1);
totalSamples = sum(sum(value1));
    
accuracy = trace(value1)/totalSamples; 

[TP,TN,FP,FN,sensitivity,specificity,FPR,precision,f_score,mcc] = deal(zeros(numOfClasses,1));
for class = 1:numOfClasses
   TP(class) = value1(class,class);
   tempMat = value1;
   tempMat(:,class) = []; % remove column
   tempMat(class,:) = []; % remove row
   TN(class) = sum(sum(tempMat));
   FP(class) = sum(value1(:,class))-TP(class);
   FN(class) = sum(value1(class,:))-TP(class);
end

for class = 1:numOfClasses
    sensitivity(class) = TP(class) / (TP(class) + FN(class)); % true positive rate (required for ROC curve)
    specificity(class) = TN(class) / (FP(class) + TN(class));
    FPR(class) = 1 -specificity(class); % false positive rate (required for ROC curve)
    precision(class) = TP(class) / (TP(class) + FP(class));
    f_score(class) = 2*(precision(class)*sensitivity(class))/...
        (precision(class)+sensitivity(class));
    mcc(class) = (TP(class)*TN(class)-FP(class)*FN(class))/...
        sqrt((TP(class)+FP(class))*(TP(class)+FN(class))*(TN(class)+FP(class))*...
        (TN(class)+FN(class)));
end

% field2 = 'accuracy';   value2 = accuracy;
% field3 = 'TP'; value3 = TP;
% field4 = 'TN'; value4 = TN;
% field5 = 'FP'; value5 = FP;
% field6 = 'FN'; value6 = FN;
% field7 = 'recall';  value7 = sensitivity;
% field8 = 'specificity';  value8 = specificity;
% field9 = 'precision';  value9 = precision;
% field10 = 'Fscore';  value10 = f_score;
% field11 = 'MCC';  value11 = mcc;

% stats1 = struct(field1,value1,field3,value3,field4,value4,field5,value5,...
%     field6,value6);
% stats2 = struct(field2,value2,field7,value7,field8,value8,field9,value9,...
%     field10,value10,field11,value11);
end