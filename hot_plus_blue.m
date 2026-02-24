function cmap = hot_plus_blue(N, varargin)
%HOT_PLUS_BLUE  Custom diverging colormap based on HOT with blue extension.
%
%   This colormap combines:
%     - flipud(hot): white → yellow → red → dark tones
%     - fliplr(hot): dark → blue → cyan → white
%
%   The dark/black region of flipud(hot) is truncated to avoid excessively
%   low-value colors. The blue region is extracted from fliplr(hot) and 
%   appended to form a smooth diverging colormap.
%
%   USAGE:
%       cmap = HOT_PLUS_BLUE()                   
%       cmap = HOT_PLUS_BLUE(N)                  
%       cmap = HOT_PLUS_BLUE(N,'Scale',[-20 0])
%
%   INPUTS:
%       N       : Number of colormap levels (default: 512)
%
%   Name-Value Parameters:
%       'Scale' : Two-element vector [lo hi] defining the data range.
%                 The zero-crossing determines the transition between
%                 the red and blue regions.
%                 (default: [-20 0])
%
%   NOTES:
%     - The blue portion is extracted from fliplr(hot), skipping the
%       initial black entries to retain only visible blue tones.
%     - The two parts are interpolated and concatenated to ensure a
%       smooth transition and exactly N levels.
%
%   Author: Kevin ROUARD, 2026 February 

    if nargin < 1 || isempty(N), N = 2*256; end

    % --- Parser simple ---
    p = inputParser;
    addParameter(p,'Scale',[-20 0],@(x) isnumeric(x) && numel(x)==2 && x(1)<x(2));
    parse(p,varargin{:});
    lo = p.Results.Scale(1);
    hi = p.Results.Scale(2);

    % --- Colormaps from hot ---
    whiteredblack   = flipud(hot(N));  
    blackbluewhite  = fliplr(hot(N));   
    bluewhite = blackbluewhite(2:end-10, :); % custom

    xzero = linspace(lo,hi,N);
    [~,idzero] = min(abs(xzero));

    x  = linspace(0,1,size(whiteredblack,1));
    xi = linspace(0,1,idzero);
    cmap1 = [interp1(x,whiteredblack(:,1),xi,'linear')', ...
            interp1(x,whiteredblack(:,2),xi,'linear')', ...
            interp1(x,whiteredblack(:,3),xi,'linear')'];

    x  = linspace(0,1,size(bluewhite,1));
    xi = linspace(0,1,N-idzero);
    cmap2 = [interp1(x,bluewhite(:,1),xi,'linear')', ...
            interp1(x,bluewhite(:,2),xi,'linear')', ...
            interp1(x,bluewhite(:,3),xi,'linear')'];

    cmap = [cmap1; cmap2];
end
