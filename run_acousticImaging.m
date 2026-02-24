function [] = run_acousticImaging(param,geoName,sphType,algoType,acousticImages,centeredSource,varargin)
%   Pilot routine: geometry, source/scan setup, algorithm loop, and imaging
%
%   Inputs:
%       param           Struct with fields:
%                       .Q (int)   number of microphones
%                       .ra (m)    array radius
%                       .rs (m)    source/scan radius
%                       .phi (deg) source azimuth (if not centered)
%                       .theta(deg)source inclination (if not centered)
%       geoName         Char/str  geometry identifier (e.g., 't-design')
%       sphType         'open' | 'rigid'  (spherical wave model)
%       algoType        'CBF'  | 'SHB'
%       acousticImages  'Y'/'N'  display acoustic images
%       centeredSource  'Y'/'N'  center source at (az=0, inc=90) and rotate array
%       varargin :  'freq', [x x]   a single frequency or a frequency vector
%                   'Nmax', [x x]   a single Nmax value or a vector
%                   'N', [x x]      a single N value or a vector
%
%   Notes:
%       - Angles use convention φ (azimuth), θ (inclination from +z).
%       - Uses octavebandtradfun for frequency vector (octave here).
%       - Distance matrix rqrl is computed (Q×L).
%
%   See also:
%       source_scan_settings, mysph2cart, mycart2sph, Function_CBF_k, Function_SHBaq,
%       classic_acoustic_imaging
%
%**************************************************************************
% Author:           Kevin Rouard
% Date:             23 August 2025
%**************************************************************************
if any(strcmpi(acousticImages,'Y'))
    return
end
isFreqVec = @(x) isnumeric(x) && isvector(x) && ~isempty(x) && all(isfinite(x)) && all(x>0);
isPosInt  = @(x) isnumeric(x) && isscalar(x) && isfinite(x) && (x>0) && (x==fix(x));
isNarg = @(x) (ischar(x) || isstring(x) || isnumeric(x));
p = inputParser;
p.FunctionName  = 'run_acousticImaging';
%% Default parameters
defaultFreq = octavebandtradfun(250,8000,'one'); % vector of frequencies (Hz)
defaultNmax = floor(sqrt(param.Q)) - 1 ; % standardization

addParameter(p,'freq',defaultFreq,isFreqVec);
addParameter(p,'Nmax',defaultNmax,isPosInt);
addParameter(p,'N','auto',isNarg);
parse(p,varargin{:});

freq    = p.Results.freq(:).';
Nmax = p.Results.Nmax;
Nopt    = p.Results.N;

cType = 5; % CBF formulation iii
dnType= 1; % SHB gain (MD)

%% Microphone positions for a given geometry
if any(strcmpi(centeredSource,'Y'))
    [~, mic0, aq, ~]=get_geo_positions(geoName,param.Q,param.ra);
    mic1=RotationMatrix(mic0,0,0,-param.phi) ;
    mic=RotationMatrix(mic1,0,-(param.theta-90),0) ;
    [source,scan]=source_scan_settings(0,90,param.rs);
else
    [~, mic, aq, ~] = get_geo_positions(geoName,param.Q,param.ra);
    [source,scan]=source_scan_settings(param.phi,param.theta,param.rs);
end
% Microphone angles (φ, θ) in radians
[micRad(1,:),micRad(2,:)]=mycart2sph(mic.x,mic.y,mic.z) ;

% % Debug plot
% figure(1)
% plot3(mic.x, mic.y, mic.z,'b*'); hold on
% for it=1:param.Q
%     text(mic.x(it)*1.1, mic.y(it)*1.1, mic.z(it)*1.1,num2str(it))
% end
% [mics.x,mics.y,mics.z] = mysph2cart(source.azi_rad,source.inc_rad,0.5) ;
% plot3(mics.x, mics.y, mics.z,'r*')
% text(mics.x*1.1, mics.y*1.1, mics.z*1.1,[num2str(param.phi) ',' num2str(param.theta)])
% axis equal
% grid on; grid minor
% xlabel('x'); ylabel('y'); zlabel('z')
% axis([-0.5 0.5 -0.5 0.5 -0.5 0.5])

