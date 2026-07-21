function [ x, y, z, w, N ] = ld_by_order ( order )

%*****************************************************************************80
%
%% ld_by_order() returns a Lebedev angular grid given its order.
%
%  Discussion:
%
%    Only a certain set of such rules are available through this function.
%
%  Modified:
%
%    13 September 2010
%
%  Author:
%
%    Dmitri Laikov
% Modified 04/03/2023, Kevin ROUARD, 2023, add precision_table. 
%
%  Reference:
%
%    Vyacheslav Lebedev, Dmitri Laikov,
%    A quadrature formula for the sphere of the 131st
%    algebraic order of accuracy,
%    Russian Academy of Sciences Doklady Mathematics,
%    Volume 59, Number 3, 1999, pages 477-481.
%
%  Input:
%
%    integer ORDER, the order of the rule.
%
%  Output:
%
%    real X(ORDER), Y(ORDER), Z(ORDER), W(ORDER), 
%    the coordinates and weights of the points.
%
  if ( order == 6 )
    [ x, y, z, w ] = ld0006( ); N = floor(precision_table(1)/2) ;
  elseif ( order == 14 )
    [ x, y, z, w ] = ld0014 ( ); N = floor(precision_table(2)/2) ;
  elseif ( order == 26 )
    [ x, y, z, w ] = ld0026 ( ); N = floor(precision_table(3)/2) ;
  elseif ( order == 38 )
    [ x, y, z, w ] = ld0038 ( ); N = floor(precision_table(4)/2) ;
  elseif ( order == 50 )
    [ x, y, z, w ] = ld0050 ( ); N = floor(precision_table(5)/2) ;
  elseif ( order == 74 )
    [ x, y, z, w ] = ld0074 ( ); N = floor(precision_table(6)/2) ;
  elseif ( order == 86 )
    [ x, y, z, w ] = ld0086 ( ); N = floor(precision_table(7)/2) ;
  elseif ( order == 110 )
    [ x, y, z, w ] = ld0110 ( ); N = floor(precision_table(8)/2) ;
  elseif ( order == 146 )
    [ x, y, z, w ] = ld0146 ( ); N = floor(precision_table(9)/2) ;
  elseif ( order == 170 )
    [ x, y, z, w ] = ld0170 ( ); N = floor(precision_table(10)/2) ;
  elseif ( order == 194 )
    [ x, y, z, w ] = ld0194 ( ); N = floor(precision_table(11)/2) ;
  elseif ( order == 230 )
    [ x, y, z, w ] = ld0230 ( ); N = floor(precision_table(12)/2) ;
  elseif ( order == 266 )
    [ x, y, z, w ] = ld0266 ( ); N = floor(precision_table(13)/2) ;
  elseif ( order == 302 )
    [ x, y, z, w ] = ld0302 ( ); N = floor(precision_table(14)/2) ;
  elseif ( order == 350 )
    [ x, y, z, w ] = ld0350 ( ); N = floor(precision_table(15)/2) ;
  elseif ( order == 434 )
    [ x, y, z, w ] = ld0434 ( ); N = floor(precision_table(16)/2) ;
  elseif ( order == 590 )
    [ x, y, z, w ] = ld0590 ( ); N = floor(precision_table(17)/2) ;
  elseif ( order == 770 )
    [ x, y, z, w ] = ld0770 ( ); N = floor(precision_table(18)/2) ;
  elseif ( order == 974 )
     [ x, y, z, w ] = ld0974 ( ); N = floor(precision_table(19)/2) ;
  elseif ( order == 1202 )
    [ x, y, z, w ] = ld1202 ( ); N = floor(precision_table(20)/2) ;
  elseif ( order == 1454 )
    [ x, y, z, w ] = ld1454 ( ); N = floor(precision_table(21)/2) ;
  elseif ( order == 1730 )
    [ x, y, z, w ] = ld1730 ( ); N = floor(precision_table(22)/2) ;
  elseif ( order == 2030 )
    [ x, y, z, w ] = ld2030 ( ); N = floor(precision_table(23)/2) ;
  elseif ( order == 2354 )
    [ x, y, z, w ] = ld2354 ( ); N = floor(precision_table(24)/2) ;
  elseif ( order == 2702 )
    [ x, y, z, w ] = ld2702 ( ); N = floor(precision_table(25)/2) ;
  elseif ( order == 3074 )
    [ x, y, z, w ] = ld3074 ( ); N = floor(precision_table(26)/2) ;
  elseif ( order == 3470 )
    [ x, y, z, w ] = ld3470 ( ); N = floor(precision_table(27)/2) ;
  elseif ( order == 3890 )
    [ x, y, z, w ] = ld3890 ( ); N = floor(precision_table(28)/2) ;
  elseif ( order == 4334 )
    [ x, y, z, w ] = ld4334 ( ); N = floor(precision_table(29)/2) ;
  elseif ( order == 4802 )
    [ x, y, z, w ] = ld4802 ( ); N = floor(precision_table(30)/2) ;
  elseif ( order == 5294 )
    [ x, y, z, w ] = ld5294 ( ); N = floor(precision_table(31)/2) ;
  elseif ( order == 5810 )
    [ x, y, z, w ] = ld5810 ( ); N = floor(precision_table(32)/2) ;
  else
   % fprintf ( 1, '\n' );
   % fprintf ( 1, 'LD_BY_ORDER - Fatal error!\n' );
   % fprintf ( 1, '  Unexpected value of ORDER.\n' );
    error ( 'LD_BY_ORDER - Fatal error!' );
  end

  return
end
