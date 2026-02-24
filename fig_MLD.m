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
MLD2D(:,2) = abs(MLD) ;
MLD2D(:,3) = abs(MLD) ;

%% --- Figure & axes formatting ---
fsz = 14 ;
figure('Units','pixels','Position',[80 50 700 200]);
% Surface plot (view set to 2D)
surf(kRR_lin.',1:size(MLD2D,2).',MLD2D.','EdgeColor','None'); hold on
set(gca, 'YDir','normal')
% X label
xlabel('$kr_a$', 'Interpreter', 'Latex','FontSize',fsz)
set(gca,'Xtick',0:2:16)
set(gca, 'XTickLabel', 0:2:16,'FontSize',fsz,'FontName','Times New Roman')
grid on
grid minor
% Y label
Labll(2:3) = {'',geoName} ;
set(gca,'Ytick',1:size(MLD2D,2))
set(gca, 'YTickLabel', Labll,'FontSize',fsz,'FontName','Times New Roman')
% xtickangle(45)
% Limits and view
xlim([0 16])
ylim([0 size(MLD2D,2)+2])
view(2)
box on
% Colorbar formatting
c=colorbar;
c.Location = 'northoutside' ;
text(-1.5,5.8,'MLD','Color','black','FontSize',fsz,'FontName','Times New Roman')
set(c,'FontSize',fsz,'FontName','Times New Roman');
% Colormap
N = 5; % Color scale density with 0.5 dB steps
couleur0 = turbo(N*6);
couleur =  [flipud(couleur0); repmat([1 ,1, 1],2*N,1) ];
colormap(couleur)
clim([0 4])

kvecpl = repmat(2.5,510,1) ;
% Black markers where error is +/- 5°
plot3(kRR_lin,kvecpl.'',MLDer.','m.','linewidth',2,'markersize',8)

end

