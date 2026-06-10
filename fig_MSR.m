function [] = fig_MSR(geoName,kRR_lin,MSR)
%   Plot of Main-to-Side Ratio (MSR) versus nondimensional wavenumber k r_a
%
%**************************************************************************
% Author:  Kevin Rouard  |  Date: 05 Mars 2023 
%**************************************************************************
% Ensure column vectors
MSR = MSR(:);
kRR_lin = kRR_lin(:);

n = numel(MSR);

if numel(kRR_lin) ~= n
    error('MSR and kRR_lin must have the same number of elements.');
end

%% --- Data filtering ---
MSRInf = MSR;
MSRInf(MSR < 500) = NaN;

MSRfilt = MSR;
MSRfilt(MSR >= 100) = NaN;   % too large → out of range
MSRfilt(MSR <= 0.03) = 0;    % too small → non-significant

% Remove isolated spikes: [NaN, value, NaN]
for in = 1:n-2
    pattern = isnan(MSRfilt(in:in+2));
    if isequal(pattern, [true; false; true])
        MSRfilt(in+1) = NaN;
    end
end

% Points below 6 dB
MSR6dB = MSRfilt;
MSR6dB(MSR6dB >= 6) = NaN;
MSR6dB(MSR6dB < 6) = 1e3;

%% --- Build 2D surface ---
MSR2D = NaN(n,3);
MSR2D(:,2) = MSRfilt;
MSR2D(:,3) = MSRfilt;

%% --- Figure & axes formatting ---
fsz = 14;

fig = figure('Units','pixels','Position',[80 300 700 200]);

% Fixed positions in pixels
leftMargin = 170;      % increase this if the left label is still clipped
axWidth    = 490;
axPos = [leftMargin 45 490 75];     % [left bottom width height]
cbPos = [leftMargin 150 490 18];    % same left and width as axis

ax = axes(fig, 'Units','pixels', 'Position', axPos);
ax.ActivePositionProperty = 'position';

surf(ax, kRR_lin.', 1:size(MSR2D,2), MSR2D.', ...
    'EdgeColor','none');

hold(ax, 'on');

set(ax, 'YDir','normal');
view(ax, 2);
box(ax, 'on');
grid(ax, 'on');
grid(ax, 'minor');

xlabel(ax, '$kr_a$', ...
    'Interpreter','latex', ...
    'FontSize',fsz);

set(ax, ...
    'XTick',0:2:16, ...
    'XTickLabel',0:2:16, ...
    'FontSize',fsz, ...
    'FontName','Times New Roman');

xlim(ax, [0 16]);
ylim(ax, [0 size(MSR2D,2)+2]);

% Y tick labels
Labll = cell(1, size(MSR2D,2));
Labll(:) = {''};
Labll{2} = '';
Labll{3} = char(geoName);

set(ax, ...
    'YTick',1:size(MSR2D,2), ...
    'YTickLabel',Labll, ...
    'FontSize',fsz, ...
    'FontName','Times New Roman');

%% --- Colorbar formatting ---
c = colorbar(ax);
c.Location = 'northoutside';
c.Units = 'pixels';
c.Position = cbPos;

set(c, ...
    'FontSize',fsz, ...
    'FontName','Times New Roman');

clim(ax, [0 26]);

newTicks = 0:2:26;
c.Ticks = newTicks;
c.TickLabels = cellstr(num2str(newTicks.', '%.0f'));

%% --- Colormap ---
couleur = turbo(48);
couleur(end+1:end+4,:) = 1;
colormap(ax, couleur);

%% --- Text label ---
text(ax, -1.5, 5.8, 'MSR', ...
    'Color','black', ...
    'FontSize',fsz, ...
    'FontName','Times New Roman', ...
    'Clipping','off');

%% --- Markers ---
kvecpl = repmat(2.5, n, 1);

plot3(ax, kRR_lin, kvecpl, MSRInf, ...
    'k.', ...
    'LineWidth',2, ...
    'MarkerSize',8);

plot3(ax, kRR_lin, kvecpl, MSR6dB, ...
    'r.', ...
    'LineWidth',2, ...
    'MarkerSize',8);

% Re-force positions after all objects are created
drawnow;
ax.Units = 'pixels';
ax.Position = axPos;
c.Units = 'pixels';
c.Position = cbPos;

end
