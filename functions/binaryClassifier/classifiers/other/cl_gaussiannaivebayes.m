function [trainedClassifier] = cl_gaussiannaivebayes(trainingData, responseData)
% [trainedClassifier, validationAccuracy] = trainClassifier(trainingData,
% responseData)
% Returns a trained classifier and its accuracy. This code recreates the
% classification model trained in Classification Learner app. Use the
% generated code to automate training the same model with new data, or to
% learn how to programmatically train models.
%
%  Input:
%      trainingData: A matrix with the same number of columns and data type
%       as the matrix imported into the app.
%
%      responseData: A vector with the same data type as the vector
%       imported into the app. The length of responseData and the number of
%       rows of trainingData must be equal.
%
%  Output:
%      trainedClassifier: A struct containing the trained classifier. The
%       struct contains various fields with information about the trained
%       classifier.
%
%      trainedClassifier.predictFcn: A function to make predictions on new
%       data.
%
%      validationAccuracy: A double containing the accuracy as a
%       percentage. In the app, the Models pane displays this overall
%       accuracy score for each model.
%
% Use the code to train the model with new data. To retrain your
% classifier, call the function from the command line with your original
% data or new data as the input arguments trainingData and responseData.
%
% For example, to retrain a classifier trained with the original data set T
% and response Y, enter:
%   [trainedClassifier, validationAccuracy] = trainClassifier(T, Y)
%
% To make predictions with the returned 'trainedClassifier' on new data T2,
% use
%   yfit = trainedClassifier.predictFcn(T2)
%
% T2 must be a matrix containing only the predictor columns used for
% training. For details, enter:
%   trainedClassifier.HowToPredict

% Auto-generated by MATLAB on 10-Nov-2021 11:39:47


% Extract predictors and response
% This code processes the data into the right shape for training the
% model.

% Convert input to table
% for i = 1:size(trainingData,2)
%     predictorNames{1,i} = ['feature_',num2str(i)];
% end
predictorNames = trainingData.Properties.VariableNames;   
isCategoricalPredictor = false(1,size(predictorNames,2));
% inputTable = array2table(trainingData, 'VariableNames', predictorNames);
% predictors = inputTable(:, predictorNames);
response = responseData(:);

% Train a classifier
% This code specifies all the classifier options and trains the classifier.

% Expand the Distribution Names per predictor
% Numerical predictors are assigned either Gaussian or Kernel distribution and categorical predictors are assigned mvmn distribution
% Gaussian is replaced with Normal when passing to the fitcnb function
distributionNames =  repmat({'Normal'}, 1, length(isCategoricalPredictor));
distributionNames(isCategoricalPredictor) = {'mvmn'};

if any(strcmp(distributionNames,'Kernel'))
    classificationNaiveBayes = fitcnb(...
        trainingData, ...
        response, ...
        'Kernel', 'Normal', ...
        'Support', 'Unbounded', ...
        'DistributionNames', distributionNames, ...
        'ClassNames', [0; 1]);
else
    classificationNaiveBayes = fitcnb(...
        trainingData, ...
        response, ...
        'DistributionNames', distributionNames, ...
        'ClassNames', [0; 1]);
end
% trainedClassifier.limeModel = lime(classificationNaiveBayes,trainingData);


% Create the result struct with predict function
predictorExtractionFcn = @(x) array2table(x, 'VariableNames', predictorNames);
naiveBayesPredictFcn = @(x) predict(classificationNaiveBayes, x);
trainedClassifier.predictFcn = @(x) naiveBayesPredictFcn(predictorExtractionFcn(x));

% Add additional fields to the result struct
trainedClassifier.classModel = classificationNaiveBayes;
trainedClassifier.About = 'This struct is a trained model exported from Classification Learner R2021b.';
trainedClassifier.HowToPredict = sprintf('To make predictions on a new predictor column matrix, X, use: \n  yfit = c.predictFcn(X) \nreplacing ''c'' with the name of the variable that is this struct, e.g. ''trainedModel''. \n \nX must contain exactly 24 columns because this model was trained using 24 predictors. \nX must contain only predictor columns in exactly the same order and format as your training \ndata. Do not include the response column or any columns you did not import into the app. \n \nFor more information, see <a href="matlab:helpview(fullfile(docroot, ''stats'', ''stats.map''), ''appclassification_exportmodeltoworkspace'')">How to predict using an exported model</a>.');

% y_predict = trainedClassifier.predictFcn(x_test);
