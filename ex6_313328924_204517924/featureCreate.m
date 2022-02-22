function [feat] = featureCreate(Data,technicalPar,feat,type)
% function that extract all fearures and arrange it in a (type)
% Data - all data for extracting the features
% Prmtr - all parameter of the Data
% Features - struct that containing all features data lables and parameters
% (type) - train or test (type)
featindex =1;
for i = 1:length(technicalPar.chans)
    for j = 1:length(feat.bandPower)    %looping over relevant range
        tRange = (technicalPar.time >= feat.bandPower{j}{2}(1) & ...
            technicalPar.time <= feat.bandPower{j}{2}(2));
        %% raw bandpower
        feat.(type)(:,featindex) = ...
            (bandpower(Data(:,tRange,i)',technicalPar.fs,feat.bandPower{j}{1}))';
        feat.featLables{featindex} =char("Bandpower - "+technicalPar.chansName(i)+newline+...
            " "+ feat.bandPowerName{j} +": "+ feat.bandPower{j}{1}(1)+"Hz - "...
            +feat.bandPower{j}{1}(2)+"Hz");
        featindex = featindex + 1;
        %% relative bandpower
        totalBP = bandpower(Data(:,tRange,i)')';
        feat.(type)(:,featindex) = feat.(type)(:,featindex-1)./totalBP;
        feat.featLables{featindex} =char("Relative Bandpower - "+technicalPar.chansName(i)+newline+...
            " "+ feat.bandPowerName{j} +" frequency: " + feat.bandPower{j}{1}(1)+"Hz - "...
            +feat.bandPower{j}{1}(2)+"Hz");
        featindex = featindex + 1;
    end
    [PW,freqPW] = pwelch(Data(:,(technicalPar.miPeriod*technicalPar.fs),i)',...
        technicalPar.winLen,technicalPar.winOvlp,technicalPar.freq,technicalPar.fs);    %calc PWelch for features
    
    %% total power
    feat.(type)(:,featindex) = sum(PW)';
    feat.featLables{featindex} = char("Total Power - " + technicalPar.chansName{i});  %update the feature name
    featindex = featindex + 1;
    %% root total power
    feat.(type)(:,featindex) =sqrt(sum(PW))';
    feat.featLables{featindex} = char("Root Total Power - "+ technicalPar.chansName{i});%update the feature name
    featindex = featindex + 1;
    %% Max
    feat.(type)(:,featindex) = max(PW);
    feat.featLables{featindex} = char("Maximum - "+ technicalPar.chansName{i});%update the feature name
    featindex = featindex + 1;
    %% Min
    feat.(type)(:,featindex) = min(PW);
    feat.featLables{featindex} = char("Minimum - "+ technicalPar.chansName{i});%update the feature name
    featindex = featindex + 1;
    %% ArithmeticMean
    feat.(type)(:,featindex) = mean(PW);
    feat.featLables{featindex} = char("Arithmetic Mean - "+ technicalPar.chansName{i});%update the feature name
    featindex = featindex + 1;
    %% MeanCurveLength
    Y = zeros(1,size(PW,2));
    for j=1 : size(PW,2)
        for m = 2:size(PW,1)
            Y(j) = Y(j) + abs(PW(m,j) - PW(m-1,j));
        end
    end
    feat.(type)(:,featindex) = (1 / size(PW,1)) * Y;
    feat.featLables{featindex} = char("Mean Curve Length - " + technicalPar.chansName{i});%update the feature name
    featindex = featindex + 1;
    %% spectral Moment
    prob = PW./sum(PW);    %normalize the power by the total power so it can be treated as a probability
    feat.(type)(:,featindex) = (technicalPar.freq*prob)';
    feat.featLables{featindex} = char("Spectral Moment - "+ technicalPar.chansName{i});%update the feature name
    featindex = featindex + 1;
    
    %% Spectral entropy
    feat.(type)(:,featindex) = (-sum(prob .* log2(prob),1))';
    feat.featLables{featindex} = char("Spectral Entropy - "+ technicalPar.chansName{i});%update the feature name
    featindex = featindex + 1;
    %% Renyi Entropy
    % Parameter
    alpha = 2;     % alpha
    % Entropy
    entropy   = prob .^ alpha;
    feat.(type)(:,featindex) =     (1 / (1 - alpha)) * log2(sum(entropy));
    feat.featLables{featindex} = char("Renyi Entropy - " + technicalPar.chansName{i});%update the feature name
    featindex = featindex + 1;
    %% Kurtosis
    feat.(type)(:,featindex) =     kurtosis(PW);
    feat.featLables{featindex} = char("Kurtosis - " + technicalPar.chansName{i});%update the feature name
    featindex = featindex + 1;
    %% skewness
    feat.(type)(:,featindex) =     skewness(PW);
    feat.featLables{featindex} = char("Skewness - " + technicalPar.chansName{i});%update the feature name
    featindex = featindex + 1;
%     %% Standard Deviation
%     feat.(type)(:,featindex) =     std(PW);
%     feat.featLables{featindex} = char("Standard Deviation - " + technicalPar.chansName{i});%update the feature name
%     featindex = featindex + 1;
%     %% Variance
%     feat.(type)(:,featindex) =     var(PW);
%     feat.featLables{featindex} = char("Variance - " + technicalPar.chansName{i});%update the feature name
%     featindex = featindex + 1;
end

% % diff Amplitude between channels
% chan1 = find(technicalPar.chansName == feat.diffBetween(1));
% chan2 = find(technicalPar.chansName == feat.diffBetween(2));
% feat.(type)(:,featindex) = sum(Data(:,(technicalPar.miPeriod*technicalPar.fs),chan1)-...
%     Data(:,(technicalPar.miPeriod*technicalPar.fs),chan2),2);
% feat.featLables{featindex} = char(" Amplitude Difference: " + technicalPar.chansName{chan1} + "-" + technicalPar.chansName{chan2});
end