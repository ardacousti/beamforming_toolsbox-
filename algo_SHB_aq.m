function [Out, WW] = algo_SHB_aq(C,N,th_Mic,ph_Mic,Nl,th_Scan,ph_Scan,Tpsphere,k,kr,ka,krs,dnType,aq,varargin)
%   Spherical Harmonic Beamforming (SHB) with multiple gain designs
%
%   Inputs:
%       C           Q×Q cross-spectral matrix (CSM)
%       N           Truncation order for microphones (nonnegative integer)
%       th_Mic      Q×1 microphone inclination angles θ (rad)
%       ph_Mic      Q×1 microphone azimuth angles φ (rad)
%       Nl          Truncation order for scan grid (Nl ≥ N)
%       th_Scan     L×1 scan inclination angles θ (rad)
%       ph_Scan     L×1 scan azimuth angles φ (rad)
%       Type_Sph    'open' | 'rigid'   (spherical boundary type)
%       k           Wavenumber (rad/m)
%       kr          k*r  at microphone radius r        (scalar or vector)
%       ka          k*a  at sphere radius a            (scalar or vector)
%       krs         k*rs at source radius rs           (scalar or vector)
%       dnType      Gain design selector (int or char):
%                   {1,'MD'}     Maximum Directivity (Rafaely, 2018)
%                   {2,'DS'}     Delay and Sum (Rafaely, 2018)
%                   {3,'MWNG'}   Maximum White Noise Gain (Rafaely, 2018)
%                   {4,'SHARP'}  Spherical Harmonics Angularly Resolve Pressure (Haddad, 2008)
%                   {5,'FOHCP'}  Fractional-Order Hyper-Cardioid (Carpentier, 2023) 
%                   {7,'DAS'}    Delay and Sum (Yang, 2016)
%                   otherwise    SHB without gain (dn = 1)
%       aq          Q×1 microphone weights
%       varargin    Extra parameters per case
%
%   Notes : 
%       Yq      SHTF of Pmic, (N+1)^2 x Mic.Nb
%       Yl      SHTF in axis-symmetric look direction, (Nl+1)^2 x 4(Nl+1)^2
%       B       Bessel/Hankel function depending on sphere type, (N+1)^2 x 1
%       WnmH    the hermitian steering matrix
%       WcW     Power spectrum matrix with the microphone weights
%       pnm     Power spectrum of the modal acoustic pressure
%
%   Outputs:
%       Out         L×1 beamformer map over scan directions
%       WW          Q×Q weight outer-product (aq*aq.')
%
%**************************************************************************
% Author:   Kevin Rouard
% Date:     3 Apr 2024
%**************************************************************************
%% --- Weights
aq = aq(:);                     % ensure column
WW = aq * aq.';                 % Q×Q
wCw = WW .* C;                  % weighted CSM (Hadamard product)
%% --- Harmonic bases 
Yq = (sh2(N,  th_Mic,  ph_Mic)).'; % Microphones (Q × (N+1)^2)
Yl = (sh2(Nl, th_Scan, ph_Scan)).'; % Scan grid (L × (Nl+1)^2), restrict to N
YlN = Yl(:, 1:(N+1)^2);
%% --- Radial terms
Bn = (BnMatR(N, k, kr, ka, krs, Tpsphere)).'; 
%% --- modal pressure 
pnm = Yq' * wCw * Yq;
%% --- Switch on design
switch dnType
    % ===== 1) Maximum Directivity (MD) =====
    case {1, 'MD'}
        dn      =   (4*pi)/(N+1)^2 ;
        dnBn    =   (dn./Bn) ;
        WnmH   =     YlN * diag(dnBn) ;
        Out = dot( WnmH *  pnm, WnmH, 2) ;
    % ===== 2) Delay-and-Sum (DS) =====    
    case {2, 'DS'}
        dn      =   abs(Bn).^2 ;
        dnBn    =   (dn./Bn) ;
        WnmH   =     YlN * diag(dnBn) ;
        Out = dot( WnmH *  pnm, WnmH, 2) ;
    % ===== 3) Maximum White Noise Gain (MWNG) =====    
    case {3, 'MWNG'}
        D      =   abs(Bn).^2 ;
        FF=[];
        for ii=0:N
            F = (2*ii+1);
            FF = [FF; repmat(F,2*ii+1,1)];
        end
        dn      =   D ./ sum( (FF.*D)/(4*pi) ) ;
        dnBn    =   (dn./Bn) ;
        WnmH   =     YlN * diag(dnBn) ;
        Out = dot( WnmH *  pnm, WnmH, 2) ;
    % ===== 4) SHARP (Angularly Resolve Pressure) =====
    case {4, 'SHARP'}
        dn    =   (k/(N+1)^2) .* (exp(-1i.*krs)./(krs)) ; 
        dnBn  =   (dn./Bn) ;
        WnmH  =   YlN * diag(dnBn) ;
        Out = dot( WnmH *  pnm, WnmH, 2) ;
    % ===== 5) FOHCP / FMD (fractional) =====
    case {5, 'FOHCP', 'FMD'}
        clear Yq Yl Bn pnm
        Nf = N ; N = ceil(Nf) ; Nm1 = N - 1 ;
        alpha = 1 - (N/(Nf+1))*sqrt(((N-Nf)*(N+Nf+2))/(2*N+1)) ;
        if Nf==round(Nf)
            Yq   = (sh2(N,th_Mic,ph_Mic)).';
            Yl   =   (sh2(Nl,th_Scan,ph_Scan)).' ;
            Bn   =   (BnMatR(N,k,kr,ka,krs,Tpsphere)).';
            dn = alpha.*(4*pi)/(N+1)^2 ;
            dnBn    =   (dn./Bn) ;
            WnmH   =     Yl(:,1:(N+1)^2) * diag(dnBn) ;
            pnm    = (Yq)' * wCw *  (Yq);
            Out = dot( WnmH *  pnm, WnmH, 2) ;
        else
            Yq   = (sh2(N,th_Mic,ph_Mic)).';
            Yqm1 = (sh2(Nm1,th_Mic,ph_Mic)).' ;
            Yl   = (sh2(Nl,th_Scan,ph_Scan)).' ;
            Bn   = (BnMatR(N,k,kr,ka,krs,Tpsphere)).';
            Bnm1 = (BnMatR(Nm1,k,kr,ka,krs,Tpsphere)).';
            dn   = (4*pi)/(N+1)^2;
            dnm1 = (4*pi)/(Nm1+1)^2 ;
            dnBn   = (dn./Bn) ;
            dnBnm1 = (dnm1./Bnm1) ;
            WnmH   = Yl(:,1:(N+1)^2) * diag(dnBn) ;
            WnmHm1 = Yl(:,1:(Nm1+1)^2) * diag(dnBnm1) ;
            pnm    = (Yq)' * wCw *  (Yq);
            pnmm1    = (Yqm1)' * wCw *  (Yqm1);
            Out1 = dot( WnmH *  pnm, WnmH, 2) ;
            Out2 = dot( WnmHm1 *  pnmm1, WnmHm1, 2) ;
            Out = alpha.*Out1 + (1-alpha).*Out2 ; % May be false ...
        end
    % ===== 6) DAS (iv) (Yang, 2016) ====    
    case {6, 'DAS'}
        VqH  = ( Yq * diag( Bn ) * YlN' )' ;
        Q = length(th_Mic) ;
        norm_vqh = dot(VqH,VqH,2) ;
        WH = (4*pi*krs/k).*1./sqrt(Q) .* VqH ./ sqrt(norm_vqh);
        Out = dot(WH*C,WH,2) ;
    % ===== default: SHB without gain =====
    otherwise 
        dn      =   1 ;
        dnBn    =   (dn./Bn) ;
        WnmH   =     YlN * diag(dnBn) ;
        Out = dot( WnmH *  pnm, WnmH, 2) ;
end





