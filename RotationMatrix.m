function  [out] = RotationMatrix(V,alpha,beta,gamma)
%   Full rotation matrix
%
%**************************************************************************
% Author:  Kevin Rouard  |  Date: 18 June 2025
%**************************************************************************
Rx = rotx(alpha);
Ry = roty(beta);
Rz = rotz(gamma);

A = Rz * Ry * Rx ; 

Lx = length(V.x) ;
vp = zeros(3,6) ;

for iv=1:Lx
    v = [V.x(iv); V.y(iv); V.z(iv)]  ;
    vp(:,iv) = A * v;
end

out.x = vp(1,:);
out.y = vp(2,:);
out.z = vp(3,:);
end