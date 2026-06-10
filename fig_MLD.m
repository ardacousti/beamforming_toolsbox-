function [] = fig_MLD(geoName,kRR_lin,MaxPos,MLD)
% Plot of Maximum Level Difference (MLD) versus nondimensional wavenumber k r_a
%
%**************************************************************************
% Author:  Kevin Rouard  |  Date: 05 March 2023 | revised 06 june 2026
%**************************************************************************
%% --- Ensure column vectors ---
kRR_lin = kRR_lin(:);
MLD     = MLD(:);

n = numel(kRR_lin);

if numel(MLD) ~= n
    error('MLD and kRR_lin must have the same number of elements.');
end

if size(MaxPos,2) ~= n || size(MaxPos,1) < 2
    error('MaxPos must be a 2 x N array, where N = numel(kRR_lin).');
end

%% --- Masks & helpers ---
% Preparation of points to be drawn for source localization error > 5 deg
PosRef = [0; 90];

MLDer = NaN(n,1);

for it = 1:n
    if abs(MaxPos(1,it) - PosRef(1)) < 5 && abs(MaxPos(2,it) - PosRef(2)) < 5
        MLDer(it) = NaN;
    else
        MLDer(it) = 1200;
    end
end

%% --- Build a 2D surface with 3 columns ---
MLD2D = NaN(n,3);
MLD2D(:,2) = abs(MLD);
MLD2D(:,3) = abs(MLD);

%% --- Figure & axes formatting ---
fsz = 14;

fig = figure('Units','pixels','Position',[80 50 700 200]);

% Fixed positions in pixels
% Increase leftMargin if a longer geoName is still clipped.
leftMargin = 170;
axWidth    = 490;

axPos = [leftMargin 45  axWidth 75];   % [left bottom width height]
cbPos = [leftMargin 150 axWidth 18];   % same left and width as axis

ax = axes(fig, ...
    'Units','pixels', ...
    'Position',axPos);

ax.ActivePositionProperty = 'position';

%% --- Surface plot ---
surf(ax, kRR_lin.', 1:size(MLD2D,2), MLD2D.', ...
    'EdgeColor','none');

hold(ax,'on');

set(ax,'YDir','normal');

xlabel(ax,'$kr_a$', ...
    'Interpreter','latex', ...
    'FontSize',fsz);

set(ax, ...
    'XTick',0:2:16, ...
    'XTickLabel',0:2:16, ...
    'FontSize',fsz, ...
    'FontName','Times New Roman');

grid(ax,'on');
grid(ax,'minor');

%% --- Y label ---
Labll = cell(1,size(MLD2D,2));
Labll(:) = {''};
Labll{3} = char(geoName);

set(ax, ...
    'YTick',1:size(MLD2D,2), ...
    'YTickLabel',Labll, ...
    'FontSize',fsz, ...
    'FontName','Times New Roman');

%% --- Limits and view ---
xlim(ax,[0 16]);
ylim(ax,[0 size(MLD2D,2)+2]);

view(ax,2);
box(ax,'on');

%% --- Colorbar formatting ---
c = colorbar(ax);
c.Location = 'northoutside';

set(c, ...
    'FontSize',fsz, ...
    'FontName','Times New Roman');

% Force colorbar position after creation
c.Units = 'pixels';
c.Position = cbPos;

%% --- Colormap ---
N = 5;
couleur0 = turbo(N*6);
couleur = [flipud(couleur0); repmat([1, 1, 1],2*N,1)];

colormap(ax,couleur);
caxis(ax,[0 4]);

%% --- Text label ---
text(ax, -1.5, 5.8, 'MLD', ...
    'Color','black', ...
    'FontSize',fsz, ...
    'FontName','Times New Roman', ...
    'Clipping','off');

%% --- Markers where localization error is greater than +/- 5 deg ---
kvecpl = repmat(2.5,n,1);

plot3(ax, kRR_lin, kvecpl, MLDer, ...
    'm.', ...
    'LineWidth',2, ...
    'MarkerSize',8);

%% --- Re-force positions after all graphical objects are created ---
drawnow;

ax.Units = 'pixels';
ax.Position = axPos;

c.Units = 'pixels';
c.Position = cbPos;

end
