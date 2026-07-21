% Author:: K. ROUARD. 2024. april. 
function [Nmax] = table_order_fliege(nb_mic)

Q = [4,	9, 16, 25, 36, 49, 64, 81, 100, 121, 144, 169, 196, 225, 256, 289,...
    324, 361, 400, 441, 484, 529, 576, 625, 676, 729, 784, 841, 900] ;

N = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, ...
    21,	22,	23,	24,	25,	26,	27,	28,	29] ;

index = find(Q == nb_mic);

if ~isempty(index)
    Nmax = N(index);
else
    error('Non available number of microphone');
    Nmax = [];
end

end
