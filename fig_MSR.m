function [] = fig_MSR(geoName,kRR_lin,MSR)
%   Plot of Main-to-Side Ratio (MSR) versus nondimensional wavenumber k r_a
%
%**************************************************************************
% Author:  Kevin Rouard  |  Date: 05 Mars 2023 | revised 26 Aug 2025
%**************************************************************************
%% --- Masks & helpers ---
% Preparation of points to be drawn from the infinite MSR.
MSRInf = MSR;
MSRInf(MSR~=1000) = NaN;

% Filter out non-informative values
MSRfilt = MSR;
MSRfilt(MSR>=100) = NaN; % too large → out of range
MSRfilt(MSR<=0.03) = 0;% too small → non-significant
in = 1; % Remove isolated spikes
while in+2<length(MSRfilt) % Target pattern: [NaN, value, NaN]
    if  sum(( isnan(MSRfilt(in:2+in)) )==( [1; 0; 1] ))==3
        MSRfilt(in+1)=NaN; % If detected, discard the middle value
    end
    in=in+1; % Shift the window by one
end

% Preparation of points to be drawn below 6dB 
MSR6dB = MSRfilt;
MSR6dB(MSR6dB>=6) = NaN;
MSR6dB(MSR6dB<6)  = 1e3;

% Build a 2D “surface” with 3 columns:
MSR2D(1:510,1) = NaN ;
MSR2D(:,2) = MSRfilt ;
MSR2D(:,3) = MSRfilt ;

%% --- Figure & axes formatting ---
fsz = 14 ;
figure('Units','pixels','Position',[630 80 300 500]);
% Surface plot (view set to 2D)
surf(1:size(MSR2D,2),kRR_lin,MSR2D,'EdgeColor','None'); hold on
set(gca, 'YDir','normal')
% Y label
ylabel('$kr_a$', 'Interpreter', 'Latex','FontSize',fsz)
set(gca,'Ytick',0:2:16)
set(gca, 'YTickLabel', 0:2:16,'FontSize',fsz,'FontName','Times New Roman')
grid on
grid minor
% X label
Labll(2:3) = {'',geoName} ;
set(gca,'Xtick',1:size(MSR2D,2))
set(gca, 'XTickLabel', Labll,'FontSize',fsz,'FontName','Times New Roman')
% xtickangle(45)
% Limits and view
ylim([0 16])
xlim([0 size(MSR2D,2)+2])
view(2)
box on
% Colorbar formatting
c=colorbar;
c.Title.String = 'MSR';
c.Title.VerticalAlignment = 'bottom' ;
set(c,'FontSize',fsz,'FontName','Times New Roman');
% Colormap
couleur = parula(48) ;
couleur(end+1,:)=1;
couleur(end+1,:)=1;
couleur(end+1,:)=1;
couleur(end+1,:)=1;
colormap(couleur)
clim([0 26])
% Colorbar ticks every 2 dB
newTicks = 0:2:26;
set(c, 'YTick', newTicks);
tickLabels = cellstr(num2str(newTicks', '%.0f'));
set(c, 'YTickLabel', tickLabels)
kvecpl = repmat(2.5,510,1) ;
% Black markers where MSR == inf
plot3(kvecpl,kRR_lin.',MSRInf,'k.','linewidth',2,'markersize',8)
% Red markers for MSR < 6 dB
plot3(kvecpl,kRR_lin,MSR6dB,'r.','linewidth',2,'markersize',8)

end

