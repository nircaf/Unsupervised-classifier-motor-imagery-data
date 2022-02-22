%MATLAB 2019a
%this code loads an EEG structure extarcts feature out of the data and trains an LDA model
%to predict between two classes
% for run = 1: 50

clear all; close all;
% load('run.mat')
%% expariment param
load('motor_imagery_train_data.mat');       % trainig data
fs = P_C_S.samplingfrequency;               %sampling frequency, Hz
nSamples = size(P_C_S.data,2);              % num of sample
times = 1/fs:1/fs:nSamples/fs;                %create time vec according to parameters
f = 0.5:0.1:40;                             % relevant freq range
window = 1.2;                               %window length in secs
windOverlap = 1;                          %window overlap length in secs
numOfWindows = floor((size(P_C_S.data,2)-window*fs)/...
    (window*fs-floor(windOverlap*fs)))+1;   %number of windows
miStart = 2.25;                             %motor imagery start in sec
miPeriod = times(times >= miStart);     %motor imagery period
edgePrct = 90;                              %spectral edge percentaile
null = 0;                                   %in case of no input needed
chans = cell2mat(P_C_S.channelname(1:2));   %channels in use
chans = str2num(chans);
chansName = ["C3" "C4"];                    %channels names should corresponds to chans
nchans = length(chans);                     % num of channels
sides = P_C_S.attributename(3:end);       %extract classes assuming rows 1,2 are artifact and remove
numberSides = length(sides);                                 %this project support two classes only
sides = string(sides);

ntrialsPerClass = [sum(P_C_S.attribute(3,:)==1),...
    sum(P_C_S.attribute(4,:)==1)]; % Third and fouth rows contain left and right

