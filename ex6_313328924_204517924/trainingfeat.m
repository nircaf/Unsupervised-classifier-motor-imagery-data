function [accuracy,trainError,confusionMatrixSum,matrixFeatSelected,featindex] = trainingfeat(feat,Data,trialNumber,featDeduct)
%TRAINING Summary of this function goes here
%   Detailed explanation goes here
%% feature selection
Selection = fscnca(feat.matrix,Data.lables); % Feature selection using neighborhood component analysis for classification
weights = Selection.FeatureWeights;
[~ , featOrder] = sort(weights, 'descend');     %Sort in decending order
featRunNumber = feat.selectedFeat-featDeduct;
featindex = featOrder(1:featRunNumber+1); %Choosing the most importent features
matrixFeatSelected = feat.matrix(:,(featindex));
%% Train model with cross-validation
idxSegments = mod(randperm(trialNumber),featRunNumber)+1;   %randomly split trails in to trainingPar groups
confusionMatrixSum = zeros(size(struct2table(Data.indexes),2),size(struct2table(Data.indexes),2));                 % allocate space for confusion matrix
for i = 1:featRunNumber
    % each test on 1 group and train on the else
    validation = logical(idxSegments == i)';
    trainingSegment = logical(idxSegments ~= i)';
    [results{i},trainError{i}] =...
        classify(matrixFeatSelected(validation,:),matrixFeatSelected(trainingSegment,:),Data.lables(trainingSegment));
    accuracy(i) = sum(results{i} == Data.lables(validation));  %sum num of correct results
    accuracy(i) = accuracy(i)/length(results{i})*100;
    %build the confusion matrix
    confusionMatrix = confusionmat(Data.lables(validation),results{i});
    confusionMatrixSum = confusionMatrixSum + confusionMatrix;
end
end

