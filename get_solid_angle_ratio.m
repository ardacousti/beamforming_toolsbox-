function solid_angle_ratio = get_solid_angle_ratio(phi,the,PREMAP2PLOT,threshold,refvalue)
%   Solid-angle ratio of the region above a dB threshold in 2D scan maps
%
%   Inputs:
%       phi           Azimuth grid (rad)
%       the           Inclination grid (rad)
%       PREMAP2PLOT   Nphi×Nthe×L1×L2 array of maps in dB.
%                     Dims 1–2 are angular (φ, θ). Dims 3–4 are extra indices
%                     (e.g., frequency, radius, algorithm).
%       threshold     Relative threshold (dB).
%                     Typical values are negative, e.g., -3, -6, -10.
%       refvalue      (optional) Reference level in dB for each map.
%                     If omitted, is the maximum value for each map.
%
%   Output:
%       solid_angle_ratio   L1×L2 array. For each map, returns:
%                           100 * Ω / (4π)   in percent,
%                           where Ω is the solid angle (sr) of the region
%                           with map ≥ (refvalue + threshold).
%
%   Notes:
%       - This function calls `solid_angle(phi_deg, the_deg, idx)` which must be
%         available on the path. `idx` is the set of linear indices of the selected
%         pixels (in column-major MATLAB order) in the Nphi×Nthe map.
%       - If no pixel satisfies the threshold, the ratio is 0.
%       - dB is assumed to be on a **power** scale (10·log10).
%
%   See also:
%       solid_angle, meshgrid, rad2deg
%
%**************************************************************************
% Authors:  K. Rouard (Jun 2023, Apr 2024)
%**************************************************************************
[~,~,L_1D,L_2D] = size(PREMAP2PLOT) ;
solid_angle_ratio = zeros(L_1D,L_2D);
for k2D= 1:L_2D
    for k1D = 1:L_1D
        MAP2PLOT = PREMAP2PLOT(:,:,k1D,k2D); 
        if nargin < 5
            refvalue = max(max(MAP2PLOT)) ;
        end
        idx = find(MAP2PLOT.'< threshold+refvalue ); % find position under the threshold
        solid_angle_ratio(k1D,k2D) = 100*solid_angle(rad2deg(phi),rad2deg(the),idx)./(4*pi);
    end
end
end