%% Pre-allocation
Nphi = numel(scan.phi_lin);
Nth  = numel(scan.the_lin);
Nf   = numel(freq);
plotImage = zeros(Nphi, Nth, Nf);
%% Main frequency loop
for ifreq = 1:Nf
    k=(2*pi.*freq(ifreq))./source.cel; krq=k.*param.ra; kra=krq; krs=k.*param.rs;
    % if strcmp(sphType, 'open'), sphWave = 3; else sphWave = 4; end
    sphWave = strcmpi(sphType, 'open') * 3 + strcmpi(sphType, 'rigid') * 4;
    % Simulated mic signals & CSM (instantaneous form)
    sigMic=sma_freefield(micRad,sphWave,source.azi_rad,source.inc_rad,k,krq,kra,krs,source.a0);
    sigMic = funNoise(sigMic,param.SNR,param.seed);
    C = sigMic*sigMic'; % QxQ
    % ---------------- Algorithms ----------------
    if any(strcmpi(algoType,'CBF'))
        % -------- CBF --------
        [gridx,gridy,gridz] = mysph2cart(scan.phi_2Dlin,scan.th_2Dlin,param.rs);
        rqrl = zeros(param.Q,length(gridx));
        for q=1:param.Q  % Vectorized distances rqrl (Q×L)
            rqrl(q,:) = sqrt( (gridx-mic.x(q)).^2 + (gridy...
                -mic.y(q)).^2 + (gridz-mic.z(q)).^2 );
        end
        map = algo_CBF_k(C,k,rqrl,cType);
    else
        % -------- SHB --------
        if ischar(Nopt) || isstring(Nopt)
            mustBeMember(char(Nopt),{'auto'});
            N = floor(kra) + 1 ; % standardization
        elseif isnumeric(Nopt)
            if isscalar(Nopt)
                validateNscalar(Nopt,ifreq);
                N = Nopt;
            elseif isvector(Nopt)
                if numel(Nopt) ~= numel(freq)
                    error('Length N must be same as freq')
                end
                validateNscalar(Nopt(ifreq),ifreq);
                N = Nopt(ifreq);
            end
        else
            error('non recognize N value')
        end
        Nl = 20 ;
        if N > Nmax, N = Nmax; end
        [map,~] = algo_SHB_aq(C,N,micRad(2,:).',micRad(1,:).',...
            Nl,scan.th_2Dlin,scan.phi_2Dlin,sphWave,k,krq,kra,krs,dnType,aq);
    end
    plotImage(:,:,ifreq) = reshape(10*log10(abs(map)/source.a0^2),Nphi,Nth);
end
%% Display acoustic images
for ifreq=1:Nf
    name_title_image = sprintf([algoType ' $f=%.0f$ Hz - $kr=%.2f$' ' $Q=%d$' ],...
        freq(ifreq), round((2*pi.*freq(ifreq)).*param.ra./source.cel,2), param.Q) ;
    fig_acoustic_imaging(plotImage(:,:,ifreq),scan.phi_lin,scan.the_lin,name_title_image)
%%% If you need the values : 
    % SAR = get_solid_angle_ratio(scan.phi_lin,scan.the_lin,plotImage(:,:,ifreq),-3);
    % [MLD,~,MSR] = get_lobe_level(plotImage(:,:,ifreq));
    % sprintf(['MLD=%.2f  ' 'SAR=%.2f  ' 'MSR=%.2f  '],round(MLD,2),round(SAR,2),round(MSR,2))
end

    function validateNscalar(N,ifreq)
        if ~(isscalar(N) && isfinite(N) && N>0 && N==fix(N))
            error('N(ifreq=%d) doit être un entier positif.', ifreq);
        end
    end

end
