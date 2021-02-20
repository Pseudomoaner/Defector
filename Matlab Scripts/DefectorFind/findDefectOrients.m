function [pDorients,nDorients] = findDefectOrients(pD,nD,dx4,dy4,nx,ny,gridSpacing)
%FINDDEFECTORIENTS finds the orientations of all defects in the specified
%director field.
%
%   INPUTS:
%       -pD, nD: Coordinates of positive/negative half defect cores within
%       the director field, in physical units.
%       -dx4, dy4: x and y-components of the set of unit vectors specifying
%       the director field.
%       -nx, ny: Number of grid points in the director field in the x and y
%       directions
%       -gridSpacing: Spacing between points in sampling grid, in physical
%       units.
%
%   OUTPUTS:
%       -pDorients: Orientations of +1/2 defects, in degrees, specified
%       between -180 and 180 degrees.
%       -nDorients: Orientations of -1/2 defects, in degrees, specified
%       between - 60 and 60 degrees.
%
%   Authors: Oliver J. Meacock and Amin Doostmohammadi, (c) 2021

defectCircleRadius = 10;

pDorients = zeros(size(pD,1),1);
%Find the orientation of the positive half defects
for i = 1:size(pD,1)
    yDPos = pD(i,1)/gridSpacing; %In pixels
    xDPos = pD(i,2)/gridSpacing;
    
    %Clockwise list of indices around defect core, on circular path
    [xSurrList,ySurrList] = findParameterizedCirclePoints(defectCircleRadius,[xDPos,yDPos]);

    if isempty(find(xSurrList < 1,1)) && isempty(find(ySurrList < 1,1)) && isempty(find(xSurrList > ny,1)) && isempty(find(ySurrList > nx,1)) %Make sure box does not go outside range of director field. At some point, I seem to have decided that nx should correspond to the y direction, so just ignore this apparant incongruity.
        %Clockwise list of orentations of director field around defect core
        nemList = zeros(size(xSurrList));
        for j = 1:size(nemList,1)
            nemList(j) = atan(dy4(ySurrList(j),xSurrList(j))/dx4(ySurrList(j),xSurrList(j)));
        end
        
        pDorients(i) = GetphalfDefectOrientation(xDPos,yDPos,nemList,xSurrList,ySurrList);
    else
        pDorients(i) = nan;
    end
end

nDorients = zeros(size(nD,1),1);
%Find the orientation of the negative half defects
for i = 1:size(nD,1)
    yDPos = nD(i,1)/gridSpacing; %In pixels
    xDPos = nD(i,2)/gridSpacing;
    
    %Clockwise list of indices around defect core, on circular path
    [xSurrList,ySurrList] = findParameterizedCirclePoints(defectCircleRadius,[xDPos,yDPos]);

    if isempty(find(xSurrList < 1,1)) && isempty(find(ySurrList < 1,1)) && isempty(find(xSurrList > ny,1)) && isempty(find(ySurrList > nx,1)) %Make sure box does not go outside range of director field. At some point, I seem to have decided that nx should correspond to the y direction, so just ignore this apparant incongruity.
        %Clockwise list of orentations of director field around defect core
        nemList = zeros(size(xSurrList));
        for j = 1:size(nemList,1)
            nemList(j) = atan(dy4(ySurrList(j),xSurrList(j))/dx4(ySurrList(j),xSurrList(j)));
        end
        
        nDorients(i) = GetmhalfDefectOrientation(xDPos,yDPos,nemList,xSurrList,ySurrList);
    else
        nDorients(i) = nan;
    end
end