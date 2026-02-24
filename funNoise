function [output] = funNoise(sig_mic,SNR,seed)

% author : Kevin ROUARD, 2025/09/19

% see : A. Pereira, Acoustic Imaging in Enclosed Spaces, Ph.D. thesis, INSA de Lyon, 2014.

Q = length(sig_mic);

if strcmpi(seed,'Y'), rng(3300,'combRecursive'); end, gamma = randn ; 
if strcmpi(seed,'Y'), rng(2892,'combRecursive'); end, delta = randn ; 

if strcmpi(seed,'Y'), rng(1394,'combRecursive'); end, epsilon=2*pi*randn; 
if strcmpi(seed,'Y'), rng(5580,'combRecursive'); end, zeta   =2*pi*randn; 

for iq = 1:Q
    Z(iq,:) = 10^(-SNR/20)*(gamma*exp(1i*epsilon)*sig_mic(iq) + delta*exp(1i*zeta)*sqrt(norm(sig_mic).^2/Q) ).';
end

output = sig_mic + Z; 
end
