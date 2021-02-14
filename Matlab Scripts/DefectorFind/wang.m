function answ=wang(ax1,ax2)
%WANG finds the difference between the angles of the input directors.
%
%   INPUTS:
%       -ax1, ax2: 1x2 vectors specifying the director angles you want to
%       find the angle between
%
%   OUTPUTS:
%       -answ: Angular displacement between the two input vectors.
%
%   Author: Amin Doostmohammadi, (c) 2021

ang=atan2(abs(det([ax1;ax2])),dot(ax1,ax2));
if(ang>pi/2)
    ax2=-ax2;
end
m=det([ax1;ax2]);
ang=sign(m)*atan2(abs(m),dot(ax1,ax2));
answ=ang;