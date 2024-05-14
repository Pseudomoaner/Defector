function [] = plotTriangle(x,y,theta,scale,colour,axH)
%PLOTTRIANGLE plots an equilateral triangle of the given position, scale, 
%colour and orientation on the current axes.
%
%   INPUTS:
%       -x: x-coordinate of triangle centre
%       -y: y-coordinate of triangle centre
%       -theta: orientation of triangle (value of 0 indicates one vertex is
%       poiting directly left)
%       -scale: how large the triangle should be (the distance between the
%       centre and each corner)
%       -colour: colour of triangle, as standard Matlab triple (1x3 vector)
%       -axH: Handle to axes into which you want to plot.
%
%   Author: Oliver J. Meacock, (c) 2021

x1 = x + (cosd(theta) * scale);
y1 = y + (sind(theta) * scale);
x2 = x + (cosd(theta + 120) * scale);
y2 = y + (sind(theta + 120) * scale);
x3 = x + (cosd(theta - 120) * scale);
y3 = y + (sind(theta - 120) * scale);

X = [x1;x2;x3];
Y = [y1;y2;y3];

patch(X,Y,colour,'Parent',axH);