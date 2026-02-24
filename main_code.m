% - Set parameters: source/array geometry (rs, theta/phi, ra, Q), 
% array layout 'geoName', sphere type ('open'/'rigid'), and algorithm ('CBF'/'SHB').
% - Configure visualization flags to control outputs: acoustic images, 
% criteria (MLD, MSR, SAR), and the MSR distribution display.
% - Run by calling run_acousticImaging, run_criteria, 
% and run_distribMSR with the chosen parameters and flags.
%**************************************************************************
% Rouard et al. (2025) - submitted 
% Influence of spherical microphone array design on acoustic images
% obtained with conventional and spherical harmonic beamforming, JSV.
%**************************************************************************
% close all
%% Set parameters
% Set a fixed source-array radius rs (m) and its position
param.rs=2;
param.theta = 90; % [0,180]
param.phi = 0; % [-180,180]

% Set a fixed array radius ra (m) and a number of microphone Q
param.ra=0.1;
param.Q=24;

% Set noise and seed
param.SNR = +100;  % dB
param.seed = 'Y'; 

% Set the geometry
geoName = 't-design'; % See the list of geometry names
% {'Equi-angle' ; 'Gauss-Legendre' ; 'Lebedev' ; 'Fliege' ;...
%     'BetK' ; 't-design' ; 'Minimum Energy' ; 'Packing' ; 'Covering' ;...
%     'Maximal Volume' ; 'Efficient t-design' ; 'L-design' ; 'Maximum Determinant' ;...
%     'Fibonacci' ; 'Spiral'}
sphType = 'rigid'; % 'open'/'rigid'

% Set the algorithm
algoType = 'SHB'; % 'CBF'/'SHB'

%% VIEW RESULTS
% Display acoustic images
acousticImages = 'Y'; % 'Y'/'N'
centeredSource = 'Y'; % 'Y'/'N'

% Display criteria results (MLD, MSR, SAR)
criteria = 'N'; % 'Y'/'N'

% Display the distribution of MSR
distribMSR = 'N'; % 'Y'/'N'

%% Run
% Call the main functions
run_acousticImaging(param,geoName,sphType,algoType,acousticImages,centeredSource)
run_criteria(param,geoName,sphType,algoType,criteria)

run_distribMSR(param,geoName,sphType,algoType,distribMSR)
