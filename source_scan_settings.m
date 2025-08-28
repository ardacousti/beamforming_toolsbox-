function [source,scan] = source_scan_settings(azi_deg_source,inc_deg_source,rs)  
%SOURCE_SCAN_SETTINGS Configure source and scan grid parameters.
%
% Inputs:
%   azi_deg_source  - source azimuth in degrees
%   inc_deg_source  - source inclination in degrees
%   rs              - source–array radius (m)
%
% Outputs:
%   source - struct with acoustic source parameters
%   scan   - struct with scan grid (phi/theta) and flattened vectors
%**************************************************************************
% Author:  Kevin Rouard  |  Date: 22 Aug 2025
%**************************************************************************
% Source parameters
source.cel = 343; % Speed of sound (m/s)
source.azi_rad = azi_deg_source*pi/180; source.inc_rad = inc_deg_source*pi/180;
source.p0 = 2*10^-5; % Reference pressure for 0 dB SPL (Pa)
refdB = 94; % Reference level (dB SPL)
% Source strength such that the SPL at radius rs equals refdB
source.a0 = 10^(refdB/20)*(source.p0)*4*pi*rs;

% Scan grid
scan.phi_lin                = linspace(-180,178,180)*pi/180;
scan.the_lin                = linspace(0,178,90)*pi/180;
scan.Nobs                   = numel(scan.phi_lin)*numel(scan.the_lin);
[th_scan,ph_scan]           = meshgrid(scan.the_lin,scan.phi_lin);
scan.phi_2Dlin              = reshape(ph_scan,1,scan.Nobs);
scan.th_2Dlin               = reshape(th_scan,1,scan.Nobs);
end