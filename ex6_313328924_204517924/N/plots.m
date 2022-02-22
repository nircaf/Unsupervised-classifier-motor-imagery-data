function plots(type,Data,technicalPar,feat,featMatrix)
%plots Summary: this function receives data and displays it visually,
%according to its properties.
% "type" determines the required data analysis process
% "Data" is a struct which contains data on which this process is performed
% "technicalPar" is a struct which contains all parameters 
% "feat" is a struct which contains features
% "featMatrix" is the matrix which contains the weight of the features

switch type
    %% pca
    case 'pca'
        %in that case: compute pca for each component and attribute and plot pca
        figure('Units','normalized','Position',technicalPar.Vis.PositionOfFig);
        
        comp = pca(featMatrix,'NumComponents',3); %compute pca and choose the 3 components  
                                                  %who holds the greatest variability
        component = (featMatrix * comp)';         %coded matrix
        dot_sz = 11;                              %size of the dots on scatter
        %2 PCA components
        sgtitle("PCA Plots",'FontSize',15);
        subplot(1,2,1)
        scatter(component(1,(Data.indexes.LEFT)),...
            component(2,(Data.indexes.LEFT)),dot_sz,'b','filled');hold on;
        hold on;
        scatter(component(1,(Data.indexes.RIGHT)),...
            component(2,(Data.indexes.RIGHT)),dot_sz,'r','filled')
        title('2 Dimentional PCA','FontSize',15)
        axis square
        xlabel('PC1'); ylabel('PC2');
        set(gca,'YDir','normal','FontSize',15)
        %3 PCA components
        subplot(1,2,2)
        scatter3(component(1,(Data.indexes.LEFT)),...
            component(2,(Data.indexes.LEFT)),component(3,(Data.indexes.LEFT)),dot_sz,'b','filled')
        hold on;
        scatter3(component(1,(Data.indexes.RIGHT)),...
            component(2,(Data.indexes.RIGHT)),component(3,(Data.indexes.RIGHT)),dot_sz,'r','filled')
        title('3 Dimentional PCA','FontSize',15)
        axis square
        xlabel('PC1','FontSize',15); ylabel('PC2','FontSize',15); zlabel('PC3','FontSize',15);
        set(gca,'YDir','normal','FontSize',15)
        leg3 = legend(technicalPar.classes(1),technicalPar.classes(2));
        pos2 = [0.01203125,0.839907407407407,0.062239583333333,0.078148148148148];
        set(leg3,'position',pos2)
        %% Pwelch
    case 'Pwelch'
        %in that case: compute Pwelch over all condition
        figure('Units','normalized','Position',technicalPar.Vis.PositionOfFig);
        for i = 1:length(Data.CaseName) %loop over all conditions:
            subplot(technicalPar.nchans,technicalPar.nClassification,i)
            plot(technicalPar.frequency,mean(Data.PWelch.(Data.CaseName{i}),2))
            title(Data.CaseName{i},'FontSize',15);hold on
            if(mod(i-1,technicalPar.nchans)==0)
                ylabel('power spectral density','FontSize',15)
            end
            if(i>=3) %label only some subplots
                xlabel('Frequency[Hz]','FontSize',15)
            end
        end
        hold off

        %visualize the difference of average intensity of frequencies between
        %classes within each electrode as a function of frequency.
        figure('Units','normalized','Position',technicalPar.Vis.PositionOfFig);
        for i =1:length(technicalPar.chansName) %loop over C3 and C4
            subplot(technicalPar.nchans,1,i)
            plot(technicalPar.frequency,mean(Data.PWelch.(Data.CaseName{i}),2),'r')   %left imagination
            hold on
            plot(technicalPar.frequency,mean(Data.PWelch.(Data.CaseName{i+2}),2),'b') %right imagination
            title(strcat('Power Spectrom diff',{'  '}', (technicalPar.chansName{i})),'FontSize',15)
            ylabel('power spectral density','FontSize',15)
            if(i>1) %label only some subplots
                xlabel('Frequency[Hz]','FontSize',15)
            end
            legend(technicalPar.classes{1},technicalPar.classes{2})
        end
        %% Spectdiff
    case 'SpectDiff'
        %difference of average 
        %intensity of frequencies between classes for each chanle
        figure('Units','normalized','Position',technicalPar.Vis.PositionOfFig);
        
        diff1 = Data.spect.(Data.CaseName{1})-Data.spect.(Data.CaseName{3});
        diff2 = Data.spect.(Data.CaseName{2})-Data.spect.(Data.CaseName{4});
        spectDiffCond = {diff1,diff2};
        diffTitle = {'C3Diff','C4Diff'};
        sgtitle('Spectogram Diff','FontSize',15)
        for i = 1:length(spectDiffCond) %loop over diff1 and diff2
            subplot(1,length(spectDiffCond),i)
            imagesc(technicalPar.time_vector,technicalPar.frequency,spectDiffCond{i})
            set(gca,'YDir','normal','FontSize',15)
            colormap(jet);
            axis square
            title(diffTitle{i})
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
        %in that case: visualize (as a spectogram) the spctral power for each condition
        fig= figure('Units','normalized','Position',technicalPar.Vis.PositionOfFig);
        
        for i = 1:length(Data.CaseName) %loop over all conditions
            subplot(technicalPar.nClassification,technicalPar.nchans,i)
            imagesc(technicalPar.time_vector,technicalPar.frequency,Data.spect.(Data.CaseName{i}))
            set(gca,'YDir','normal','FontSize',15)
            colormap(cool);
            axis square
            title(Data.CaseName{i});
        end
        cb = colorbar;
        cb.Label.String = 'Power diff [dB]';
        cb.FontSize = 15;
        pos = [0.9,0.3,0.02,0.35];
        set(cb,'units','Normalized','position',pos);
        caxis('auto');
            %labels and title for the whole graph
            han=axes(fig,'visible','off'); 
            han.XLabel.Visible='on';
            han.YLabel.Visible='on';
            han.Title.Visible='on';
            xlabel(han,'time [sec]','FontSize',15);
            ylabel(han,'Frequency [Hz]','FontSize',15);
            title(han,'Spectograms','FontSize',17);
        %% dataviz
    case 'dataviz'
        %in that case: visualize the EEG signal of 20 random trails For each class, 
        %each subplot plots the data from both channels(C3 and C4).
        for clss =1: size(struct2table(Data.indexes),2) % runs over classes
            timeVec = [0:length(technicalPar.time_vector)-1]/technicalPar.fs; 
            fig=figure('Units','normalized','Position',technicalPar.Vis.PositionOfFig);
            set(gca,'YDir','normal','FontSize',15)
            randIndex_trails = Data.indexes.(technicalPar.classes{clss})...
                (randperm(length(Data.indexes.(technicalPar.classes{clss})),...
                (technicalPar.Vis.plotPerRow*technicalPar.Vis.plotPerCol)));   %choose rand trails
            sgtitle(technicalPar.classes{clss} + " " + "Imagery Amplitude as a function of time",'FontSize',15)
            for i = 1:length(randIndex_trails) %loop over all selected trails
                subplot(technicalPar.Vis.plotPerCol,technicalPar.Vis.plotPerRow,i)
                C3 = plot(timeVec,Data.all(randIndex_trails(i),:,1),'b');   %signal from c3
                hold on
                C4 = plot(timeVec,Data.all(randIndex_trails(i),:,2),'r','LineStyle','-.');   %signal from c4
                ylim([-15,15])
                
            end
            %legend:
            Legendpos = legend('C3','C4');
            set(Legendpos,'Position',[0.848091556210113 0.925793650793651 0.113690476190476 0.071031746031746],'Units', 'normalized');
            %labels for the whole graph
            han=axes(fig,'visible','off'); 
            han.XLabel.Visible='on';
            han.YLabel.Visible='on';
            han.Title.Visible='on';
            xlabel(han,'time [sec]','FontSize',15);
            ylabel(han,'Amplitude[\muV]','FontSize',15);
            
        end
        %% Features Histogram
    case 'FeaturesHist'
        %in that case: create histogram for each feature
        hist = cell(1,technicalPar.nClassification); %creat cell array which will contain the histogram data
        plotC4 = (size(feat.matrix,2))/2;   %co-responding feature for second electrode

        count =1;
        for i = 1:(size(feat.matrix,2))/2   %compute over all features
            titlCell = cell(1,length(technicalPar.Channels)); %maching title for the combination
            figure('Units','normalized','Position',technicalPar.Vis.PositionOfFig);
            set(gca,'YDir','normal','FontSize',15)
            hold on;
            for k = 1:technicalPar.nchans %loop over C3 and C4
                subplot(length(technicalPar.Channels),1,k) 
                if((k~=1))  %check if use jump for co-responding feature for diff elec
                    count =count + plotC4;
                else
                    count = i;
                end
                titlCell{k} = char(feat.featLables{count}); %suitable feature name
                for j = 1:technicalPar.nClassification %loop over left and right
                    %make histogram for each class
                    hist{j} = histogram(feat.matrix(Data.indexes.(technicalPar.classes{j}),count),'nor','pr');
                    hist{j}.BinEdges = technicalPar.Vis.binEdges;
                    hold on;
                    alpha(technicalPar.Vis.trnsp);
                end
                    legend(technicalPar.classes{1},technicalPar.classes{2})
                title(titlCell{k}, 'Units','normalized','Position', technicalPar.Vis.PositionOfTitle,'FontSize',15);
                ylabel('Probability','FontSize',15);
                if(k == length(technicalPar.Channels))
                    xlabel('Standad Deviation','FontSize',15);
                end
            end
            xlim(technicalPar.Vis.xLim);
            hold off;
        end
    case 'PowerSpec'
        %in that case: compute the difference of the average frequency
        %intensity between classes:
        figure('Units','normalized','Position',technicalPar.Vis.PositionOfFig);
        for i =1:length(technicalPar.chansName) %loop over C3 and C4
            subplot(technicalPar.nchans,1,i)
            plot(technicalPar.frequency,mean(Data.PWelch.(Data.CaseName{i}),2),'b')   %left
            hold on
            plot(technicalPar.frequency,mean(Data.PWelch.(Data.CaseName{i+2}),2),'r') %right
            title(strcat('Power Spectrom diff',{'  '}', (technicalPar.chansName{i})))
            ylabel('Power Spectrom')
            if(i>1)
                %lable only some subplots
                xlabel('Frequency[Hz]')
            end
            legend(technicalPar.classes{1},technicalPar.classes{2})
        end
end
end

