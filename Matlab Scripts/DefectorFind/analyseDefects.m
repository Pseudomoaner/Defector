function [pD,nD,pDorients,nDorients] = analyseDefects(dx,dy,minimumDist,plotting)
%ANALYSEDEFECTS finds the locations and orientations of half-integer
%defects in the given director field.
%
%   INPUTS:
%       -dx: The x-components of the orientation vectors of the orientation
%       field.
%       -dy: The y-components of the orientation vectors.
%       -minimumDist: The minimum separation (in pixels) permitted between
%       defects of opposite charge. Defect pairs closer than this will be
%       annihilated.
%       -plotting: Whether or not to generate an overlay of the detected
%       defects.
%
%   OUTPUTS:
%       -pD: The locations of the detected +1/2 defect cores (nx2 matrix)
%       -nD: The locations of the detected -1/2 defect cores (nx2 matrix)
%       -pDorients: The orientations of the corresponding +1/2 defects in
%       degrees, between -180 and 180 degrees (nx1 vector)
%       -nDorients: The orientations of the corresponding -1/2 defects in
%       degrees, between -60 and 60 degrees (nx1 vector)
%
%   Authors: Oliver J. Meacock and Amin Doostmohammadi, (c) 2021

dx4=dx;
dy4=dy;

[nx,ny] = size(dx);

%%%START OF PLOTTING PARAMETERS %%%
nMax = max(nx,ny);
defectScale = nMax/150;
defectThickness = 2;
%%%END OF PLOTTING PARAMETERS%%%

%Find the locations of possible defects (based on sharp edges in the
%orientation field)
se = strel('disk',2,8);
possSpots = imdilate(edge(dy),se);

wn=calcs(dx,dy,possSpots);
[pD,nD] = chargearray(nx,ny,wn);

[pD,nD] = annihilateDefects(pD,nD,minimumDist);

[pDorients,nDorients] = findDefectOrients(pD,nD,dx4,dy4,nx,ny,1);

if plotting
    for i = 1:size(nD,1)
        if ~isnan(nDorients(i))
            line([nD(i,2),nD(i,2)+(cosd(nDorients(i)+60)*defectScale)],[nD(i,1),nD(i,1)+(sind(nDorients(i)+60)*defectScale)],'Color',[0,0,0],'LineWidth',defectScale/defectThickness);
            line([nD(i,2),nD(i,2)+(cosd(nDorients(i)+60)*defectScale)],[nD(i,1),nD(i,1)+(sind(nDorients(i)+60)*defectScale)],'Color',[0,1,1],'LineWidth',defectScale/(defectThickness*2));
            line([nD(i,2),nD(i,2)+(cosd(nDorients(i)+180)*defectScale)],[nD(i,1),nD(i,1)+(sind(nDorients(i)+180)*defectScale)],'Color',[0,0,0],'LineWidth',defectScale/defectThickness);
            line([nD(i,2),nD(i,2)+(cosd(nDorients(i)+180)*defectScale)],[nD(i,1),nD(i,1)+(sind(nDorients(i)+180)*defectScale)],'Color',[0,1,1],'LineWidth',defectScale/(defectThickness*2));
            line([nD(i,2),nD(i,2)+(cosd(nDorients(i)-60)*defectScale)],[nD(i,1),nD(i,1)+(sind(nDorients(i)-60)*defectScale)],'Color',[0,0,0],'LineWidth',defectScale/defectThickness);
            line([nD(i,2),nD(i,2)+(cosd(nDorients(i)-60)*defectScale)],[nD(i,1),nD(i,1)+(sind(nDorients(i)-60)*defectScale)],'Color',[0,1,1],'LineWidth',defectScale/(defectThickness*2));
            
            plotTriangle(nD(i,2),nD(i,1),nDorients(i) + 60,defectScale/2,[0,0,0]);
            plotTriangle(nD(i,2),nD(i,1),nDorients(i) + 60,defectScale/3,[0,0,1]);
        else
            plotTriangle(nD(i,2),nD(i,1),60,defectScale/2,[0,0,0]);
            plotTriangle(nD(i,2),nD(i,1),60,defectScale/3,[0,0,1]);
        end
    end
    
    for i = 1:size(pD,1)
        plot(pD(i,2),pD(i,1),'ko','MarkerSize',defectScale,'MarkerFaceColor','k');
        plot(pD(i,2),pD(i,1),'ro','MarkerSize',defectScale/1.5,'MarkerFaceColor','r');
        if ~isnan(pDorients(i))
            plotarrow(pD(i,2),pD(i,1),cosd(pDorients(i)),sind(pDorients(i)),[1,0.5,0],defectScale*2,defectScale/defectThickness,defectScale/(defectThickness*2));
        end
    end
end