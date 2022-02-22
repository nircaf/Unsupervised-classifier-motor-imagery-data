%
% MATLAB and neural data-analysis - Exercise #3
%
% Place your code this scaffold (marked with YOUR_CODE). The commented code
% lines serve as suggestions and clues for your solution.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%clearing commands
%YOUR_CODE starts here
close all; clear all;
%YOUR_CODE ends here
%% parameters
%define parameters here and avoid magic numbers
load('motor_imagery_train_data.mat');
load('motor_imagery_test_data.mat');
fs = P_C_S.samplingfrequency;
datatrain = P_C_S.data;
trials = datatrain(:,:,1);
timesamples = datatrain(:,:,2);
attribute = P_C_S.attribute;
attribute_left = find(attribute(3,:)==1);
attribute_right = find(attribute(4,:)==1);
dataleft = datatrain(attribute_left,:,1:2);
dataright = datatrain(attribute_right,:,1:2);
ftime = (0:1/fs:(size(dataleft,2)-1)/(fs))

% plotleftright(dataleft,dataright,ftime);
dt = 1/fs;                                  %time step [sec]
nTrials = size(P_C_S.data,1);               % num of trails
trialLen = size(P_C_S.data,2);              % num of sample
timeVec = dt:dt:trialLen/fs;                %create time vec according to parameters
ffreq = 0.5:0.1:40;                             % relevant freq range
window = 1.1;                               %window length in secs
windOverlap = 1;                          %window overlap length in secs
numOfWindows = floor((size(P_C_S.data,2)-window*fs)/...
    (window*fs-floor(windOverlap*fs)))+1;   %number of windows
miStart = 2.25;                             %motor imagery start in sec
miPeriod = timeVec(timeVec >= miStart);     %motor imagery period
edgePrct = 90;                              %spectral edge percentaile
% creating struct for all relevant parameters
Prmtr = struct('fs',fs,'time',timeVec,'freq',ffreq,'nTrials',nTrials,'winLen',floor(window*fs),...
    'winOvlp',floor(windOverlap*fs),'miPeriod',miPeriod);
%     'clasRow',cell2mat(clasRow),'ntrialsPerClass',ntrialsPerClass,...
%     'chans',chans,'chansName',chansName,'nchans',nchans,'edgePrct',edgePrct);

pwelchleft = pwelch(dataleft(:,(Prmtr.miPeriod*fs),1)',...
    Prmtr.winLen,Prmtr.winOvlp,Prmtr.freq,Prmtr.fs);

secall = 6; %[sec]
sec40interval = 40*fs; %[sec]
sec20interval = sec40interval/2; %[sec]
fintervalue = 0.1; % Inter value between frequencies
frequencystart = 0.5; % Start frequency
frequencyend = 40; % End frequency
ffreq = frequencystart:fintervalue:frequencyend; %frequency band [Hz]
window = (frequencyend/2)*fs; %[samples] Half of 40Hz width requested to present
noverlap = floor(window/5); %[samples]
frequencybands = [1 4.5;4.5 8;8 11.5;11.5 15;15 30;30 40];
num_bands = length(frequencybands);

