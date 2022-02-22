%MATLAB 2019a
%this code loads an EEG structure extarcts feature out of the data and trains an LDA model
%to predict between two classes
clear all; close all;

%% expariment param
load('motor_imagery_train_data.mat');       % trainig data
testFileName = 'motor_imagery_test_data.mat'; % test data
fs = P_C_S.samplingfrequency;               %sampling frequency, Hz
nTrials = size(P_C_S.data,1);               % num of trails
trialLen = size(P_C_S.data,2);              % num of sample
timeVec = 1/fs:1/fs:trialLen/fs;                %create time vec according to parameters
f = 0.5:0.1:40;                             % relevant freq range
window = 1.2;                               %window length in secs                         
windOverlap = 1;                          %window overlap length in secs
numOfWindows = floor((size(P_C_S.data,2)-window*fs)/...
    (window*fs-floor(windOverlap*fs)))+1;   %number of windows
miStart = 2.25;                             %motor imagery start in sec
miPeriod = timeVec(timeVec >= miStart);     %motor imagery period
edgePrct = 90;                              %spectral edge percentaile
null = 0;                                   %in case of no input needed
chans = cell2mat(P_C_S.channelname(1:2));   %channels in use
chans = str2num(chans);
chansName = ["C3" "C4"];                    %channels names should corresponds to chans 
nchans = length(chans);                     % num of channels
classes = P_C_S.attributename(3:end);       %extract classes assuming rows 1,2 are artifact and remove 
nclass = length(classes);                                 %this project support two classes only
classes = string(classes);

ntrialsPerClass = [sum(P_C_S.attribute(3,:)==1),...
    sum(P_C_S.attribute(4,:)==1)]; % Third and fouth rows contain left and right

