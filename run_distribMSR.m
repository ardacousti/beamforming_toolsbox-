function [] = run_distribMSR(param,geoName,sphType,algoType,distribMSR)
%PILOT_MY_FUNCTIONS Summary of this function goes here
%
%
%**************************************************************************
% Author:           Kevin Rouard
% Date:             23 August 2025
%**************************************************************************
if any(strcmpi(distribMSR,'Y'))
    %% Supplementary parameters
    kraLin = 2:0.05:8;
    param.ra = 0.05; 
    
    cType = 5; % CBF formulation iii
    dnType= 1; % SHB gain (MD)

    [~,scan]=source_scan_settings(0,90,param.rs); %Initialize parameters

    %% Pre-allocation
    Nphi = numel(scan.phi_lin);
    Nth  = numel(scan.the_lin);
    Nf   = numel(kraLin);
    plotImage = zeros(Nphi, Nth, Nf);
    %% Main frequency loop
    parfor it = 1:Nf % Use parfor with SHB
        %% Microphone positions for a given geometry
        % if any(strcmpi(centeredSource,'Y'))
            [~, mic0, aq, ~]=get_geo_positions(geoName,param.Q,param.ra);
            mic1=RotationMatrix(mic0,0,0,-param.phi) ;
            mic=RotationMatrix(mic1,0,-(param.theta-90),0) ;
            [source,scan]=source_scan_settings(0,90,param.rs);
        % else
        %     [~, mic, aq, ~] = get_geo_positions(geoName,param.Q,ra_logMat(idkra(it)));
        %     [source,scan]=source_scan_settings(param.phi,param.theta,param.rs);
        % end
        % Microphone angles (φ, θ) in radians
        [micRad1,micRad2]=mycart2sph(mic.x,mic.y,mic.z) ;

        k = kraLin(it)./param.ra; krq=kraLin(it); kra=krq; krs=k.*param.rs;
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
        plotImage(:,:,it) = reshape(10*log10(abs(map)/max(max(abs(map)))),Nphi,Nth);
    end
    % Display acoustic images
    % freqLin = source.cel*kraLin./(2*pi*param.ra) ; 
    % for it=1:10:Nf
    %     name_title_image = sprintf([algoType ' $f=%.0f$ Hz - $kr=%.2f$' ' $Q=%d$' ],...
    %         freqLin(it), round(kraLin(it),2), param.Q) ;
    %     fig_acoustic_imaging(plotImage(:,:,it),scan.phi_lin,scan.the_lin,name_title_image)
    % end
    %% Display disribution of MSR figure
    fig_distribMSR(geoName,param.Q,plotImage,kraLin)
end
end


