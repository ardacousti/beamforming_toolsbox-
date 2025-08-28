function BB = BnMatR(N,k,kr,ka,krs,sphere)
%   Radial matrix for plane/spherical waves around a sphere
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
%
%   Output:
%       BB       Radial matrix (transfer matrix)
%
%   References:
%       - Boaz Rafaely, "Fundamentals of Spherical Array Processing", 2018.
%
%**************************************************************************
% Author:   Kevin Rouard (mod. from Boaz Rafaely codes)
% Date:     26 Oct 2021
%**************************************************************************
BB=[];
for n=0:N
    B = BnR(n,k,kr,ka,krs,sphere);
    BB = [BB; repmat(B,2*n+1,1)];
end
BB=BB.';