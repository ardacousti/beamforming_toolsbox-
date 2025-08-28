function [] = fig_distribMSR(geoName,Q,IMG2PLOT,kr_init)
% Plot of the MSR distribution for a given geometry.
%
%**************************************************************************
% Author:  Kevin Rouard  |  Date: 05 Mars 2023 | revised 27 Aug 2025
%**************************************************************************
%% Compute MSR
[~,~,MSR]         =   get_lobe_level(IMG2PLOT);
MSR = round(MSR,1);

% Select the kr window [2, 8]. Indices closest to 2 and 8 in kr_init
[~,start_kr] = min(abs(2-kr_init)) ;
[~,end_kr]   = min(abs(8-kr_init)) ;
% Trapezoidal weigth (in case of non linear kr)
Nkr=(end_kr-start_kr+1);
dx = diff(kr_init(start_kr:end_kr));                    % length Nkr-1
kRR_wgth        = zeros(1, Nkr);
kRR_wgth(1)     = dx(1);            % forward half-step at left end
kRR_wgth(2:end-1) = (dx(1:end-1)+dx(2:end))/2;  % centered
kRR_wgth(end)   = dx(end);          % backward half-step at right end

% Weighted mean
[~,M_MSR] = var(MSR(start_kr:end_kr),kRR_wgth,1);

%% Prepare figure
% Liste array
Liste_Array ={'t-design' ; 'Covering' ; 'Maximal Volume' ; 'Minimum Energy' ;...
    'Packing' ; 'Spiral' ; 'Fibonacci' ; 'L-design' ; ...
    'Lebedev' ; 'Maximum Determinant' ; 'BetK' ; 'Fliege' ; 'Equi-angle' ; 'Gauss-Legendre' ;...
    'Min. Pot.' ; 'Efficient t-design'};
karray = find(strcmpi(Liste_Array, geoName), 1);

% Display styles
marker_styles = {'o', '+', 's', 'd', 'p', 'h', '*', 'x'}; % '^', 'v', '>', '<'
marker_idx = mod(karray - 2, length(marker_styles)) + 1;

% Colors (darker/lighter)
color_styles_darker = repmat([0 0 0], 16, 1);   % black
color_styles_lighter = [1 1 101/255;            % yellow
    1 221/255 219/255;                          % soft pink
    197/255 181/255 1;                          % purple
    197/255 1 214/255;                          % mint
    1 1 197/255;                                % beige
    139/255 205/255 255/255;                    % blue
    1 139/255 139/255;                          % red
    161/255 195/255 185/255;                    % blue rock
    217/255 244/255 150/255;                    % olive
    1 197/255 139/255;                          % red orange
    109/255 243/255 247/255;                    % sky
    250/255 184/255 247/255;                    % hot pink
    217/255 217/255 217/255;                    % grey
    152/255 1 101/255;                          % green
    1 215/255 101/255;                          % orange
    197/255 216/255 1];                         % blue grey

color_idx = mod(karray, length(color_styles_darker))+1;

% Data for the boxplot
MSR_2_box = MSR(start_kr:end_kr);
[minval, maxval] = minmax(MSR_2_box,'all') ;

% Tight outlier detection
ol =  isoutlier(MSR_2_box,"percentiles",[0.14 99.86]);

%% Figure and background rectangles
figure('Units','pixels','Position',[940 80 300 500])

%  Box polyline (closed with 5 vertices)
Ybx = [minval, maxval, maxval, minval, minval];
x0  = 1; w = 0.25;
Xbx = [x0-w, x0-w, x0+w, x0+w, x0-w];

% Filled rectangle for min/max area
if ~isnan(minval)
    rectangle('position', [1-w, minval, 2*w, maxval-minval],...
        'FaceColor', color_styles_lighter(color_idx,:),...
        'EdgeColor', [0 0 0], 'LineWidth', 1.5)
end
hold on

% Boxplot
bc = boxplot2(MSR_2_box);

% Visual styling of all boxplot components
set(bc.out,'marker', '.','HandleVisibility', 'off');
set([bc.lwhis bc.uwhis],'linestyle','-.','LineWidth',1,'color','k','HandleVisibility', 'off');
set([bc.ladj bc.uadj],'LineWidth',1,'color','k','HandleVisibility', 'off');
set(bc.box,'linestyle','-','LineWidth',1.5,'color','k','HandleVisibility', 'off');
set(bc.med,'linestyle','none','color','none','HandleVisibility', 'off');
set(bc.box,'YData',Ybx,'XData', Xbx);
set(bc.med,'XData',1);
set([bc.uwhis bc.uadj bc.lwhis bc.ladj],'Color','none');
Nbx = numel(MSR_2_box(ol)); % Remove outlier points
if Nbx == 0
    rdom = [];
elseif mod(Nbx,2) == 0
    rdom = [1-rand(1,Nbx/2)./5, 1+rand(1,Nbx/2)./5];
else
    rdom = [1-rand(1,(Nbx-1)/2)./5, 1, 1+rand(1,(Nbx-1)/2)./5];
end
if ~isempty(rdom)
    set(bc.out,'YData',MSR_2_box(ol,1),'XData',rdom)
end
hold on

% Marker and reference threshold
plot(1,M_MSR,'LineStyle','none','Marker',marker_styles(marker_idx),...
    'MarkerSize',8,'LineWidth',1.2,'Color',color_styles_darker(color_idx,:),...
    'HandleVisibility', 'off')
yline(6,'-.','LineWidth',1,'Color',	[0.5 0.5 0.5])
hold off

% Ylabels
fsz    = 13;
set(gca, 'YDir','normal')
ylabel('MSR','FontSize',fsz,'FontName','Times New Roman')
set(gca,'Ytick',0:2:24)
set(gca, 'YTickLabel', 0:2:24,'FontSize',fsz,'FontName','Times New Roman')
grid on
grid minor

% X: show Q at x=1
Labll = num2str(Q) ;
set(gca,'Xtick',1)
set(gca, 'XTickLabel', Labll,'FontSize',fsz,'FontName','Times New Roman')
xlabel('Q','FontSize',fsz,'FontName','Times New Roman')
% xtickangle(45)

% Title
title('$kr=[2-8]$','Interpreter','Latex')

% Axes
ylim([0 24])
xlim([0 2])
box on
end

