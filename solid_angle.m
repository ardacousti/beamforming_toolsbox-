function omega = solid_angle(az_p,el_p,idx)
%   Total solid angle (Ω) 
%
%   Inputs:
%       az_p    Azimuth sampling points (degrees). Vector of scanning grid
%               [-180, 180] or [0, 360].
%       el_p    Elevation sampling points (degrees). Vector of scanning grid
%               [-90, 90] or [0, 180].
%       idx     Linear indices (column-major) of points to EXCLUDE
%               from the integration (e.g., below a threshold).
%
%   Output:
%       omega   Total solid angle (steradians) of the unmasked region.
%
%   Method:
%       - Build an elevation×azimuth grid and mask out selected cells.
%       - Ensure the elevation vector is expressed from 0° to 180°.
%       - Pad azimuth/elevation with “ghost” samples at both ends to
%         compute centered cell widths:
%             Δφ  ≈ (1/2)·(φ_{i+1} − φ_{i−1})
%             Δcosθ ≈ −cos(θ_{j+½}) + cos(θ_{j−½})
%       - Accumulate Ω ≈ Σ Δφ · Δcosθ over all unmasked cells.
%
%   Notes:
%       - If el_p starts at −90°, it is shifted to [0, 180] internally.
%       - If el_p does not start at 0° after remapping, an error is raised.
%       - az_p/el_p are assumed to be in degrees.
%
%   Rouard, K., St-Jacques, J., Sgard, F., ..., Padois, T. (2023). 
%   A criterion based on the calculation of a solid angle to assess 
%   the quality of acoustic images obtained with a SMA. 
%   journal of the canadian acoustical association, 51 (3), 179.
%
%**************************************************************************
% Author:   K. ROUARD
% Created:  17/06/2022
% Modified: 02/06/2023, 11/07/2025 
%**************************************************************************
% Build elevation×azimuth grid; mask selected cells
[grid,~] = meshgrid(az_p,el_p);
grid(idx) = NaN;
% Normalize elevation sampling to [0, 180]
if el_p(1) == -90
    el_p = el_p + 90;
elseif el_p(1) ~= 0
    error('el_p must start with 0°')
end
% Initialize
omega = 0;
% Pad azimuth/elevation for centered-difference cell widths
% Add a trailing azimuth sample (wrap) and a leading one (extrapolated step)
az_p(:,length(az_p)+1) = -az_p(:,1);    % wrap end
az_p = [(az_p(end-1)-az_p(end) + az_p(1))  az_p];  % extrapolate begin

if el_p(:,end) ~= 180 % if last is not 180°, south pole is missed, then add "double-step semi angle" at end
    el_p(:,length(el_p)+1) = el_p(end) + 2*(180-el_p(end));
else % if already at 180°, add a "zero step angle" at begin for symetry
    el_p(:,length(el_p)+1) = 180;
end
el_p = [0 el_p]; % prepend 0° for symmetry
% Loop over interior cells
for ii = 2:length(az_p)-1
    for jj = 2:length(el_p)-1
        % Skip masked cells
        Is_nan = isnan(grid(jj-1,ii-1))  ;
        if Is_nan == 0
            % Centered azimuth width Δφ (radians)
            array_delta_phi         =  deg2rad( (1/2)*(az_p(ii+1) - az_p(ii-1)) ) ;
            % Centered Δcosθ using mid-elevation samples
            array_delta_cos_theta   =    (-cos(  deg2rad( ((el_p(jj+1)-el_p(jj))/2)+el_p(jj) )) ...
                + cos( deg2rad( ((el_p(jj-1)-el_p(jj))/2) + el_p(jj) ) ) ) ;
            % Cell solid-angle contribution
            pre_omega =   array_delta_phi * array_delta_cos_theta ;
            % Accumulate
            omega = omega + pre_omega ;
        else
            continue
        end
    end
end