%IDEA: 
%To get one of the triangular vertex direction of minus half defect, notice in OrientationAnalysis result movies 
%that there will be one director more or less pointing in the same (nem)direction as
%that of the direction of the line linking its own position with the defect
%core ('radial director'), and the director opposite to it ( for 3 by 3 lattice of directors)  should ideally be having perpendicular (nem)direction wrt the 
%line linking its own position with the defect core ('transverse director').
%The difference in (nem) direction between director and line linking position to core is the 'smallest absolute relative change in direction' (herein named as RelCgDirPosToCore).
%THe exact definition for RelCgDirPosToCore is the absolute value of that defined in %Method to obtain winding number is refered from (in appendix a): 
% Huterer et al. - Distribution of singularities in the cosmic
% microwave background polarization - PRD 72, 043004 (2005)

%We will call the clear 'radial' director as Vertex, while the 'transverse director' opposite it as Edge.
%To determine a pair of (Vertex,Edge), we check opposite single directors.
%We take the ratio of RelCgDirPosToCore for each pair (Edge/Vertex). 
%The pair with the highest ratio of RelCgDirPosToCore, will be the direction of the Vertex To Edge, 
%with the vertex being the director with the smaller RelCgDirPosToCore value. 

%INPUT:
%NemAngleListCW: (in column form) gives  the angles in radians(vector angle wrt to some fixed axis - THE RANGE OF THE ANGLES must be within pi, e.g. [-pi/2,pi/2], [0,pi] etc.) of individual points,
%               gotten from travelling CLOCKWISE around a reference point. In the paper,
%                the range of angles was given as  [-pi/2,pi/2] 
%               These pts, form a squarish boundary (of boxes) around the core, with
%               number of boxes at the sides to be 3,4,5,etc. For side box numbers of 3, size(NemAngleListCW) will be 8, for 4, it will be 12 etc. 
%X(Y)PositionNemList:  x(y) location of the corresponding nem directors in the NemAngleListCW.
%x(y)phdcentre: x(y) location of plus half defect core centre.


%OUTPUT:
%NormX(Y)mhalfDefectVertexToEdgeVect: x(y) component of the
%                             vertex to edge direction vector of a minus half defect, corresponding to the
%                             X and YDIWwindow (normalised vector)


%NOTE: 
%all angles involved here are nematic angles Specifically:
% 1st quadrant Vector [0,pi/2] = Nem [0,pi/2], 
% 2nd quadrant Vecotr (pi/2 , pi] = Nem (-pi/2 ,0],
% 3rd quadrant Vector (-pi, -pi/2) = Nem (0,pi/2)
% 4th quadrant Vector [-pi/2, 0] = Nem [-pi/2,0]
%In Practice, its very easy... just take Nem Angle =atan(y/x)



function [NormXmhalfDefectVertexToEdgeVect,NormYmhalfDefectVertexToEdgeVect]=GetmhalfDefectOrientation(xphdcentre,yphdcentre,NemAngleListCW,XPositionNemList,YPositionNemList)
dum=size(NemAngleListCW);
oppositeGpInterval = round(dum(1,1)/2);

XPosCorVectList=xphdcentre-XPositionNemList; %position to core vector, x component
YPosCorVectList=yphdcentre-YPositionNemList; %position to core vector, y component
PosCorVectAngleList=atan(YPosCorVectList./XPosCorVectList);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%%Start searching for the vertex to edge vector
RatioRelCgDirPosToCore=zeros(dum(1,1),1);   %for taking ratio of RelCgDirPosToCore Opposite(edge)/current(vertex)

for i=1:dum(1,1)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %For that particular single director
    
    gp1index=mod((i-1)+0,dum(1,1))+1;
    sum1RelCgDirPosToCor=GetAbsSmallestRelCg(PosCorVectAngleList(gp1index,1),NemAngleListCW(gp1index,1));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %For opposite particular single director
    
    gp2index=mod((i+(oppositeGpInterval+1)-1)+0,dum(1,1))+1;
    sum2RelCgDirPosToCor= GetAbsSmallestRelCg(PosCorVectAngleList(gp2index,1),NemAngleListCW(gp2index,1));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
    
    RatioRelCgDirPosToCore(i,1)=sum2RelCgDirPosToCor/sum1RelCgDirPosToCor;
end

%now need to find the VertexToEdge pair , find the corresponding x,y
%for max value of RatioRelCgDirPosToCor. If there are more than one
%positions havin the max, then take the mean x
temp=[RatioRelCgDirPosToCore,XPositionNemList,YPositionNemList];
a=temp(temp(:,1)==max(RatioRelCgDirPosToCore),:);
xtail=mean(a(:,2));   %taking average because there could be more than one position with the same max ratio - eventhough very unlikely
ytail=mean(a(:,3));
NormVertexToEdgeVect=[xphdcentre-xtail;yphdcentre-ytail]/sqrt((xphdcentre-xtail)^2+(yphdcentre-ytail)^2);
NormXmhalfDefectVertexToEdgeVect=NormVertexToEdgeVect(1,1);
NormYmhalfDefectVertexToEdgeVect=NormVertexToEdgeVect(2,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

