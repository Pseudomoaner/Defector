function [] = plotTriangle(x,y,theta,scale,colour)
%DRAWTRIANGLE plots a triangle of the given position, scale, colour and orientation

x1 = x + (cosd(theta) * scale);
y1 = y + (sind(theta) * scale);
x2 = x + (cosd(theta + 120) * scale);
y2 = y + (sind(theta + 120) * scale);
x3 = x + (cosd(theta - 120) * scale);
y3 = y + (sind(theta - 120) * scale);

X = [x1;x2;x3];
Y = [y1;y2;y3];

patch(X,Y,colour);