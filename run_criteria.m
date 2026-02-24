function [] = run_criteria(param,geoName,sphType,algoType,criteria)
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
%       centeredSource  'Y'/'N'  center source at (az=0, inc=90) and rotate array
%       criteria        'Y'/'N'  (placeholder for additional metrics)
%
%   Notes:
%       - Angles use convention φ (azimuth), θ (inclination from +z).
%       - Uses octavebandtradfun for frequency vector (octave here).
%       - Distance matrix rqrl is computed (Q×L).
%
%   See also:
%       source_scan_settings, mysph2cart, mycart2sph, Function_CBF_k, Function_SHBaq,
%       classic_criteria
%
%**************************************************************************
% Author:           Kevin Rouard
% Date:             23 August 2025
%**************************************************************************
if any(strcmpi(criteria,'Y'))
    %% Supplementary parameters
    freq = octavebandtradfun(200,8000,'third').'; % vector of frequencies (Hz)
    ra_log = logspace(log10(0.04),log10(0.40),30);

    cType = 5; % CBF formulation iii
    dnType= 1; % SHB gain (MD)

    [source,scan]=source_scan_settings(0,90,param.rs); %Initialize parameters

    kraMat = 2*pi*freq*ra_log/source.cel;
    [kraVec, idkra] = sort( reshape( kraMat,1,numel(freq)*numel(ra_log) )  ) ;
    freqMat = repmat(freq,1,numel(ra_log));
    ra_logMat = repmat(ra_log,numel(freq),1);

    %% Pre-allocation
    Nphi = numel(scan.phi_lin);
    Nth  = numel(scan.the_lin);
    Nf   = numel(kraVec);
    plotImage = zeros(Nphi, Nth, Nf);
    %% Main frequency loop
    parfor it = 1:Nf % Use parfor with SHB, or use a simple for loop
        %% Microphone positions for a given geometry
        % if any(strcmpi(centeredSource,'Y'))
        [~, mic0, aq, ~]=get_geo_positions(geoName,param.Q,ra_logMat(idkra(it)));
        mic1=RotationMatrix(mic0,0,0,-param.phi) ;
        mic=RotationMatrix(mic1,0,-(param.theta-90),0) ;
        [source,scan]=source_scan_settings(0,90,param.rs);
        % else
        %     [~, mic, aq, ~] = get_geo_positions(geoName,param.Q,ra_logMat(idkra(it)));
        %     [source,scan]=source_scan_settings(param.phi,param.theta,param.rs);
        % end
        % Microphone angles (φ, θ) in radians
        [micRad1,micRad2]=mycart2sph(mic.x,mic.y,mic.z) ;

        k=(2*pi.*freqMat(idkra(it)))./source.cel; krq=kraMat(idkra(it)); kra=krq; krs=k.*param.rs;
        sphWave = strcmpi(sphType, 'open') * 3 + strcmpi(sphType, 'rigid') * 4;
        % Simulated mic signals & CSM (instantaneous form)
        sigMic=sma_freefield([micRad1; micRad2],sphWave,source.azi_rad,source.inc_rad,k,krq,kra,krs,source.a0);
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
            Nmax = floor(sqrt(param.Q)) - 1 ; % standardization
            N = floor(kra) + 1 ;
            Nl = 20 ;
            if N > Nmax, N = Nmax; end
            [map,~] = algo_SHB_aq(C,N,micRad2.',micRad1.',...
                Nl,scan.th_2Dlin,scan.phi_2Dlin,sphWave,k,krq,kra,krs,dnType,aq);
        end
        [~ , idf] = max(map);
        maxPos1(it) = scan.phi_2Dlin(idf)*180/pi;
        maxPos2(it) = scan.th_2Dlin(idf)*180/pi;
        plotImage(:,:,it) = reshape(10*log10(abs(map)./source.a0.^2),Nphi,Nth);
    end
    maxPos = [maxPos1; maxPos2];
    %% Display acoustic images
    % for it=1:10:Nf
    %     name_title_image = sprintf([algoType ' $f=%.0f$ Hz - $kr=%.2f$' ' $Q=%d$' ],...
    %         freqMat(idkra(it)), round(kraMat(idkra(it)),2), param.Q) ;
    %     fig_acoustic_imaging(plotImage(:,:,it),scan.phi_lin,scan.the_lin,name_title_image)
    % end
    %% Display criteria figures
    name_title_image = sprintf([algoType ' $Q=%d$' ], param.Q) ;
    fig_criteria(geoName,plotImage,kraVec,scan.phi_lin,scan.the_lin,maxPos)


end
end


