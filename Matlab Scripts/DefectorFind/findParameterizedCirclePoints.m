function [outX,outY] = findParameterizedCirclePoints(circRad,circCent)
%FINDPARAMETERIZEDCIRCLEPOINTS finds the (ordered) list of pixel locations in 
%a circular path around the given point.
%   
%   INPUTS:
%       -circRad: Radius of the circular path you want to sample pixels
%       from
%       -circCent: Coordinates of the centre of the circular path.
%
%   OUTPUTS:
%       -outX, outY: Coordinates of the pixels in the circular path of the
%       specified radius.
%
%   Author: Oliver J. Meacock, (c) 2021

density = pi/4; %Starting with some multiple of pi ensures symmetry of the resulting path
trialParam = 0:density:2*pi;
trialX = round(circRad * cos(trialParam));
trialY = round(circRad * sin(trialParam));
trialDists = sqrt((diff(trialX) .^ 2) + (diff(trialY) .^ 2));

while sum(trialDists > sqrt(2)) > 0
    density = density/2;trialParam = 0:density:2*pi;
    trialX = round(circRad * cos(trialParam));
    trialY = round(circRad * sin(trialParam));
    trialDists = sqrt((diff(trialX) .^ 2) + (diff(trialY) .^ 2));
end

%Remove repeated points in final path
trialPoints = unique([trialX',trialY'],'rows','stable');

%Add specified displacement (based on center of circle).
outX = round(trialPoints(:,1) + circCent(1));
outY = round(trialPoints(:,2) + circCent(2));