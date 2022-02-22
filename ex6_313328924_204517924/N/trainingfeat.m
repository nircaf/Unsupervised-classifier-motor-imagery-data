function [accuracy,trainError,confusionMatrixSum,matrixFeatSelected,featindex] =...
    trainingfeat(feat,Data,trialNumber,featDeduct)
% "trainingfeat" function chooses the best features for a uccessful prediction
% and finds the percentage of success and train error in learning a given
% feature matrix

%input:
% "feat" is a struct which contains features
% "Data" is a struct which contains data on which this process is performed
% "trialNumber" is the number of trials preformed
% "featDeduct" is the number of selected features

%% feature selection
%this section recives features matrix and a lable and chooses the
%best features
Selection = fscnca(feat.matrix,Data.lables); %Feature selection using neighborhood
% component analysis for classification
weights = Selection.FeatureWeights;
[~ , featOrder] = sort(weights, 'descend');  %Sort in decending order
featindex = featOrder(1:feat.selectedFeat-featDeduct+1); %Choose most importent features
%featindex is the index of the selected best features.
matrixFeatSelected = feat.matrix(:,(featindex));
%matrixFeatSelected is the selected matrix of weigth

%% Train model with cross-validation

idxSegments = mod(randperm(trialNumber),feat.selectedFeat)+1;   ...
    %split trails randomly to n=trainingPar groups
confusionMatrixSum = zeros(size(struct2table(Data.indexes),2)...
    ,size(struct2table(Data.indexes),2));  %creat primary confusion matrix

%perform this process on choosen "train" group and test it on "test" group
for i = 1:feat.selectedFeat %loop over selected features
    validation = logical(idxSegments == i)';
    trainingSegment = logical(idxSegments ~= i)';
    [results{i},trainError{i}] =classify(matrixFeatSelected(validation,:)...
        ,matrixFeatSelected(trainingSegment,:),Data.lables(trainingSegment));
    accuracy(i) = sum(results{i} == Data.lables(validation));  %sum the number of correct results
    accuracy(i) = accuracy(i)/length(results{i})*100;
    
    
    %put recived data in the confusion matrix
    confusionMatrix = confusionmat(Data.lables(validation),results{i});
    confusionMatrixSum = confusionMatrixSum + confusionMatrix;
end


end

