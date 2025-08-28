%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Save .mat files from web .txt files.  
%%%% K.ROUARD - 15/03/2023
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Bibliography::
% J. Fliege and U. Maier, The Distribution of Points on the Sphere and 
% Corresponding Cubature Formulae, IMA Journal of Numerical Analysis, 
% vol. 19, no. 2, pp. 317–334, 1999. doi: 10.1093/imanum/19.2.317.
%
% R. Womersley, Interpolation and Cubature on the Sphere, Mar. 2020. 
% [Online]. Available: https://web.maths.unsw.edu.au/~rsw/Sphere/#Weights
% same as ::
api = 'https://www.personal.soton.ac.uk/jf1w07/nodes/' ;
%%% Loop trying importdata. 
for k=0:900
    try
        urlfileName = [num2str(k)] ;
        fileName = ['fliege' sprintf('%03d', k)] ;
        fileNameMat = [fileName '.mat'] ;
        url = [api urlfileName '.txt'];
        urlwrite(url, [fileName '.txt'])
    catch
    continue;
    end
 end

 




