function[S]=quadlg(funct,a,b)

% Numerical integration by Gauss-Legendre Quadrature
% This is very universal formula
% If integral over (-inf +inf) use quadgh
% If integral over (a +inf) use quadglq
% quadg is also universal formula
% Gausian quadrature is the form
% integ(f)=sum(wi*xi)+E
% wi is weights xi is abscissas
% By Kenichi Ueda 1996


S=((b-a)/2)*((0.568889)*feval(funct,((b-a)/2)+a)......
 +(0.478629)*(feval(funct,(1.538469*(b-a)/2)+a)......
 +feval(funct,(0.461531*(b-a)/2)+a))......
 +(0.236927)*(feval(funct,(1.906180*(b-a)/2)+a)......
 +feval(funct,(0.09382*(b-a)/2)+a)));
