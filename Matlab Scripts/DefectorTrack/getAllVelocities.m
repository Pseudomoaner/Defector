function [RawSpeed,RawPhi] = getAllVelocities(Centroids,Times,tStep) 
%GETALLVELOCITIES Calculates the raw velocities of all objects in the
%current tracked dataset.
%
%   INPUTS:
%       -Centroids: Nx1 cell array, where N is the total number of objects
%       in the current dataset. Each cell contains a Tx2 matrix of values,
%       indicating the (x,y) coordinates of the object at each sampled
%       point in its track.
%       -Times: Cell array of same size as Centroids containing the
%       timepoints at which each object is observed in its track
%       -tStep: The time (in physical units) between adjacent timepoints in
%       Times.
%
%   OUTPUTS:
%       -RawSpeed: Cell array containing the raw (unsmoothed) speed of all
%       objects in the input tracks.
%       -RawPhi: Cell array containing the raw (unsmoothed) direction of
%       motion of all objects in the input tracks.
%
%   Author: Oliver J. Meacock (c) 2019

RawSpeed = cell(size(Centroids));
RawPhi = cell(size(Centroids));

for i = 1:length(Times)
    if length(Times{i}) > 1
        rawX = Centroids{i}(:,1);
        rawY = Centroids{i}(:,2);
        
        interpX = interp1(Times{i},rawX,Times{i}(1):Times{i}(end))';
        interpY = interp1(Times{i},rawY,Times{i}(1):Times{i}(end))';
        
        interpDX = diff(interpX);
        interpDY = diff(interpY);
        
        rawVel = [interpDX./tStep,interpDY./tStep];
        
        RawSpeed{i} = sqrt(sum(rawVel.^2,2));        
        RawPhi{i} = -atan2d(interpDY,interpDX);
    else
        RawSpeed{i} = NaN;
        RawPhi{i} = NaN;
    end
end