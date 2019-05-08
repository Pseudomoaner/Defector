%IDEA: 
%To get the Tail to head vector of a plus half defect, notice that at the
%tails, the directors are more or less pointing in the same (nem)direction as
%that of the direction of the line linking its own position with the defect
%core. In other words, the 'smallest absolute relative change in direction' between the 'director direction' and the 'positionToCore direction' (herein named as RelCgDirPosToCore) is small.
%THe exact definition for RelCgDirPosToCore is the absolute value of that defined in %Method to obtain winding number is refered from (in appendix a): 
% Huterer et al. - Distribution of singularities in the cosmic
% microwave background polarization - PRD 72, 043004 (2005)


%For the head, directors are pointing in a more perpendicular direction compared to positionToCore direction. So the RelCgDirPosToCore is big.

%Hence to determine a pair (tail, head), we check opposite pairs of groups
%of consecutive directors (by default always 3 directors in consecutive).
%We take the ratio of RelCgDirPosToCore for each pair (head/tail). 
%The pair with the highest ratio of RelCgDirPosToCore, will be the tail to head vector, with the tail being the group with the smaller RelCgDirPosToCore value. 


%INPUT:
%NemAngleListCW: (in column form) gives  the angles in radians(vector angle wrt to some fixed axis - THE RANGE OF THE ANGLES must be within pi, e.g. [-pi/2,pi/2], [0,pi] etc.) of individual points,
%               gotten from travelling CLOCKWISE around a reference point. In the paper,
%                the range of angles was given as  [-pi/2,pi/2] 
%               These pts, form a squarish boundary (of boxes) around the core, with
%               number of boxes at the sides to be 3,4,5,etc. For side box numbers of 3, size(NemAngleListCW) will be 8, for 4, it will be 12 etc. 
%X(Y)PositionNemList:  x(y) location of the corresponding nem directors in the NemAngleListCW.
%x(y)phdcentre: x(y) location of plus half defect core centre.


%OUTPUT:
%NormX(Y)phalfDefectTailToHdVect: x(y) component of the
%                             head to tail direction vector of a plus half defect, corresponding to the
%                             X and YDIWwindow (normalised vector)


%NOTE: 
%all angles involved here are nematic angles Specifically:
% 1st quadrant Vector [0,pi/2] = Nem [0,pi/2], 
% 2nd quadrant Vecotr (pi/2 , pi] = Nem (-pi/2 ,0],
% 3rd quadrant Vector (-pi, -pi/2) = Nem (0,pi/2)
% 4th quadrant Vector [-pi/2, 0] = Nem [-pi/2,0]
%In Practice, its very easy... just take Nem Angle =atan(y/x)


function [NormXphalfDefectTailToHdVect,NormYphalfDefectTailToHdVect]=GetphalfDefectOrientation(xphdcentre,yphdcentre,NemAngleListCW,XPositionNemList,YPositionNemList)
dum=size(NemAngleListCW);
oppositeGpInterval = round(dum(1,1)/2);

XPosCorVectList=xphdcentre-XPositionNemList; %position to core vector, x component
YPosCorVectList=yphdcentre-YPositionNemList; %position to core vector, y component
PosCorVectAngleList=atan(YPosCorVectList./XPosCorVectList);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%%Start searching for the tail-head vector
RatioRelCgDirPosToCore=zeros(dum(1,1),1);   %for taking ratio of RelCgDirPosToCore Opposite/current

for i=1:dum(1,1)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %For three consecutive directors
    gp1lindex=mod((i-1)-1,dum(1,1))+1;   %left
    gp1mindex=mod((i-1)+0,dum(1,1))+1;   %middle
    gp1rindex=mod((i-1)+1,dum(1,1))+1;   %right
    
    sum1RelCgDirPosToCor=GetAbsSmallestRelCg(PosCorVectAngleList(gp1mindex,1),NemAngleListCW(gp1lindex,1))+...
        GetAbsSmallestRelCg(PosCorVectAngleList(gp1mindex,1),NemAngleListCW(gp1mindex,1))+...
        GetAbsSmallestRelCg(PosCorVectAngleList(gp1mindex,1),NemAngleListCW(gp1rindex,1)); %always compare the three nem angles with the middle vector angle linking position and core.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %For opposite three consecutive directors
    gp2lindex=mod((i+(oppositeGpInterval+1)-1)-1,dum(1,1))+1;  %left
    gp2mindex=mod((i+(oppositeGpInterval+1)-1)+0,dum(1,1))+1; %middle
    gp2rindex=mod((i+(oppositeGpInterval+1)-1)+1,dum(1,1))+1;  %right
    
    sum2RelCgDirPosToCor=GetAbsSmallestRelCg(PosCorVectAngleList(gp2mindex,1),NemAngleListCW(gp2lindex,1))+...
        GetAbsSmallestRelCg(PosCorVectAngleList(gp2mindex,1),NemAngleListCW(gp2mindex,1))+...
        GetAbsSmallestRelCg(PosCorVectAngleList(gp2mindex,1),NemAngleListCW(gp2rindex,1));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
    
    RatioRelCgDirPosToCore(i,1)=sum2RelCgDirPosToCor/sum1RelCgDirPosToCor; %Will produce a maximum peak where the opposite point is maximally misaligned and this point is maximally aligned (or at least the ratio between these two values is maximal)
end

%now need to find the tail-head pair , find the corresponding x,y
%for max value of RatioRelCgDirPosToCor. If there are more than one
%positions havin the max, then take the mean x
temp=[RatioRelCgDirPosToCore,XPositionNemList,YPositionNemList];
a=temp(temp(:,1)==max(RatioRelCgDirPosToCore),:); %
xtail=mean(a(:,2));   %taking average because there could be more than one position with the same max ratio - eventhough very unlikely
ytail=mean(a(:,3));
NormTailToHdVect=[xphdcentre-xtail;yphdcentre-ytail]/sqrt((xphdcentre-xtail)^2+(yphdcentre-ytail)^2);
NormXphalfDefectTailToHdVect=NormTailToHdVect(1,1);
NormYphalfDefectTailToHdVect=NormTailToHdVect(2,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end