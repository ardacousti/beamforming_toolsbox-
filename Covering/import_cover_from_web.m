% % Import the Data from the Web 
% % Author:: K. ROUARD, 2023.
% % Bibliography::
% % N. J. A. Sloane, Home Page. [Online]. Available: http://neilsloane.com/.
% % 
% % J.H. Conway and N.J.A. Sloane, Sphere Packings, Lattices and Groups 
% % (Grundlehren der mathematischen Wissenschaften), 
% % Third. Springer-Verlag New York, 1999, vol. 290.

for k=16:64
    nom = ['maxvol.3.' num2str(k) '.txt'];
    data = webread(['http://neilsloane.com/maxvolumes/dim3/' nom]);
    dat =str2num(data);
    save(nom,'dat','-ascii')
end

