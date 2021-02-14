function orients = findImageOrients(img,SD)
%FINDIMAGEORIENTS uses the tensor method algorithm to determine the local
%director field in a given image.
%
%   INPUTS:
%       -img: Grayscale image you wish to find director field of
%       -SD: Standard eviation of Gaussian filter used to specify the
%       spatial scale at which the orientation field is being measured.
%
%   OUTPUTS:
%       -orients: Director field of same size as img.
%
%   Author: Oliver J. Meacock, (c) 2021
 
[gX,gY] = imgradientxy(img);
Ixx = gX.*gX;
Iyy = gY.*gY;
Ixy = gX.*gY;

tIxx = imgaussfilt(Ixx,SD,'FilterSize',2*ceil(SD*8)+1); %Extra filter size should suffice to ensure smoothness of image gradients (i.e. no zero values)
tIyy = imgaussfilt(Iyy,SD,'FilterSize',2*ceil(SD*8)+1);
tIxy = imgaussfilt(Ixy,SD,'FilterSize',2*ceil(SD*8)+1);

orients = 0.5 * atan2(2*tIxy,tIyy-tIxx);