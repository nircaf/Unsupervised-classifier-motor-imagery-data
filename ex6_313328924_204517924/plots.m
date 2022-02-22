function plots(type,Data,technicalPar,feat,featMet)
%PLOTS Summary of this function goes here
%   Detailed explanation goes here
switch type
    %% pca
    case 'pca'
        %case: compute pca for each component and attribute and plot pca
        figure('Units','normalized','Position',technicalPar.Vis.globalPos);
        
        comp = pca(featMet,'NumComponents',3);  %choose the best 3 PCA
        component = (featMet * comp)';  % coded matrix
        sz = 11;    %Scatter dots size
        %2 dimentional
        sgtitle("PCA Plots",'FontSize',15);
        subplot(1,2,1)
        scatter(component(1,(Data.indexes.LEFT)),...
            component(2,(Data.indexes.LEFT)),sz,'b','filled');hold on;
        hold on;
        scatter(component(1,(Data.indexes.RIGHT)),...
            component(2,(Data.indexes.RIGHT)),sz,'r','filled')
        title('2 Dimentional PCA','FontSize',15)
        axis square
        xlabel('PC1'); ylabel('PC2');
        set(gca,'YDir','normal','FontSize',15)
        %3 dimentional
        subplot(1,2,2)
        scatter3(component(1,(Data.indexes.LEFT)),...
            component(2,(Data.indexes.LEFT)),component(3,(Data.indexes.LEFT)),sz,'b','filled')
        hold on;
        scatter3(component(1,(Data.indexes.RIGHT)),...
            component(2,(Data.indexes.RIGHT)),component(3,(Data.indexes.RIGHT)),sz,'r','filled')
        title('3 Dimentional PCA','FontSize',15)
        axis square
        xlabel('PC1','FontSize',15); ylabel('PC2','FontSize',15); zlabel('PC3','FontSize',15);
        set(gca,'YDir','normal','FontSize',15)
        leg3 = legend(technicalPar.classes(1),technicalPar.classes(2));
        pos2 = [0.01203125,0.839907407407407,0.062239583333333,0.078148148148148];
        set(leg3,'position',pos2)
        %% Pwelch
    case 'Pwelch'
        figure('Units','normalized','Position',technicalPar.Vis.globalPos);
        for i = 1:length(Data.combLables)   %looping all condition
            subplot(technicalPar.nchans,technicalPar.nclass,i)
            plot(technicalPar.freq,mean(Data.PWelch.(Data.combLables{i}),2))
            title(Data.combLables{i},'FontSize',15);hold on
            if(mod(i-1,technicalPar.nchans)==0)
                ylabel('Power Spectrom','FontSize',15)
            end
            if(i>=3)
                xlabel('Frequency[Hz]','FontSize',15)
            end
        end
        hold off
        %compare the chanle for each class for the PWelch results
        figure('Units','normalized','Position',technicalPar.Vis.globalPos);
        for i =1:length(technicalPar.chansName)
            subplot(technicalPar.nchans,1,i)
            plot(technicalPar.freq,mean(Data.PWelch.(Data.combLables{i}),2),'r')   %left
            hold on
            plot(technicalPar.freq,mean(Data.PWelch.(Data.combLables{i+2}),2),'b') %right
            title(strcat('Power Spectrom diff',{'  '}', (technicalPar.chansName{i})),'FontSize',15)
            ylabel('Power Spectrom','FontSize',15)
            if(i>1)
                xlabel('Frequency[Hz]','FontSize',15)
            end
            legend(technicalPar.classes{1},technicalPar.classes{2})
        end
        %% Spectdiff
    case 'Spectdiff'
        %case: calculate mean diff between class for each chanle from the spectogram results
        figure('Units','normalized','Position',technicalPar.Vis.globalPos);
        
        diff1 = Data.spect.(Data.combLables{1})-Data.spect.(Data.combLables{3});
        diff2 = Data.spect.(Data.combLables{2})-Data.spect.(Data.combLables{4});
        spectDiffCond = {diff1,diff2};
        diffTitle = {'C3Diff','C4Diff'};
        sgtitle('Spectogram Diff','FontSize',15)
        for i = 1:length(spectDiffCond)
            subplot(1,length(spectDiffCond),i)
            imagesc(technicalPar.time,technicalPar.freq,spectDiffCond{i})
            set(gca,'YDir','normal','FontSize',15)
            colormap(jet);
            axis square
            title(diffTitle{i})
            if(i == 1)
                ylabel ('Frequency [Hz]','FontSize',15);
            end
            xlabel ('Time [sec]','FontSize',15);
        end
        cb2 = colorbar;
        cb2.Label.String = 'Power diff [dB]';
        pos = [0.91868,0.324253,0.0117708,0.340874];
        lablPos = [3.9142857,0.54263613,0];
        set(cb2,'units','Normalized','position',pos,'FontSize',15);
        set(cb2.Label,'units','Normalized','position',lablPos,'FontSize',15);
        caxis('auto');
        %% Spectogram
    case 'Spectogram'
        %case: plot the spctral power for each condition returned by
        %spectogram commend
        figure('Units','normalized','Position',technicalPar.Vis.globalPos);
        
        for i = 1:length(Data.combLables)   %looping all condition
            subplot(technicalPar.nclass,technicalPar.nchans,i)
            imagesc(technicalPar.time,technicalPar.freq,Data.spect.(Data.combLables{i}))
            set(gca,'YDir','normal','FontSize',15)
            colormap(cool);
            axis square
            title(Data.combLables{i});
            ylabel ('Frequency [Hz]','FontSize',15);
            xlabel ('Time [sec]','FontSize',15);
        end
        cb = colorbar;
        cb.Label.String = 'Power diff [dB]';
        cb.FontSize = 15;
        pos = [0.9,0.3,0.02,0.35];
        set(cb,'units','Normalized','position',pos);
        caxis('auto');
        %% dataviz
    case 'dataviz'
        for clss =1: size(struct2table(Data.indexes),2) % Go over left and right
            timeVec = [0:length(technicalPar.time)-1]/technicalPar.fs;    %time in sec
            figure('Units','normalized','Position',technicalPar.Vis.globalPos);
            set(gca,'YDir','normal','FontSize',15)
            randIndex_trails = Data.indexes.(technicalPar.classes{clss})...
                (randperm(length(Data.indexes.(technicalPar.classes{clss})),...
                (technicalPar.Vis.plotPerRow*technicalPar.Vis.plotPerCol)));   %choose rand trails
            sgtitle(technicalPar.classes{clss} + " " + "Imagery",'FontSize',15)
            for i = 1:length(randIndex_trails)
                subplot(technicalPar.Vis.plotPerCol,technicalPar.Vis.plotPerRow,i)
                C3 = plot(timeVec,Data.all(randIndex_trails(i),:,1),'b');   %c3 signal
                hold on
                C4 = plot(timeVec,Data.all(randIndex_trails(i),:,2),'r','LineStyle','-.');   %c4 signal
                ylim([-15,15])
                xlabel('time [sec]','FontSize',15);
                ylabel('Amplitude[\muV]','FontSize',15);
            end
            hold on
            Legendpos = legend([C3,C4],technicalPar.classes(1),technicalPar.classes(2));
            set(Legendpos,'Position',[0.848091556210113 0.925793650793651 0.113690476190476 0.071031746031746],'Units', 'normalized');
        end
        %% Features Histogram
    case 'FeaturesHist'
        %case: loops through all features and creats histogram for each one
        % of them.
        % each figure plot using subplot the same feat for all channles
        hist = cell(1,technicalPar.nclass);                %allocate space
                plotC4 = (size(feat.matrix,2))/2;    %co-responding feature for second electrode

        count =1;
        for i = 1:(size(feat.matrix,2))/2      %loops through all features
            titlCell = cell(1,length(technicalPar.chans)); % co-responding title for all chans for each elec
            figure('Units','normalized','Position',technicalPar.Vis.globalPos);
            set(gca,'YDir','normal','FontSize',15)
            hold on;
            for k = 1:technicalPar.nchans
                subplot(length(technicalPar.chans),1,k)    %subplot the same fearure for each elect
                if((k~=1))      % check if use jump for co-responding feature for diff elec
                    count =count + plotC4;
                else
                    count = i;
                end
                titlCell{k} = char(feat.featLables{count}); % select the co-responded feature name
                for j = 1:technicalPar.nclass
                    %making the hist for each class
                    hist{j} = histogram(feat.matrix(Data.indexes.(technicalPar.classes{j}),count),'nor','pr');
                    hist{j}.BinEdges = technicalPar.Vis.binEdges;
                    hold on;
                    alpha(technicalPar.Vis.trnsp);
                end
                    legend(technicalPar.classes{1},technicalPar.classes{2})
                title(titlCell{k}, 'Units','normalized','Position', technicalPar.Vis.globTtlPos,'FontSize',15);
                ylabel('Probability','FontSize',15);
                if(k == length(technicalPar.chans))
                    xlabel('Standad Deviation','FontSize',15);
                end
            end
            xlim(technicalPar.Vis.xLim);
            hold off;
        end
    case 'PowerSpec'
        %this function compare the chanle for each class for the PWelch results
        figure('Units','normalized','Position',technicalPar.Vis.globalPos);
        %sgtitle('Compare Power Spec by chanle')
        for i =1:length(technicalPar.chansName)
            subplot(technicalPar.nchans,1,i)
            plot(technicalPar.freq,mean(Data.PWelch.(Data.combLables{i}),2),'b')   %left
            hold on
            plot(technicalPar.freq,mean(Data.PWelch.(Data.combLables{i+2}),2),'r') %right
            title(strcat('Power Spectrom diff',{'  '}', (technicalPar.chansName{i})))
            ylabel('Power Spectrom')
            if(i>1)
                xlabel('Frequency[Hz]')
            end
            legend(technicalPar.classes{1},technicalPar.classes{2})
        end
end
end

