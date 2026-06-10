function [output] = funNoise(sig_mic, SNR, seed, option)
% funNoise Add white noise or amplitude/phase defects to an input signal.
%
% Inputs:
%   sig_mic : Input signal
%   SNR     : Signal-to-noise ratio in dB
%   seed    : 'Y' to use fixed random seeds, otherwise random noise
%   option  : Noise/defect type
%             'gaus'    -> real Gaussian white noise
%             'gausC'   -> complex Gaussian white noise
%             'amp'     -> amplitude defect
%             'phase'   -> phase defect
%             'phasamp' -> phase and amplitude defect
%
% If option is not provided or is empty, the default is 'gaus'.

if nargin < 4 || isempty(option)
    option = 'gaus';
end

if strcmpi(seed, 'Y')
    rng(42); Rnoise = randn(size(sig_mic));
    rng(3300, 'combRecursive'); Cnoise = 1i * randn(size(sig_mic));
else
    Rnoise = randn(size(sig_mic));
    Cnoise = 1i * randn(size(sig_mic));
end

Ps = mean(abs(sig_mic(:)).^2);
Pn = Ps / 10^(SNR/10);

switch lower(option)
    case 'gausc'
        % Complex Gaussian white noise
        noiseo = (Rnoise + Cnoise) / sqrt(2);
    case {'gaus', 'amp'}
        % Real Gaussian white noise or amplitude defect
        noiseo = Rnoise;
    case 'phase'
        % Phase defect
        noiseo = exp(-Cnoise);
    case 'phasamp'
        % Phase and amplitude defect
        noiseo = Rnoise .* exp(-Cnoise);
    otherwise
        error("Invalid option. Use 'gaus', 'gausc', 'amp', 'phase', or 'phasamp'.");
end

noisen = noiseo / sqrt(mean(abs(noiseo(:)).^2));

switch lower(option)
    case {'gausc', 'gaus'}
        % Additive Gaussian white noise
        noisen2 = sqrt(Pn) * noisen;
        output = sig_mic + noisen2;
    case 'amp'
        % Amplitude defect
        noisen2 = sqrt(Pn/Ps) * noisen;
        output = sig_mic .* (1 + noisen2);
    case 'phase'
        % Phase defect
        noisen2 = sqrt(Pn/Ps) * noisen;
        output = sig_mic .* (1 + noisen2);
    case 'phasamp'
        % Phase and amplitude defect
        noisen2 = sqrt(Pn/Ps) * noisen;
        output = sig_mic .* (1 + noisen2);
end

end
