% MATLAB and neural data-analysis - Final Project
clear all; close all;
%% Parameters
load('motor_imagery_train_data.mat');        %load trainig data
fs = P_C_S.samplingfrequency;                %frequency of sampling [Hz]
nSamples = size(P_C_S.data,2);               %number of sample
times = 1/fs:1/fs:nSamples/fs;               %time vector
f = 0.5:0.1:40;                              %frequency range
window = 1.2;                                %length of time window [sec]
Noverlap = 1;                                %length of window overlap [sec]
miStart = 2.25;                              %motor imagery start in sec
i_time_vector = times(times >= miStart);     %imagery time vector
edgePrct = 90;                               %spectral edge percentaile
null = 0;                                    %in case of no input needed
channels = cell2mat(P_C_S.channelname(1:2)); %relevant channels
channels = str2num(channels);
name_of_chan = ["C3" "C4"];                  %names of the relevant channels
nchannels = length(channels);                %number of channels
sides = P_C_S.attributename(3:end);          %extract classes assuming rows 1,2 are artifact and remove
numberSides = length(sides);                 %only left and right attributes are relevant
sides = string(sides);
ntrialsPerClass = [sum(P_C_S.attribute(3,:)==1),...
    sum(P_C_S.attribute(4,:)==1)];           %number of trails per callification.
%Third and fouth rows contain left and right

