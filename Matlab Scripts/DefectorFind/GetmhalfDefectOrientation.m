function mHalfOri =GetmhalfDefectOrientation(xphdcentre,yphdcentre,NemAngleListCW,XPositionNemList,YPositionNemList)
%GETMHALFDEFECTORIENTATION finds the orientation of a -1/2 defect using the
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

XPosCorVectList=xphdcentre-XPositionNemList; %position to core vector, x component
YPosCorVectList=yphdcentre-YPositionNemList; %position to core vector, y component

phiList = atan2(YPosCorVectList,XPosCorVectList);
FT = sum(exp(1i*phiList).*cos(2*NemAngleListCW)); %Fourier transform of the positional and orientational data
mHalfOri = rad2deg(angle(FT))/3;