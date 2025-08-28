function Out = algo_CBF_k(C1,k,rqrl,varargin)
%   Conventional Beamforming (CBF)
%
%   Inputs:
%       C1      Q×Q cross-spectral matrix (CSM)
%       k       Wavenumber (rad/m)
%       rqrl    Q×L distances r_{q,l} from microphone q to look point l (m)
%       varargin
%               {1} hType  Integer selector of steering vector formulation:
%                           1..10 (see switch below). Default: 0 (fallback)
%
%   Output:
%       Out     L×1 beamformer output power for each look point
%
%   Notes:
%       - Steering vector g is based on the free-field Green’s function:
%           g(q,l) = exp(-j k r_{q,l}) / (4π r_{q,l})
%       - This function computes W (Q×L) according to hType, then evaluates
%           Out(l) = w_l^H C1 w_l   with w_l = W(:,l).
%       - Dimensions are checked for basic consistency.
%
%   Reference:
%       Sarradj, Ennes (2012). “Three-Dimensional Acoustic Source Mapping
%       with Different Beamforming Steering Vector Formulations.” Advances in
%       Acoustics and Vibration, 2012, 1–12.
%
%**************************************************************************
% Author:           Kevin Rouard (mod. from T. Padois codes)
% Version:          v0
% Date:             25 Jan 2023
%**************************************************************************
% Sizes
[Q,L]= size(rqrl) ;
hType = 0; % default
if numel(varargin) >= 1 && ~isempty(varargin{1}), hType  = varargin{1}; end
% --- Steering vector
% Free-field Green’s function
r0  = 1;           % scaling (kept for clarity)
rt0 = 0;           % reference
rt  = (4*pi) * rqrl;                               % 4 π r
expTerm = exp(-1i * k .* (rqrl - rt0));            % e^{-j k r}
g = (r0 ./ rt) .* expTerm;                         % Q×L
% --- Weights W according to hType
W = zeros(Q,L); 
switch  hType
    %%%%%%%%%%%%    #   i   #   %%%%%%%%%%%%%%%%%%%
    case 1 % "formula"
        for q=1:Q 
            W(q,:) = 1./Q .* g(q,:) ./ abs(g(q,:)); % Add rt(q,:) to correct the level
        end
    case 2 % "derived"
        W = 1./Q .*exp(-1i*k*rqrl) ; % Add rt to correct the level
    %%%%%%%%%%%%    #   ii  #   %%%%%%%%%%%%%%%%%%%
    case 3 % "formula"
        for q=1:Q
            W(q,:) = 1/Q * g(q,:) ./ (g(q,:).*conj(g(q,:)));
        end
    case 4 % "derived"
        W = 1/Q .*exp(-1i*k*rqrl) ./ ( r0./rt ) ;
    %%%%%%%%%%%%    #  iii  #   %%%%%%%%%%%%%%%%%%%
    case 5 % "formula"
        en = dot(  g , g , 1 ) ;  % 1×L, sum_q conj(g).*g = ||g||^2
        en = mean(en) ;           % same values
        W = g ./ en;
    case 6 % "derived"
        W =  exp(-1i*k*rqrl) ./ ( r0*rt.*sum(1./rt.^2,1)) ;
    %%%%%%%%%%%% # pseudo-inverse # %%%%%%%%%%%%%%%
    case 7
        for l=1:L
            W(:,l) = pinv(g(:,l))' ; 
        end
    %%%%%%%%%%%%    #   iv  #   %%%%%%%%%%%%%%%%%%%
    case 8 % "formula"
        en =  dot(  g , g , 1 ) ; % 1×L, sum_q conj(g).*g = ||g||^2
        en = mean(en) ; % same values
        W = 1./sqrt(Q) .* g ./ sqrt(en); % Add rt(q,:) to correct the level
    case 9 % "derived"
        W =  1.*exp(-1i*k*rqrl) ./ ( rt.*sqrt(Q*sum(1./rt.^2,1)) ); % Add rt to correct the level
    %%%%%%%%%%%%    #   iv bis  #   %%%%%%%%%%%%%%%
    case 10
        en = sum(abs(g).^2,1);
        en = repmat(en,Q,1);
        W = 1./sqrt(Q).*g./sqrt(en); % Add rt to correct the level
    %%%%%%%%%%%%%%   # default #   %%%%%%%%%%%%%%%%
    otherwise
        W = 1/Q * (4*pi*rqrl).*exp(-1i*k*rqrl) ; % [L x Q]
end
% --- Beamformer output
Wh = W';
% output CBF
A = dot(  Wh * C1, Wh , 2 ) ;
Out = A ;
end

