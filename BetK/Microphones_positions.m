% function [M]= micpos_BetK_50(order) 

function [Pstspherical]= Microphones_positions(r) 
% Microphones_positions − Generates mat files with the positions of the 
% microphones in the the 50−mic rigid sphere. Also provides the last column of 
% the matrix with the Gaussian numerical integration weighting coefficients. 
% 
% Inputs : 
% 	r − radius of the sphere in use 
% 
% Outputs : 
% 
% 	Pstspherical − Matrix with the spherical coordinatest (r , theta , phi) 
% 		in the first three columns and the weighting factors in the last one . 
% 
% 	NumIntegr_coefficients.mat − column with numerical integration 
% 		coefficients. 
% Author : Guillermo Moreno 
% April 2008; email : kitxiniti@gmail.com 
% −−−−−−−−−−−−− BEGIN CODE −−−−−−−−−−−−−− 
% Matrix provided by Bruel & kaejer with the positions of the 50 microphones 
% if the sphere were 1 meter radius , and the weighting factors in the last column 
% if order == 50
M = [0.348728205     0.095094359     0.932389744     0.21453000 
0.017323077     0.361046154     0.932389744     0.21453000 
-0.338020513    0.128061538     0.932389744     0.21453000 
-0.226246154    -0.281897436    0.932389744     0.21453000 
0.198184615     -0.302287179    0.932389744     0.21453000 
0.72585641      0.228861538     0.64865641      0.21694000 
0.442666667     0.59414359      0.671589744     0.23824000 
0.006641641     0.76105641      0.64865641      0.21694000 
-0.42825641     0.604615385     0.671589744     0.23824000 
-0.721753846    0.241497436     0.64865641      0.21694000 
-0.707364103    -0.220451282    0.671589744     0.23824000 
-0.452707692    -0.611805128    0.64865641      0.21694000 
-0.008922564    -0.740871795    0.671589744     0.23824000 
0.441969231     -0.619610256    0.64865641      0.21694000 
0.701846154     -0.237425641    0.671589744     0.23824000 
0.960276923     0.142871795     0.239723077     0.29000000 
0.688471795     0.686953846     0.232594872     0.29692000 
0.160871795     0.957425641     0.239723077     0.29000000 
-0.440635897    0.867035897     0.232594872     0.29692000 
-0.860830769    0.448882051     0.239723077     0.29000000 
-0.960758974    -0.151138462    0.232594872     0.29692000
-0.692933333    -0.679989744    0.239723077     0.29000000 
-0.153148718    -0.960441026    0.232594872     0.29692000 
0.432584615     -0.869138462    0.239723077     0.29000000 
0.866102564     -0.442451282    0.232594872     0.29692000 
0.198184615     0.302246154     -0.9324         0.21453000 
-0.226225641    0.281876923     -0.9324         0.21453000 
-0.337989744    -0.128051282    -0.9324         0.21453000 
0.017340513     -0.361015385    -0.9324         0.21453000 
0.348697436     -0.095067692    -0.9324         0.21453000 
0.701815385 	0.237384615     -0.671641026    0.23824000 
0.441948718     0.619579487     -0.648687179    0.21694000 
-0.008896103    0.740820513     -0.671641026    0.23824000 
-0.452687179    0.611774359     -0.648687179    0.21694000 
-0.707323077    0.220441026 	-0.671641026    0.23824000 
-0.721723077    -0.241487179    -0.648687179    0.21694000 
-0.428225641    -0.604584615    -0.671641026    0.23824000 
0.006641333     -0.761025641    -0.648687179    0.21694000 
0.442666667     -0.594092308    -0.671641026    0.23824000 
0.725825641     -0.228851282 	-0.648687179    0.21694000 
0.866061538     0.442482051     -0.232676923    0.29692000 
0.432605128     0.869128205 	-0.239733333    0.29000000 
-0.1532         0.960410256     -0.232676923    0.29692000 
-0.692923077    0.679989744     -0.239733333    0.29000000 
-0.960738462    0.151138462     -0.232676923    0.29692000 
-0.860830769    -0.448882051    -0.239733333    0.29000000 
-0.440625641    -0.867015385    -0.232676923    0.29692000 
0.160902564     -0.957415385    -0.239733333    0.29000000 
0.688420513     -0.686974359    -0.232676923    0.29692000 
0.960276923     -0.142830769    -0.239733333    0.29000000 
];
% else
%     error('must be 50 mic. for array B&K')
% end

% save (’mic_positions_with coeficients_1m’, ’M’) ; 
Pst = zeros(50,3) ; 
% 0,0975 meters is the real radius of the 50−mic sphere, therefore using 
% Thales, and cilindrical coordinates ’ properties. 
for n=1:50 
    rho1        = sqrt(1^2-M(n,3)^2) ; 	% protection of the radius=1 in the plane xy 
    Pst(n,3)    = M(n,3) * r ;          % transform z coordinate 
    rho2        = sqrt(r^2-Pst(n,3)^2) ; % protection of the new radius in the plane xy 
    Pst(n,1)    = M(n,1) * rho2 / rho1 ; % transform x coordinate 
    Pst(n,2)    = M(n,2) * rho2 / rho1 ; % transform y coordinate 
end 
% in case we need the cartesian coordinates (Pst) for the new radius sphere 
% is always good to calculate the spherical in this way. 
A=M(:,4) ; 
% save('NumIntegr_coefficients', 'A' ) ; 
%−−−−−− transformation into spherical coordinates −−−−−−− 
% definition of the matrix 
Pstspherical=zeros(50,4) ; 
% fourth column , weighting factors 
Pstspherical(:,4) = M(:,4) ; 
% first column, the radius 
% second column, elevation 
% third column, azimuth 
for n=1:50 
% the radius is gonna be always the same , but it was a good way to chek 
% that the convertion was done in the right way 
Pstspherical(n,1) = sqrt(Pst(n,1)^2+Pst(n,2)^2+Pst(n,3)^2) ; 
Pstspherical(n,2) = acos(Pst(n,3) / Pstspherical (n ,1) ) ;
Pstspherical(n,3) = atan2(Pst(n,2), Pst(n,1) ) ; 
end 
%−−−−−−−−−−−−− END OF CODE −−−−−−−−−−−−−−

