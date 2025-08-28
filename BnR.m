function y = BnR(n,k,kr,ka,krs,sphere)
%   Radial functions for plane/spherical waves around a sphere
%
%   Inputs:
%       n       Spherical-harmonic order (nonnegative integer)
%       k       Wavenumber (rad/m)
%       kr      k*r  at microphone radius r   (can be scalar or array)
%       ka      k*a  at sphere radius a       (scalar or array)
%       krs     k*rs at source radius rs      (scalar or array)
%       sphere  Case selector (integer):
%                 1 : open   sphere, plane-wave,     mic type 'o'
%                 2 : rigid  sphere, plane-wave,     mic type 'o'
%                 3 : open   sphere, spherical-wave, mic type 'o'
%                 4 : rigid  sphere, spherical-wave, mic type 'o'
%                 5 : open   sphere, plane-wave, mic type cardioid
%   Output:
%       y       Radial function value(s) matching the selected case
%
%   Notes:
%       - Wronskian relations (for reference):
%           jn(x) * hn'*(x) - jn'(x) * hn*(x) = -i / x^2
%           jn'(x) / hn'*(x) = jn(x)/hn*(x) + i / (x^2 hn'*(x)hn*(x))
%
%   References:
%       - Taroudakis & Rafaely, Acta Acustica united with Acustica,
%         101 (2015), 470–473.
%       - Boaz Rafaely, "Fundamentals of Spherical Array Processing", 2018.
%
%   See also:
%       besseljs besselhs besseljsd besselhsd
%
%**************************************************************************
% Author:   Kevin Rouard (mod. from Boaz Rafaely codes)
% Date:     26 Oct 2021
%**************************************************************************
j=1i;
% ---------------- open sphere, plane wave ----------------
if sphere==1
   y = 4 * pi * j^n * besseljs(n,kr);    
% ---------------- rigid sphere, plane wave ----------------
elseif sphere==2
   y = 4 * pi * j^n * ( besseljs(n,kr) - ( besseljsd(n,ka)./conj(besselhsd(n,ka)) ) .* conj(besselhs(n,kr)) );
% ---------------- open sphere, spherical wave -------------
elseif sphere==3
   y =  (-j) * k  * besseljs(n,kr)*conj(besselhs(n,krs));  
% ---------------- rigid sphere, spherical wave ------------
elseif sphere==4
   y =  (-j) * k * conj(besselhs(n,krs)).* ( besseljs(n,kr) - ( besseljsd(n,ka)./conj(besselhsd(n,ka)) ) .* conj(besselhs(n,kr)) );
% ---------------- open sphere, plane-wave cardioid --------
elseif sphere==5
   y = 4 * pi * j^n * ( besseljs(n,kr) - j*besseljsd(n,kr) );
else
    y=0;  
end
