function plotarrow(x,y,u,v,color,scale,lineWidthK,lineWidthC,axH)
%PLOTARROW plots a coloured arrow on a black background, of the specified
%position, orientation and size.
%
%   INPUTS:
%       -x,y: Position of arrow tail 
%       -u,v: vector specifying length and direction of arrow
%       -colour: 1x3 vector specifying the colour of the arrow over the top
%       of the black background
%       -scale: Size of the arrow, acting to scale the vector specified by
%       u,v.
%       -lineWidthK,lineWidthC: Width of the lines used to specify the
%       black background and coloured overlay arrows.
%       -axH: Handle to axes into which you want to plot.

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

line(uuK(:),vvK(:),'Color',[0,0,0],'LineWidth',lineWidthK,'Parent',axH)
line(hu(:),hv(:),'Color',[0,0,0],'LineWidth',lineWidthK,'Parent',axH)

h1 = line(uuC(:),vvC(:),'Color',color,'LineWidth',lineWidthC,'Parent',axH);
h2 = line(hu(:),hv(:),'Color',color,'LineWidth',lineWidthC,'Parent',axH);