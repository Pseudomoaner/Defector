function plotarrow(x,y,u,v,color,scale,lineWidthK,lineWidthC)

alpha = 0.5; % Size of arrow head relative to the length of the vector
beta = 0.5;  % Width of the base of the arrow head relative to the length

uSc = u*scale;
vSc = v*scale;
uuC = [x;x+uSc;NaN];
vvC = [y;y+vSc;NaN];
uuK = [x;x+uSc;NaN];
vvK = [y;y+vSc;NaN];

% h1 = plot(uu(:),vv(:),'Color',color,'EraseMode','none');
hu = [x+uSc-alpha*(uSc+beta*(vSc+eps));x+uSc; ...
    x+uSc-alpha*(uSc-beta*(vSc+eps));NaN];
hv = [y+vSc-alpha*(vSc-beta*(uSc+eps));y+vSc; ...
    y+vSc-alpha*(vSc+beta*(uSc+eps));NaN];

line(uuK(:),vvK(:),'Color',[0,0,0],'LineWidth',lineWidthK)
line(hu(:),hv(:),'Color',[0,0,0],'LineWidth',lineWidthK)

h1 = line(uuC(:),vvC(:),'Color',color,'LineWidth',lineWidthC);
h2 = line(hu(:),hv(:),'Color',color,'LineWidth',lineWidthC);

% h2 = plot(hu(:),hv(:),'Color',color,'EraseMode','none');
% drawnow