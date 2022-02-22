function [] = plotlabels(titlestr,volt)
%PLOTLABELS Plot x y axis labels, legend and gets title and presents it

%Detailed explanation goes here
% titlestr is titile string to present
% aif is bool whether we are plotting aif or EC and EO
set(gca,'FontSize',15);
try if ~isempty(volt)
             xlabel('Time[s]','FontSize',15);
     ylabel('Volt[V]','FontSize',15);
          legend('C3','C4','Location','eastoutside');

    end
catch
                    xlabel('Frequenct[Hz]','FontSize',15);
     ylabel('Power','FontSize',15);
end
     title(titlestr,'FontSize',15);


     
end

%      zlabel('PC_3','FontSize',15);

