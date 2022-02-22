function [feat] = featureCreate(Data,technicalPar,feat,type)
% featureCreate Summary:
% this function extracts fearures from the data, and creats a matrix 
% called "feat" which contains them.
% "Data" is a struct which contains data on which this process is performed
% "technicalPar" are the parameter of the Data
% "feat" -is a struct which contains the features extracted from the data
% "type" - determines the sort of the data: train or test

featindex =1;
for i = 1:length(technicalPar.Channels)
    for j = 1:length(feat.bandPower)    %loop over all bands
        tRange = (technicalPar.time_vector >= feat.bandPower{j}{2}(1) & ...
            technicalPar.time_vector <= feat.bandPower{j}{2}(2));
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
    %perform PWelch
    [PW,freqPW] = pwelch(Data(:,(technicalPar.imagery_time*technicalPar.fs),i)',...
        technicalPar.windowLength,technicalPar.Noverlap,technicalPar.frequency,technicalPar.fs); 
    
    %% total power
    feat.(type)(:,featindex) = sum(PW)';
    feat.featLables{featindex} = char("Total Power - " + technicalPar.chansName{i});  %name features accordingly
    featindex = featindex + 1;
    %% root total power
    feat.(type)(:,featindex) =sqrt(sum(PW))';
    feat.featLables{featindex} = char("Root Total Power - "+ technicalPar.chansName{i}); %name features accordingly
    featindex = featindex + 1;
    %% ArithmeticMean
    feat.(type)(:,featindex) = mean(PW);
    feat.featLables{featindex} = char("Arithmetic Mean - "+ technicalPar.chansName{i});%name features accordingly
    featindex = featindex + 1;
    %% MeanCurveLength
    Y = zeros(1,size(PW,2));
    for j=1 : size(PW,2)
        for m = 2:size(PW,1)
            Y(j) = Y(j) + abs(PW(m,j) - PW(m-1,j));
        end
    end
    feat.(type)(:,featindex) = (1 / size(PW,1)) * Y;
    feat.featLables{featindex} = char("Mean Curve Length - " + technicalPar.chansName{i}); %name features accordingly
    featindex = featindex + 1;
    %% spectral Moment
        prob = PW./sum(PW);    %creat a probability function by normalizing the power by the total power
    feat.(type)(:,featindex) = (technicalPar.frequency*prob)';
    feat.featLables{featindex} = char("Spectral Moment - "+ technicalPar.chansName{i}); %name features accordingly
    featindex = featindex + 1;
    
    %% Spectral entropy
    feat.(type)(:,featindex) = (-sum(prob .* log2(prob),1))';
    feat.featLables{featindex} = char("Spectral Entropy - "+ technicalPar.chansName{i});%name features accordingly
    featindex = featindex + 1;
    %% Renyi Entropy
    % Parameter
    alpha = 2;     % alpha
    % Entropy
    En   = prob .^ alpha;
    feat.(type)(:,featindex) =     (1 / (1 - alpha)) * log2(sum(En));
    feat.featLables{featindex} = char("Renyi Entropy - " + technicalPar.chansName{i}); %name features accordingly
    featindex = featindex + 1; 
    %% Kurtosis
        feat.(type)(:,featindex) =     kurtosis(PW);
    feat.featLables{featindex} = char("Kurtosis - " + technicalPar.chansName{i}); %name features accordingly
    featindex = featindex + 1; 
        %% skewness
        feat.(type)(:,featindex) =     skewness(PW);
    feat.featLables{featindex} = char("Skewness - " + technicalPar.chansName{i}); %name features accordingly
    featindex = featindex + 1; 
    %% Standard Deviation
        feat.(type)(:,featindex) =     std(PW);
    feat.featLables{featindex} = char("Standard Deviation - " + technicalPar.chansName{i}); %name features accordingly
    featindex = featindex + 1;
    %% Variance
        feat.(type)(:,featindex) =     var(PW);
    feat.featLables{featindex} = char("Variance - " + technicalPar.chansName{i}); %name features accordingly
    featindex = featindex + 1;
end


end