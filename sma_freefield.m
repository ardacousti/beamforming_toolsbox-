function [P] = sma_freefield(mic_rad,sphwave,ph_s,th_s,k,kr,ka,krs,a0)
% Generate acoustic pressures of spherical microphone array in free field
% acoustic conditions 
%
%**************************************************************************
%  Author: Kevin Rouard | 14 June 2024
%**************************************************************************
    if k>1
        INFTY = floor((1.2*ka + 8 * (krs./(ka) +1)./(krs./(ka)))) ;
    else
        INFTY = 2 ;
    end
    Ynm_s   =   sh2(INFTY,th_s,ph_s).';
    anm     =   a0.*Ynm_s';
    Ynm_inf = sh2(INFTY,mic_rad(2,:),mic_rad(1,:)).';
    Binf    =   BnMatR(INFTY,k,kr,ka,krs,sphwave).';
    Pnm     =   Binf.*anm;
    P = (Ynm_inf*Pnm) ;
end

