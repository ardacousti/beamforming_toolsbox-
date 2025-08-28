function [] = fig_criteria(geoName,IMG2PLOT,kRR_lin,phi,the,maxPos)
% Compute the criteria to plot it 
%
%**************************************************************************
% Author:  Kevin Rouard  |  Date: 05 Mars 2023 | revised 26 Aug 2025
%**************************************************************************

threshold = -3;
SAR = get_solid_angle_ratio(phi,the,IMG2PLOT,threshold);
[MLD,~,MSR] = get_lobe_level(IMG2PLOT);

crit = round([MLD, SAR, MSR],1) ;

fig_MLD(geoName,kRR_lin,maxPos,crit(:,1))
fig_SAR(geoName,kRR_lin,maxPos,crit(:,2))
fig_MSR(geoName,kRR_lin,crit(:,3))

end

