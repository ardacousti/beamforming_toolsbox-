function [MLL,MSL,MSR] = get_lobe_level(PREMAP2PLOT)
%   Extract main-lobe level (MLL), maximum sidelobe level (MSL),
%   and mainlobe to side-lobe ratio (MSR) from acoustic maps.
%
%   Input:
%       PREMAP2PLOT  φ×θ×L1×L2×L3 array of maps in dB.
%                    Dimensions 1–2 are angular (phi, theta). Dimensions
%                    3–4 are extra indices (e.g., frequency, radius, case).
%
%   Outputs:
%       MLL          L1×L2  Main Lobe Level (dB) at each (k1,k2)
%       MSL          L1×L2  Maximum Side Lobe Level (dB), or -Inf if none
%       MSR          L1×L2  MLL - MSL (dB), Inf if no side lobe found
%
%   Method (per map):
%       - Ignore the one-cell border to avoid edge artefacts.
%       - Convert dB→lin and apply a gamma compression (1/np) to help
%         peak detection; increase np until a peak is found.
%       - Evaluate peak heights from the ORIGINAL dB map, then sort.
%
%**************************************************************************
% Authors:  T. Padois (2022), modified by K. Rouard (Apr. 2023)
%**************************************************************************
% Sizes (angular dims = 1..2; “extra” dims = 3..5)
[~,~,L_1D,L_2D] = size(PREMAP2PLOT) ;
% Preallocate
MLL  = zeros(L_1D,L_2D);
MSL  = zeros(L_1D,L_2D);
MSR  = zeros(L_1D,L_2D);
for k2D= 1:L_2D
    for k1D = 1:L_1D
        % Parameters for peak search
        ind_tri = [] ;
        np = 2 ;
        while sum(size(ind_tri)) < 4 && np <= 100
            MAP_Lineaire = (10.^(PREMAP2PLOT(2:end-1,2:end-1,k1D,k2D))).^(1/np) ;
            % peaks2() is expected to return row/col indices of peaks
            [~,idxpeaks,idypeaks] = peaks2(MAP_Lineaire);
            % index for phi and theta for all peaks find
            ind_phi = idxpeaks+1;
            ind_the = idypeaks+1;
            % Find the value in dB
            values1 = diag(PREMAP2PLOT(ind_phi,ind_the,k1D,k2D));
            % Sort by descending order
            % the main lobe is first and the side lobe is second, and so on.
            [Values_tri,ind_tri] = sort(values1,'descend');
            try
                ind_the1 = ind_the(ind_tri,1);
            end
            np = 2*np ; % increase if nothing found
        end
        if sum(size(ind_the1)) == 2
            MLL_loop = Values_tri(1) ;
            MSL_loop = -1000  ; % Consider as -Inf.
            MSR_loop = Values_tri(1)-(-1000) ;
        elseif all(isnan(PREMAP2PLOT(ind_phi,ind_the,k1D,k2D)))
            MLL_loop = -1000;
            MSL_loop = -1000;
            MSR_loop =  1000;
        else
            MLL_loop = Values_tri(1) ;
            MSL_loop = Values_tri(2) ;
            MSR_loop = Values_tri(1)-Values_tri(2) ;
        end
        MLL(k1D,k2D) = MLL_loop;
        MSL(k1D,k2D) = MSL_loop;
        MSR(k1D,k2D) = MSR_loop;
    end
end

end


