function answ=wang(ax1,ax2)
%ax1 and ax2 are the 1x2 vectors of the director orientation at a given point (x,y).
ang=atan2(abs(det([ax1;ax2])),dot(ax1,ax2));
if(ang>pi/2)
    ax2=-ax2;
end
m=det([ax1;ax2]);
ang=sign(m)*atan2(abs(m),dot(ax1,ax2));
answ=ang;
end