% creating struct for all relevant parameters
technicalPar = struct('fs',fs,'time',times,'freq',f,'nTrials',size(P_C_S.data,1),'winLen',floor(window*fs),...
    'winOvlp',floor(windOverlap*fs),'miPeriod',miPeriod,'nclass',numberSides,'classes',sides, ...
    'clasRow',cell2mat({3, 4}'),'ntrialsPerClass',ntrialsPerClass,...
    'chans',chans,'chansName',chansName,'nchans',nchans,'edgePrct',edgePrct);


% isTrainMode = 0; % if set to 1 than the script will ran a loop in order to
%check the best num of features to select using analyzeNumOfFeat function
%when is set to 0 a normal run will occur

%% Data
% creating struct for all relevant data and arrange it
Data.all = P_C_S.data;
Data.combLables = cell(1,nchans*numberSides);        %lables for channels*class combinations
Data.lables = strings(technicalPar.nTrials,1);               %lable each trail for his class
countCol = 1;
for i = 1:numberSides
    currClass = sides(i);
    Data.indexes.(sides{i}) = find(P_C_S.attribute(technicalPar.clasRow(i),:)==1);   %finding the indexes for each class
    Data.lables(Data.indexes.(sides{i})) = currClass;                         %lable each trail for his class
    for j = 1:nchans
        sideName = char(currClass + chansName(j));                               %creating combination name
        Data.(sideName) = Data.all(Data.indexes.(sides{i}),:,chans(j));    %arrange data by combination
        Data.combLables{1,countCol} = sideName;
        countCol = countCol+1;
    end
end

%% features

%band power features
feat.bandPower{1} = {[12,15],[3.5,6]}; % Low Beta 1
feat.bandPowerName{1} = "Low Beta 1";
feat.bandPower{2} = {[15,19],[3.5,6]}; % Low Beta 2
feat.bandPowerName{2} = "Low Beta 2";
feat.bandPower{3} = {[19,23],[1.2,2.7]}; % High Beta 1
feat.bandPowerName{3} = "High Beta 1";
feat.bandPower{4} = {[23,30],[1.2,2.7]}; % High Beta 2
feat.bandPowerName{4} = "High Beta 2";
feat.bandPower{5} = {[30,34],[4,6]}; % Gamma
feat.bandPowerName{5} = "Gamma";
feat.bandPower{6} = {[8,12],[5.5,6]}; % Alpha
feat.bandPowerName{6} = "Alpha";


nBandPowerFeat = length(feat.bandPower)*2;  %bandpower and relative bandpower for each relevant range

feat.diffBetween = ["C3","C4"];             % choose two elctrode to calc diff

feat.selectedFeat = 11;                               %number of general features
feat.nFeat = ((nBandPowerFeat+feat.selectedFeat)*numberSides); %num of total features feature selection method

%% Model training
trainingPar = feat.selectedFeat;                          %k traning parameter
results = cell(trainingPar,1);

%% visualization
% Set the figure
paper_width     = 0.85; %cm
figure_ratio    = 0.7;  % Figure's height/width ratio
figPosition = [0.1, 0.1, paper_width, figure_ratio*paper_width];    %cm  main screen, upper right side
titlePosition = [0.45,0.999];      %global title position
%first visualization
signalPerFig = 20;              %signals per figuer
plotPerRow = 4;                 %plots per row
plotPerCol = signalPerFig/plotPerRow; %make sure signalPerFig divisible with plotPerRow
%histogram
xLim = [-4 4];                  %x axis lims in sd
binWid = 0.2;
trnsp = 0.5;                    %bars transparency
binEdges = xLim(1):binWid:xLim(2);

technicalPar.Vis = struct('globalPos', figPosition,'globTtlPos',titlePosition,...
    'signalPerFig',signalPerFig,'plotPerRow',plotPerRow,'plotPerCol',plotPerCol,...
    'xLim',xLim,'binEdges',binEdges,'trnsp',trnsp);
%% Pwelch
for i = 1:numberSides
    for j = 1:length(technicalPar.chans)
        currClass = technicalPar.classes(i);
        sideName = char(currClass + chansName(j));
        Data.PWelch.(sideName) = pwelch(Data.(sideName)(:,(technicalPar.miPeriod*fs))',...
            technicalPar.winLen,technicalPar.winOvlp,technicalPar.freq,technicalPar.fs);
    end
end
%visualization PWelch
plots('Pwelch',Data,technicalPar)
%% data visualization
%visualization of the signal in Voltage[muV] for rand co-responding trails
plots('dataviz',Data,technicalPar)
% calculating PWelch for all condition


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


%% features creation
feat.matrix = zeros(technicalPar.nTrials,feat.nFeat);       %allocate space
feat.featLables = cell(1,feat.nFeat);           %allocate space to features name
feat = featureCreate(Data.all,technicalPar,feat,'matrix');   %calc and extract all features
[feat.matrix,trainavg,trainstd] = zscore(feat.matrix);            % scale all features

%% histogram
plots('FeaturesHist',Data,technicalPar,feat);

%% feature selection
[accuracySave,bestFeatDeduct] =deal(0);
for k=1: feat.selectedFeat
    accuracy = trainingfeat(feat,Data,technicalPar.nTrials,k);
    if mean(accuracy)>accuracySave
        accuracySave = mean(accuracy);
        bestFeatDeduct = k;
    end
end
[accuracy,trainError,confusionMatrixSum,matrixFeatSelected,featindex] ...
    = trainingfeat(feat,Data,technicalPar.nTrials,bestFeatDeduct);
%% Validation precentage
trainAccuracy = (1-cell2mat(trainError))*100;
fprintf("Number of optimal features is: %g\n",(feat.selectedFeat-bestFeatDeduct+1));
fprintf("The validation accuracy is: %g%% with standart diviation of: %g%%\n",mean(accuracy),std(accuracy));
fprintf("The training accuracy is: %g%% with standart diviation of: %g%% \n",mean(trainAccuracy),std(trainAccuracy));  
% plot confusionchart
figure('Units','normalized','Position',figPosition)
cmChart = confusionchart(confusionMatrixSum,[sides(1) sides(2)],'FontSize',15,'DiagonalColor','g','OffDiagonalColor','r');
cmChart.Title = char(sides(1)+" "+sides(2)+" classification");
% plot PCA
plots('pca',Data,technicalPar,null,feat.matrix)

%% Test
%Load test data
load('motor_imagery_test_data.mat')
testData = data(:,:,1:length(technicalPar.chans));

%Test feature extraction
feat.TestFeatMat = zeros(size(testData,1),feat.nFeat);              %allocate space
feat = featureCreate(testData,technicalPar,feat,'Testing');     %calc and extract all features

%Test feature selection
feat.Testing = feat.Testing(:,featindex);                 %choosing the same features
feat.Testing = (feat.Testing - trainavg(:,featindex))./trainstd(:,featindex);      % scale according to train data

%Test classifier - output is the classifier predictions for test data.
testPredict = classify(feat.Testing,matrixFeatSelected,Data.lables);

% saverun = mean(accuracy);
% run = run +1;
% save('run.mat','run');
% xlswrite('My_file.xls',saverun,'Sheet1',sprintf('A%g',run));     %Write data
% 
% end