% creating struct for all relevant parameters
technicalPar = struct('fs',fs,'time',timeVec,'freq',f,'nTrials',nTrials,'winLen',floor(window*fs),...
    'winOvlp',floor(windOverlap*fs),'miPeriod',miPeriod,'nclass',nclass,'classes',classes, ...
    'clasRow',cell2mat({3, 4}'),'ntrialsPerClass',ntrialsPerClass,...
    'chans',chans,'chansName',chansName,'nchans',nchans,'edgePrct',edgePrct);


% isTrainMode = 0; % if set to 1 than the script will ran a loop in order to 
%check the best num of features to select using analyzeNumOfFeat function
%when is set to 0 a normal run will occur

%% Data
% creating struct for all relevant data and arrange it 
Data.allData = P_C_S.data;
Data.combLables = cell(1,nchans*nclass);        %lables for channels*class combinations
Data.lables = strings(nTrials,1);               %lable each trail for his class
k = 1;
for i = 1:nclass
    currClass = classes(i);
    Data.indexes.(classes{i}) = find(P_C_S.attribute(technicalPar.clasRow(i),:)==1);   %finding the indexes for each class
    Data.lables(Data.indexes.(classes{i})) = currClass;                         %lable each trail for his class
    for j = 1:nchans
        chanCls = char(currClass + chansName(j));                               %creating combination name
        Data.(chanCls) = Data.allData(Data.indexes.(classes{i}),:,chans(j));    %arrange data by combination
        Data.combLables{1,k} = chanCls;
        k = k+1;
    end
end

%% features

%band power features 1st arr - band, 2nd arr - time range
Features.bandPower{1} = {[12,17],[3.5,6]}; % Low Beta
Features.bandPowerName{1} = "Low Beta";
Features.bandPower{2} = {[30,34],[4,6]}; % Gamma
Features.bandPowerName{2} = "Gamma";
Features.bandPower{3} = {[8,12],[5.5,6]}; % Alpha
Features.bandPowerName{3} = "Alpha";
Features.bandPower{4} = {[18,23],[1.2,2.7]}; % High Beta
Features.bandPowerName{4} = "High Beta";

nBandPowerFeat = length(Features.bandPower)*2;  %bandpower and relative bandpower for each relevant range

Features.mVthrshld = 4;                         %threshold feature in muV

Features.diffBetween = ["C3","C4"];             % choose two elctrode to calc diff

generalFeat = 8;                               %number of general features should be 10!
%Total Power,Root Total Power,Slope,Intercept,Spectral Moment,Spectral Entropy
%Spectral Edge,Threshold Pass Count,Max Voltage,Min Voltage 

nDifFeat = 1;                   %number of diffs between chanle features should be 1!
Features.nFeat = ((nBandPowerFeat+generalFeat)*nclass)+ nDifFeat; %num of total features feature selection method

Features.nFeatSelect = 8 ;      %number of features to select for classification
Features.distPrecision = 5;     %only in case you run ks for feature selection           

%% Model training
k = 5;                          %k fold parameter
results = cell(k,1);    
trainErr = cell(k,1);
acc = zeros(k,1);

%% visualization
globalPos = [0.2,0.15,0.6,0.7]; %global position for figures
globTtlPos = [0.45,0.999];      %global title position
%first visualization
signalPerFig = 20;              %signals per figuer 
plotPerRow = 4;                 %plots per row 
plotPerCol = signalPerFig/plotPerRow; %make sure signalPerFig divisible with plotPerRow
%histogram
xLim = [-4 4];                  %x axis lims in sd 
binWid = 0.2;
trnsp = 0.5;                    %bars transparency
binEdges = xLim(1):binWid:xLim(2);

technicalPar.Vis = struct('globalPos', globalPos,'globTtlPos',globTtlPos,...
    'signalPerFig',signalPerFig,'plotPerRow',plotPerRow,'plotPerCol',plotPerCol,...
    'xLim',xLim,'binEdges',binEdges,'trnsp',trnsp);

%% ************************* Start of Project ***************************

%% data visualization
%visualization of the signal in Voltage[muV] for rand co-responding trails 
      plots('dataviz',Data,technicalPar)
% calculating PWelch for all condition
for i = 1:nclass
    for j = 1:length(technicalPar.chans)
        currClass = technicalPar.classes(i);
        chanCls = char(currClass + chansName(j));
        Data.PWelch.(chanCls) = pwelch(Data.(chanCls)(:,(technicalPar.miPeriod*fs))',...
            technicalPar.winLen,technicalPar.winOvlp,technicalPar.freq,technicalPar.fs);
    end
end

%visualization PWelch
plots('Pwelch',Data,technicalPar)

%calculating spectrogram for all conditions

for i =1:length(Data.combLables)    %looping all condition
   
   for j = 1:size(Data.(Data.combLables{i}),1)
      Data.spect.(Data.combLables{i})(j,:,:) = spectrogram(Data.(Data.combLables{i})(j,:)',...
          technicalPar.winLen,technicalPar.winOvlp,technicalPar.freq,technicalPar.fs,'yaxis');
   end
% convert the units to dB and average all spect for each cindition
    Data.spect.(Data.combLables{i}) = squeeze(mean(10*log10(abs(Data.spect.(Data.combLables{i}))).^2));
end

%visualization spectogram
plots('Spectogram',Data,technicalPar)
plots('SpectDiff',Data,technicalPar)  
 

%% extracting features
Features.featMat = zeros(nTrials,Features.nFeat);       %allocate space
Features.featLables = cell(1,Features.nFeat);           %allocate space to features name
Features = extractFeatures(Data.allData,technicalPar,Features,'featMat');   %calc and extract all features
[Features.featMat,meanTrain,SdTrain] = zscore(Features.featMat);            % scale all features

%% histogram
plots('FeaturesHist',Data,technicalPar,Features);

%% feature selection
% if isTrainMode == 1     %if true than check best num of features by loop through all features
%     numOfIter = Features.nFeat;
%     f1 = zeros(numOfIter,1);
%     accAvg = zeros(numOfIter,1);
%     trAccAvg = zeros(numOfIter,1);
%     accSD = zeros(numOfIter,1);
%     trAccSD = zeros(numOfIter,1);
% else
%     numOfIter = 1;      %if false than train model once with nFeatSelect features
% end 

% for iter = 1:numOfIter  %in case that train mode is on this loop will finde the best num of features
    %select only the nFeatSelect best features
%     if isTrainMode == 1 
%         Features.nFeatSelect = iter;
%     end
%     [featIdx,selectMat,featOrder] = selectFeat(Features,Data.lables); 
        Selection = fscnca(Features.featMat,Data.lables); % Feature selection using neighborhood component analysis for classification
        weights = Selection.FeatureWeights;
            %Decsending order of importence
    [~ , featOrder] = sort(weights, 'descend');
    %Taking the most importent features
    featIdx = featOrder(1:Features.nFeatSelect);
    selectMat = Features.featMat(:,(featIdx));
%% Train model with cross-validation
    idxSegments = mod(randperm(nTrials),k)+1;   %randomly split trails in to k groups
    cmT = zeros(nclass,nclass);                 % allocate space for confusion matrix
    for i = 1:k
    % each test on 1 group and train on the else
        validSet = logical(idxSegments == i)';
        trainSet = logical(idxSegments ~= i)';
        [results{i},trainErr{i}] =...
            classify(selectMat(validSet,:),selectMat(trainSet,:),Data.lables(trainSet),'linear');
        acc(i) = sum(results{i} == Data.lables(validSet));  %sum num of correct results
        acc(i) = acc(i)/length(results{i})*100;             
        %build the confusion matrix
        cm = confusionmat(Data.lables(validSet),results{i});
        cmT = cmT + cm;
    end
    %calculate accuracy and f1
%     percision = cmT(1,1)/(cmT(1,1) + cmT(1,2));
%     recall = cmT(1,1)/(cmT(1,1) + cmT(2,1));
%     f1(iter) = 2*((percision*recall)/(percision+recall));
%    
%     accAvg(it = mean(acc);
%     accSD(iter) = std(acc);
        
    trainAcc = (1-cell2mat(trainErr))*100;
%     trAccAvg(iter) = mean(trainAcc);
%     trAccSD(iter) = std(trainAcc);
% end

% if isTrainMode == 1             %plots for checking best features number 
%     disp(char("optimal number of features is: "+...
%         analyzeNumOfFeat(technicalPar,[f1,accAvg,accSD,trAccAvg,trAccSD],Features)));
% else                            %in regular mode, print accuracy and confusion matrix
    printAcc(mean(acc),std(acc),1);      
    printAcc( mean(trainAcc),std(trainAcc),0);
    figure('Units','normalized','Position',globalPos)
    cmChart = confusionchart(cmT,[classes(1) classes(2)],'FontSize',15,'DiagonalColor','g','OffDiagonalColor','r');
    cmChart.Title = char(classes(1)+" "+classes(2)+" classification");
% end


% plot PCA
plots('pca',Data,technicalPar,null,Features.featMat)


%% Test
%Load test data

load(testFileName)
testData = data(:,:,1:length(technicalPar.chans));

%Test feature extraction

Features.TestFeatMat = zeros(size(testData,1),Features.nFeat);              %allocate space
Features = extractFeatures(testData,technicalPar,Features,'TestFeatMat');     %calc and extract all features

%Test feature selection
Features.TestFeatMat = Features.TestFeatMat(:,featIdx);                 %choosing the same features
Features.TestFeatMat = (Features.TestFeatMat - meanTrain(:,featIdx))./SdTrain(:,featIdx);      % scale according to train data

%Test classifier - output is the classifier predictions for test data.
testPredict = classify(Features.TestFeatMat,selectMat,Data.lables,'linear');