subplot(2,2,1)
pwelchleftc3 = pwelch(dataleft(:,:,1)',window,noverlap,ffreq,fs);
plot(ffreq,mean(pwelchleftc3,2))
plotlabels('left C3');
subplot(2,2,2)
pwelchleftc4 = pwelch(dataleft(:,:,2)',window,noverlap,ffreq,fs);
plot(ffreq,mean(pwelchleftc4,2))
plotlabels('left C4');
subplot(2,2,3)
pwelchrightc3 = pwelch(dataright(:,:,1)',window,noverlap,ffreq,fs);
plot(ffreq,mean(pwelchleftc3,2))
plotlabels('right C3');

subplot(2,2,4)
pwelchrightc4 = pwelch(dataright(:,:,2)',window,noverlap,ffreq,fs);
plot(ffreq,pwelchleftc4)
plotlabels('right C4');


dirPath = '.';

dirin = dir(dirPath);
for j=1: length(dirin)
    expression = 'test_data.mat';
    startIndex = regexp(dirin(j).name,expression);
    if startIndex
        load(fullfile(dirin(j).folder,dirin(j).name));
        datatest = data;
    end
    expression = 'train_data.mat';
    startIndex = regexp(dirin(j).name,expression);
    if startIndex
        load(fullfile(dirin(j).folder,dirin(j).name));
        datatrain = data;
    end
end
%
% %% Welch method
% num_of_windows=size(datasplit,2);
%
% electrodesall = size(datasplit{1,1},1);
% pwelchelectrode = cell(electrodesall,size(datasplit,2));
% features = zeros(electrodesall,18,size(datasplit,2));
%
% for patients =2:size(datasplit,1)
%     for windows =1:num_of_windows
%         for eletrodenum =1: electrodesall
%             allelectrodes = datasplit{patients,windows};
%             electroderun = allelectrodes(eletrodenum,:);
%             [pwelchelectrode{eletrodenum,windows},pwelchfreq] = pwelch(electroderun,window,noverlap,f,fs);
%             [RelativePower, RelativePowerln] = freq_bands(pwelchelectrode{eletrodenum,windows},...
%                 fs,[frequencystart frequencyend],frequencybands);
%             %% Relative Power 6 + 6
%             features(eletrodenum,1:num_bands,windows) = RelativePower/sum(RelativePower);
%             features(eletrodenum,num_bands+1:num_bands*2,windows) = RelativePowerln/sum(RelativePowerln);
%             %% Root total power 13
%             features(eletrodenum,1+num_bands*2,windows) = sqrt(sum(pwelchelectrode{eletrodenum,windows}));
%             %% Spectral slope 14
%             lnpower = log(pwelchelectrode{eletrodenum,windows});
%             lnfreq = log(pwelchfreq);
%             polyspectral = polyfit(lnfreq,lnpower,1);
%             %             plot(lnfreq,lnpower)
%             %             specval = polyval(polyspectral,lnfreq);
%             %             hold on
%             %             plot (lnfreq,specval)
%             %             hold off
%             features(eletrodenum,2+num_bands*2,windows) = mean(polyspectral(1:2:end));
%             %% Spectral intercept 15 - Y intercept
%             features(eletrodenum,3+num_bands*2,windows) = polyspectral(2);
%             %% Normalizing the raw power by the total power
%             pwelchnormalized = cell(size(pwelchelectrode));
%             pwelchnormalized{eletrodenum,windows} = pwelchelectrode{eletrodenum,windows}...
%                 ./sum(pwelchelectrode{eletrodenum,windows});
%
%             CreateGaussianmixturemodel = gmdistribution(mean(pwelchnormalized{eletrodenum,windows}),...
%                 cov(pwelchnormalized{eletrodenum,windows}));
%             probfuncspecent = pdf(CreateGaussianmixturemodel,pwelchnormalized{eletrodenum,windows}'); %Prob function
%
%             %% Spectral Edge 16
%             %vector of values in the top decile:
%             value_90=prctile(pwelchnormalized{eletrodenum,windows},90);
%             vector_90_up= pwelchnormalized{eletrodenum,windows}...
%                 (pwelchnormalized{eletrodenum,windows} >= value_90);
%             %get the value from the vector:
%             vector_90_up=min(vector_90_up);
%             features(eletrodenum,4+num_bands*2,windows) = vector_90_up;
%             %% Sperctral entropy 17
%             features(eletrodenum,5+num_bands*2,windows) = -sum(probfuncspecent.*log2(probfuncspecent));
%             %% Spectral moment 18
%             features(eletrodenum,6+num_bands*2,windows) =...
%                 sum(f'.*probfuncspecent);
%         end
%         %% Zscore
%         features(:,:,windows) = zscore(features(:,:,windows),0,1);
%     end
%     %% PCA
%     %reshape features into a 342X299 matrix, and preform PCA:
%     featuresreshapre= reshape(features, [18*elecNum,num_of_windows]);
%     coeff=pca(featuresreshapre,'Algorithm','eig','NumComponents',3 )';
%     %% Plots:
%     figure('Name','Pre Seizure Activity patterns','NumberTitle','off', ...
%         'units','centimeters', 'color','white', 'Position',[1, 1, 22, 15]);
%     txt= sprintf('Patient %s, seizure %s',(dirin(patients+2).name(2:3)),(dirin(patients+2).name(6)));
%     sgtitle(txt); %add a title for the whole figure
%
%     %2D:
%     subplot(1,2,2)
%     colors=colormap(jet(num_of_windows));
%     time= minall/num_of_windows:minall/num_of_windows:minall;
%     x=coeff(1,:);
%     y=coeff(2,:);
%     markerColors = zeros(num_of_windows,3);
%     for k =1:num_of_windows
%     markerColors(k,:)= colors(k,:);
%     end
%     scatter(x,y,[],markerColors,'filled');
%     colorbar
%     cd = colorbar;
%     cd.Label.String = 'time to seizure [min]';
%     cd.Label.FontSize = 15;
%     time_to_seizure= -100:minall/num_of_windows:0;
%     caxis([time_to_seizure(1) time_to_seizure(end)])
%     plotlabels('Features in 2D');
%
%     %3D:
%     subplot(1,2,1)
%     z=coeff(3,:);
%     markerColors = zeros(num_of_windows,3);
%     for k =1:num_of_windows
%     markerColors(k,:)= colors(k,:);
%     end
%     scatter3(x,y,z,[],markerColors,'filled');
%     plotlabels('Features in 3D');
% end
% publish('ex5_313160194_208393850.m');