%a struct which will contain all parameters
technicalPar = struct('fs',fs,'time_vector',times,'frequency',f,'nTrials',size(P_C_S.data,1),'windowLength',floor(window*fs),...
    'Noverlap',floor(Noverlap*fs),'imagery_time',i_time_vector,'nClassification',numberSides,'classes',sides, ...
    'clasRow',cell2mat({3, 4}'),'ntrialsPerClass',ntrialsPerClass,...
    'Channels',channels,'chansName',name_of_chan,'nchans',nchannels,'edgePrct',edgePrct);


%% Data
%creat a struct for all relevant data and arrange it
Data.all = P_C_S.data;
Data.CaseName = cell(1,nchannels*numberSides);  %naming the different combinations of electrode and attribute
Data.lables = strings(technicalPar.nTrials,1);  %lable trails as the suitable attribute
countCol = 1;
for i = 1:numberSides %loop over left and right
    side_attribute = sides(i);
    Data.indexes.(sides{i}) = find(P_C_S.attribute(technicalPar.clasRow(i),:)==1); %Find the places of the corresponding attribute
    Data.lables(Data.indexes.(sides{i})) = side_attribute;                         %Name as the corresponding attribute
    for j = 1:nchannels %loop over C3 and C4
        sideName = char(side_attribute + name_of_chan(j));                         %Combine attribute and electrode into one name
        Data.(sideName) = Data.all(Data.indexes.(sides{i}),:,channels(j));         %arrange data by name
        Data.CaseName{1,countCol} = sideName;
        countCol = countCol+1;
    end
end

%% features

%creat struct which contains features
%band power:
feat.bandPower{1} = {[8,12],[5.5,6]};    %Alpha
feat.bandPowerName{1} = "Alpha";
feat.bandPower{2} = {[12,15],[3.5,6]};   %Low Beta
feat.bandPowerName{2} = "Low Beta 1";
feat.bandPower{3} = {[15,19],[3.5,6]};   %Low Beta
feat.bandPowerName{3} = "Low Beta 2";
feat.bandPower{4} = {[19,23],[1.2,2.7]}; %High Beta
feat.bandPowerName{4} = "High Beta 1";
feat.bandPower{5} = {[23,30],[1.2,2.7]}; %High Beta
feat.bandPowerName{5} = "High Beta 2";
feat.bandPower{6} = {[30,34],[4,6]};     %Gamma
feat.bandPowerName{6} = "Gamma";


nFeatBandPower = length(feat.bandPower)*2; %bandpower and relative-bandpower

feat.diffBetween = ["C3","C4"];            %choose the relevant elctrode to calc diff

feat.selectedFeat = 11;            %number of features used for training the model this is the number of features extracted
feat.nFeat = (nFeatBandPower+feat.selectedFeat)*numberSides; %number of total features extracted over channels

%% Model training
trainingPar = feat.selectedFeat;                          %k traning parameter
results = cell(trainingPar,1);

%% visualization
%Set the figure
paper_width     = 0.8;         %cm
figure_ratio    = 0.73;         %Figure's height/width ratio
figPosition = [0.1, 0.15, paper_width, figure_ratio*paper_width];    %cm  main screen, upper right side
titlePosition = [0.45,0.999];  %global title position
%first visualization
nSignals = 20;             %signals per figuer
plotPerRow = 4;                %plots per row
plotPerCol = nSignals/plotPerRow; %make sure nSignals divisible with plotPerRow
%histogram
xLim = [-3 3];                 %x axis lims in sd
binWid = 0.2;
trnsp = 0.5;                   %bars transparency
binEdges = xLim(1):binWid:xLim(2);

%creat a struct which contains plot features
technicalPar.Vis = struct('PositionOfFig', figPosition,'PositionOfTitle',titlePosition,...
    'nSignals',nSignals,'plotPerRow',plotPerRow,'plotPerCol',plotPerCol,...
    'xLim',xLim,'binEdges',binEdges,'trnsp',trnsp);
%% Pwelch

%perform PWelch
%loop over all sides and electrodes:
for i = 1:numberSides 
    for j = 1:length(technicalPar.Channels)
        side_attribute = technicalPar.classes(i);
        sideName = char(side_attribute + name_of_chan(j));
        Data.PWelch.(sideName) = pwelch(Data.(sideName)(:,(technicalPar.imagery_time*fs))',...
            technicalPar.windowLength,technicalPar.Noverlap,technicalPar.frequency,technicalPar.fs);
    end
end

%% data visualization
%visualization of the signal in Voltage[muV] for rand co-responding trails
plots('dataviz',Data,technicalPar)
%visualization PWelch
plots('Pwelch',Data,technicalPar)
%perform spectrogram
%loop over all cases:
for i =1:length(Data.CaseName)    
    for j = 1:size(Data.(Data.CaseName{i}),1)
        Data.spect.(Data.CaseName{i})(j,:,:) = spectrogram(Data.(Data.CaseName{i})(j,:)',...
            technicalPar.windowLength,technicalPar.Noverlap,technicalPar.frequency,technicalPar.fs,'yaxis');
    end
    %convert units, and then avaerage it:
    Data.spect.(Data.CaseName{i}) = squeeze(mean(10*log10(abs(Data.spect.(Data.CaseName{i}))).^2));
end
%plot spectogram:
plots('Spectogram',Data,technicalPar)
plots('SpectDiff',Data,technicalPar)
%% features creation
feat.matrix = zeros(technicalPar.nTrials,feat.nFeat);     %Create an initial matrix which will contain the features
feat.featLables = cell(1,feat.nFeat);                     %Create an initial cell arrays which will contain the features' names
feat = featureCreate(Data.all,technicalPar,feat,'matrix');%extract features
[feat.matrix,trainavg,trainstd] = zscore(feat.matrix);    %perform zscore on all features so that columns have mean 0 and sd 1

%% histogram
plots('FeaturesHist',Data,technicalPar,feat); %plot histogram
%% feature selection
[accuracySave,bestFeatDeduct] =deal(0);
for featDeduct=1: feat.selectedFeat %loop over selected features
    accuracy = trainingfeat(feat,Data,technicalPar.nTrials,featDeduct);
    if mean(accuracy)>accuracySave % if this compilation of features is better than previous 
        accuracySave = mean(accuracy);
        bestFeatDeduct = featDeduct;
    end
end
[accuracy,trainError,confusionMatrixSum,matrixFeatSelected,featindex] ...
    = trainingfeat(feat,Data,technicalPar.nTrials,bestFeatDeduct);
%% Validation precentage
%print validation data as cumputed with trainingfeat function
trainAccuracy = (1-cell2mat(trainError))*100;
fprintf("Number of optimal features is: %g\n",(feat.selectedFeat-bestFeatDeduct+1));
fprintf("The validation accuracy is: %g%% with standard diviation of: %g%%\n",mean(accuracy),std(accuracy));
fprintf("The training accuracy is: %g%% with standard diviation of: %g%% \n",mean(trainAccuracy),std(trainAccuracy));
%plot confusionchart which displays the total number of observations in
%each cell:
figure('Units','normalized','Position',figPosition)
cmChart = confusionchart(confusionMatrixSum,[sides(1) sides(2)],'FontSize',15,'DiagonalColor','g','OffDiagonalColor','r');
cmChart.Title = char(sides(1)+" "+sides(2)+" classification Confusion matrix");
%plot PCA
plots('pca',Data,technicalPar,null,feat.matrix)
%% Test
load('motor_imagery_test_data.mat') %Load test set
test_data = data(:,:,1:length(technicalPar.Channels));

%Apply feature extraction procedure to the test set:
feat.TestFeatMat = zeros(size(test_data,1),feat.nFeat);      %Create an initial matrix which will contain the features
feat = featureCreate(test_data,technicalPar,feat,'Testing'); %extract features
%Test feature selection
feat.Testing = feat.Testing(:,featindex);                    %choose the corresponding features
feat.Testing = (feat.Testing - trainavg(:,featindex))./trainstd(:,featindex);   %scale as train data set

%Apply classifier to the features extracted from the test set to obtain a predicted
%classification:
predicted_class = classify(feat.Testing,matrixFeatSelected,Data.lables);