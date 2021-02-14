function [pD,nD] = annihilateDefects(pD,nD,minimumDist)
%ANNIHILATEDEFECTS annihilates all pairs of opposite-charge defects that
%are less than the specified minimum distance apart from each other.
%
%   INPUTS:
%       -pD: original list of +1/2 defect positions (nx2 matrix).
%       -nD: original list of -1/2 defect positions (nx2 matrix).
%       -minimumDist: Minimum distance threshold between oppositely charged
%       defects required for their annihilation.
%
%   OUTPUTS:
%       -[pD,nD]: Versions of pD and nD with annihilated defects removed.
%
%   Author: Oliver J. Meacock, (c) 2021

%Find the distance between all pairs of positive and negative defects
defectDist = pdist2(pD,nD);

%Find the closest defect pairs, annihilate and repeat until minimumDist is reached
[minNdist,minNinds] = min(defectDist,[],2);
[minDist,minPind] = min(minNdist,[],1);
minNind = minNinds(minPind);

while minDist < minimumDist
    pD(minPind,:) = [];
    defectDist(minPind,:) = [];
    nD(minNind,:) = [];
    defectDist(:,minNind) = [];
    
    [minNdist,minNinds] = min(defectDist,[],2);
    [minDist,minPind] = min(minNdist,[],1);
    minNind = minNinds(minPind);
end