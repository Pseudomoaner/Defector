function [pDorients,nDorients] = findDefectOrients(pD,nD,dx4,dy4,nx,ny,gridSpacing)
defectCircleRadius = 10;

pDorients = zeros(size(pD,1),1);
%Find the orientation of the positive half defects
for i = 1:size(pD,1)
    yDPos = pD(i,1)/gridSpacing; %In pixels
    xDPos = pD(i,2)/gridSpacing;
    
    %Clockwise list of indices around defect core (for old version of code)
%     xSurrList = round([xDPos + (-defectBoxHalfSize:defectBoxHalfSize)'; (xDPos + defectBoxHalfSize) * ones(defectBoxHalfSize * 2,1); xDPos - (-defectBoxHalfSize + 1:defectBoxHalfSize)'; (xDPos  - defectBoxHalfSize) * ones((defectBoxHalfSize * 2) - 1,1)]);
%     ySurrList = round([(yDPos + defectBoxHalfSize) * ones((defectBoxHalfSize * 2) + 1,1); yDPos - (-defectBoxHalfSize + 1:defectBoxHalfSize)'; (yDPos - defectBoxHalfSize) * ones(defectBoxHalfSize * 2,1); yDPos + (-defectBoxHalfSize + 1:defectBoxHalfSize - 1)']);
    
    %Clockwise list of indices around defect core, on circular path
    [xSurrList,ySurrList] = findParameterizedCirclePoints(defectCircleRadius,[xDPos,yDPos]);

    if isempty(find(xSurrList < 1,1)) && isempty(find(ySurrList < 1,1)) && isempty(find(xSurrList > ny,1)) && isempty(find(ySurrList > nx,1)) %Make sure box does not go outside range of director field. At some point, I seem to have decided that nx should correspond to the y direction, so just ignore this apparant incongruity.
        %Clockwise list of orentations of director field around defect core
        nemList = zeros(size(xSurrList));
        for j = 1:size(nemList,1)
            nemList(j) = atan(dy4(ySurrList(j),xSurrList(j))/dx4(ySurrList(j),xSurrList(j)));
        end
        
        [xOrient,yOrient] = GetphalfDefectOrientation(xDPos,yDPos,nemList,xSurrList,ySurrList);
        pDorients(i) = atan2d(yOrient,xOrient);
    else
        pDorients(i) = nan;
    end
end

nDorients = zeros(size(nD,1),1);
%Find the orientation of the negative half defects
for i = 1:size(nD,1)
    yDPos = nD(i,1)/gridSpacing; %In pixels
    xDPos = nD(i,2)/gridSpacing;
    
    %Clockwise list of indices around defect core (for old version of code)
%     xSurrList = round([xDPos + (-defectBoxHalfSize:defectBoxHalfSize)'; (xDPos + defectBoxHalfSize) * ones(defectBoxHalfSize * 2,1); xDPos - (-defectBoxHalfSize + 1:defectBoxHalfSize)'; (xDPos  - defectBoxHalfSize) * ones((defectBoxHalfSize * 2) - 1,1)]);
%     ySurrList = round([(yDPos + defectBoxHalfSize) * ones((defectBoxHalfSize * 2) + 1,1); yDPos - (-defectBoxHalfSize + 1:defectBoxHalfSize)'; (yDPos - defectBoxHalfSize) * ones(defectBoxHalfSize * 2,1); yDPos + (-defectBoxHalfSize + 1:defectBoxHalfSize - 1)']);
    
    %Clockwise list of indices around defect core, on circular path
    [xSurrList,ySurrList] = findParameterizedCirclePoints(defectCircleRadius,[xDPos,yDPos]);

    if isempty(find(xSurrList < 1,1)) && isempty(find(ySurrList < 1,1)) && isempty(find(xSurrList > ny,1)) && isempty(find(ySurrList > nx,1)) %Make sure box does not go outside range of director field. At some point, I seem to have decided that nx should correspond to the y direction, so just ignore this apparant incongruity.
        %Clockwise list of orentations of director field around defect core
        nemList = zeros(size(xSurrList));
        for j = 1:size(nemList,1)
            nemList(j) = atan(dy4(ySurrList(j),xSurrList(j))/dx4(ySurrList(j),xSurrList(j)));
        end
        
        [xOrient,yOrient] = GetmhalfDefectOrientation(xDPos,yDPos,nemList,xSurrList,ySurrList);
        nDorients(i) = atan2d(yOrient,xOrient);
    else
        nDorients(i) = nan;
    end
end