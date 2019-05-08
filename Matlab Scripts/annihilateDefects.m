function [pD,nD] = annihilateDefects(pD,nD,minimumDist)

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