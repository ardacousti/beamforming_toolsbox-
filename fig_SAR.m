function [] = fig_SAR(geoName,kRR_lin,MaxPos,SAR)
%   Plot of Source-to-Ambient Ratio (SAR) versus nondimensional wavenumber k r_a
%
%**************************************************************************
% Author:  Kevin Rouard  |  Date: 05 Mars 2023 
%**************************************************************************

%% --- Ensure column vectors ---
kRR_lin = kRR_lin(:);
SAR     = SAR(:);

n = numel(kRR_lin);

if numel(SAR) ~= n
    error('SAR and kRR_lin must have the same number of elements.');
end

if size(MaxPos,2) ~= n || size(MaxPos,1) < 2
    error('MaxPos must be a 2 x N array, where N = numel(kRR_lin).');
end

%% --- Masks & helpers ---
% Preparation of points to be drawn for source localization error > 5 deg
PosRef = [0; 90];

SARer = NaN(n,1);

for it = 1:n
    if abs(MaxPos(1,it) - PosRef(1)) < 5 && abs(MaxPos(2,it) - PosRef(2)) < 5
        SARer(it) = NaN;
    else
        SARer(it) = 1200;
    end
end

%% --- Build a 2D surface with 3 columns ---
SAR2D = NaN(n,3);
SAR2D(:,2) = SAR;
SAR2D(:,3) = SAR;

%% --- Figure & axes formatting ---
fsz = 14;

fig = figure('Units','pixels','Position',[80 150 700 200]);

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
surf(ax, kRR_lin.', 1:size(SAR2D,2), SAR2D.', ...
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
Labll = cell(1,size(SAR2D,2));
Labll(:) = {''};
Labll{3} = char(geoName);

set(ax, ...
    'YTick',1:size(SAR2D,2), ...
    'YTickLabel',Labll, ...
    'FontSize',fsz, ...
    'FontName','Times New Roman');

%% --- Limits and view ---
xlim(ax,[0 16]);
ylim(ax,[0 size(SAR2D,2)+2]);

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
couleur = flipud(turbo(60));
couleur(end+1:end+4,:) = 1;

colormap(ax,couleur);
caxis(ax,[0 32]);

%% --- Colorbar ticks ---
newTicks = 0:3:30;
c.Ticks = newTicks;
c.TickLabels = cellstr(num2str(newTicks.', '%.0f'));

%% --- Text label ---
text(ax, -1.0, 5.7, '$\overline{\Omega}$', ...
    'Color','black', ...
    'FontSize',fsz, ...
    'FontName','Times New Roman', ...
    'Interpreter','latex', ...
    'Clipping','off');

%% --- Markers where localization error is greater than +/- 5 deg ---
kvecpl = repmat(2.5,n,1);

plot3(ax, kRR_lin, kvecpl, SARer, ...
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
