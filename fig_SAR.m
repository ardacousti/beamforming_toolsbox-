function [] = fig_SAR(geoName,kRR_lin,MaxPos,SAR)
%   Plot of Main-to-Side Ratio (MSR) versus nondimensional wavenumber k r_a
%
%**************************************************************************
% Author:  Kevin Rouard  |  Date: 05 Mars 2023 | revised 26 Aug 2025
%**************************************************************************
%% --- Masks & helpers ---
% Preparation of points to be drawn of error localizing source of 5deg
PosRef(1) = 0; PosRef(2)=90;
for it = 1:numel(kRR_lin)
    if abs(MaxPos(1,it)-PosRef(1))<5 && abs(MaxPos(2,it)-PosRef(2))<5
        SARer(1,it)=NaN;
    else
        SARer(1,it)=1200; %10^6;
    end
end

% Build a 2D “surface” with 3 columns:
SAR2D(1:510,1) = NaN ;
SAR2D(:,2) = SAR ;
SAR2D(:,3) = SAR ;

%% --- Figure & axes formatting ---
fsz = 14 ;
figure('Units','pixels','Position',[320 80 300 500]);
% Surface plot (view set to 2D)
surf(1:size(SAR2D,2),kRR_lin,SAR2D,'EdgeColor','None'); hold on
set(gca, 'YDir','normal')
% Y label
ylabel('$kr_a$', 'Interpreter', 'Latex','FontSize',fsz)
set(gca,'Ytick',0:2:16)
set(gca, 'YTickLabel', 0:2:16,'FontSize',fsz,'FontName','Times New Roman')
grid on
grid minor
% X label
Labll(2:3) = {'',geoName} ;
set(gca,'Xtick',1:size(SAR2D,2))
set(gca, 'XTickLabel', Labll,'FontSize',fsz,'FontName','Times New Roman')
% xtickangle(45)
% Limits and view
ylim([0 16])
xlim([0 size(SAR2D,2)+2])
view(2)
box on
% Colorbar formatting
c=colorbar;
c.Title.String = '$\overline{\Omega}$';
c.Title.Interpreter = 'latex' ;
c.Title.VerticalAlignment = 'bottom' ;
set(c,'FontSize',fsz,'FontName','Times New Roman');
% Colormap
couleur = fliplr(parula(60)) ;
couleur(end+1,:)=1;
couleur(end+1,:)=1;
couleur(end+1,:)=1;
couleur(end+1,:)=1;
colormap(couleur)
clim([0 32])
% Colorbar ticks every 2 dB
newTicks = 0:3:30;
set(c, 'YTick', newTicks);
tickLabels = cellstr(num2str(newTicks', '%.0f'));
set(c, 'YTickLabel', tickLabels)
kvecpl = repmat(2.5,510,1) ;
% Black markers where error is +/- 5°
plot3(kvecpl,kRR_lin.',SARer,'k.','linewidth',2,'markersize',8)

end

