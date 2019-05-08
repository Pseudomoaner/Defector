function [outX,outY] = findParameterizedCirclePoints(circRad,circCent)
%Finds the (ordered) list of pixels in a circular path of radius circRad
%around the given point circCent.

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