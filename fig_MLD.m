function [] = fig_MLD(geoName,kRR_lin,MaxPos,MLD)
%   Plot of Main-to-Side Ratio (MSR) versus nondimensional wavenumber k r_a
%
%**************************************************************************
% Author:  Kevin Rouard  |  Date: 05 March 2023 | revised 26 Aug 2025
%**************************************************************************
%% --- Masks & helpers ---
% Preparation of points to be drawn of error localizing source of 5deg
PosRef(1) = 0; PosRef(2)=90; 
for it = 1:numel(kRR_lin)
    if abs(MaxPos(1,it)-PosRef(1))<5 && abs(MaxPos(2,it)-PosRef(2))<5
        MLDer(1,it)=NaN;
    else
        MLDer(1,it)=1200; %10^6;
    end
end
% Build a 2D “surface” with 3 columns:
MLD2D(1:510,1) = NaN ;
MLD2D(:,2) = MLD ;
MLD2D(:,3) = MLD ;

%% --- Figure & axes formatting ---
fsz = 14 ;
figure('Units','pixels','Position',[10 80 300 500]);
% Surface plot (view set to 2D)
surf(1:size(MLD2D,2),kRR_lin,MLD2D,'EdgeColor','None'); hold on
set(gca, 'YDir','normal')
% Y label
ylabel('$kr_a$', 'Interpreter', 'Latex','FontSize',fsz)
set(gca,'Ytick',0:2:16)
set(gca, 'YTickLabel', 0:2:16,'FontSize',fsz,'FontName','Times New Roman')
grid on
grid minor
% X label
Labll(2:3) = {'',geoName} ;
set(gca,'Xtick',1:size(MLD2D,2))
set(gca, 'XTickLabel', Labll,'FontSize',fsz,'FontName','Times New Roman')
% xtickangle(45)
% Limits and view
ylim([0 16])
xlim([0 size(MLD2D,2)+2])
view(2)
box on
% Colorbar formatting
c=colorbar;
c.Title.String = 'MLD';
c.Title.VerticalAlignment = 'bottom' ;
set(c,'FontSize',fsz,'FontName','Times New Roman');
% Colormap
couleur0 = turbo(12) ;
couleur =  [[1, 1, 1] ;[1, 1, 1] ; couleur0 ; [1 ,1, 1]; [1, 1, 1] ];
colormap(couleur)
clim([-4 4])

kvecpl = repmat(2.5,510,1) ;
% Black markers where error is +/- 5°
plot3(kvecpl,kRR_lin.',MLDer,'k.','linewidth',2,'markersize',8)

end

