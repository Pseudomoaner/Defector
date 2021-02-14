function pHalfOri = GetphalfDefectOrientation(x,y,NemAngleListCW,xNemList,yNemList)
%GETPHALFDEFECTORIENTATION finds the orientation of a +1/2 defect using the
%discrete Fourier transform.
%   
%   INPUTS:
%       -x,y: Coordinates of the defect core.
%       -NemAngleListCW: List of angles sampled from the orientation field
%       around the defect core in a clockwise direction. Use 
%       findParameterizedCirclePoints.m to do this sampling.
%       -xNemList,yNemList: Coordinates of the sampled positions.
%
%   Author: Oliver J. Meacock, (c) 2021

XPosCorVectList=x-xNemList; %position to core vector, x component
YPosCorVectList=y-yNemList; %position to core vector, y component

phiList = atan2(YPosCorVectList,XPosCorVectList);
FT = sum(exp(1i*phiList).*cos(2*NemAngleListCW)); %Fourier transform of the positional and orientational data
pHalfOri = rad2deg(-angle(FT));