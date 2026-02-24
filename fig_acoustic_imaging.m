function [] = fig_acoustic_imaging(FULLIMG2PLOT,phi,the,nametitle)
% Classic figures for acoustic imaging
%
%**************************************************************************
% Author:  Kevin Rouard  |  Date: 12 June 2025
%**************************************************************************
dim=size(FULLIMG2PLOT);
try
    dim4 = dim(4);
catch
    dim4 = 1;
end

try
    dim3 = dim(3);
catch
    dim3 = 1;
end
for ia=1:dim4
    for ib=1:dim3
        figure()
        IMG2PLOT = squeeze(FULLIMG2PLOT(:,:,ia,ib));
        pcolor(phi*180/pi,the*180/pi,IMG2PLOT.');
        set (gca,'YDir','reverse');
        % colormap(flipud(hot))
        colormap(hot_plus_blue(256,'Scale',[-15 5]))
        c=colorbar;
        c.Title.String = 'dB';
        set(c,'FontSize',16);
        hold on
        % clim([(max(max(IMG2PLOT))-15) max(max(IMG2PLOT))])
        clim([-15 5])
        xlabel('$\phi\,$ (degrees)','FontSize',16,'Interp','Latex');
        ylabel('$\theta\,$ (degrees)','FontSize',16,'Interp','Latex');
        set(gca,'FontSize',16);
        shading interp
        axis equal tight
        axis([-179 179 0 179])
        view(2)
        title(nametitle, 'FontSize', 16, 'Interpreter', 'Latex');
    end
end
end

