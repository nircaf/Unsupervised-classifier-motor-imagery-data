function [] = plotleftright(dataleft,dataright,f)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    randomtoplot = randperm(size(dataleft,1))
    
        %% Plots:
    figure('Name','Pre Seizure Activity patterns','NumberTitle','off', ...
        'units','centimeters', 'color','white', 'Position',[1, 1, 22, 15]);
    txt= sprintf('Visualize EEG Left');
    sgtitle(txt); %add a title for the whole figure
    
for j=1:20 
    subplot(5,4,j)
    plot(f,dataleft(randomtoplot(j),:,1))
    hold on
        plot(f,dataleft(randomtoplot(j),:,2))
hold off
plotlabels('',1);
end
        %% Plots:
    figure('Name','Pre Seizure Activity patterns','NumberTitle','off', ...
        'units','centimeters', 'color','white', 'Position',[1, 1, 22, 15]);
    txt= sprintf('Visualize EEG Right');
    sgtitle(txt); %add a title for the whole figure
        randomtoplot = randperm(size(dataright,1))
for j=1:20 
    subplot(5,4,j)
    plot(f,dataright(randomtoplot(j),:,1))
    hold on
        plot(f,dataright(randomtoplot(j),:,2))
hold off
plotlabels('',1);
end
end

