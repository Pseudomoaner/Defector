function answ=calcs(diryp,dirzp,testPoints)
%CALCS calculates the topological charge field from the input director 
%field
%
%   INPUTS:
%       -diryp, dirzp: x and y-components of the director field at each
%       lattice point.
%       -testPoints: Logical matrix specifying locations where topological
%       defect cores might be located.
%
%   OUTPUTS:
%       -answ: Charge field with values of +0.5 at locations of +1/2 defect
%       cores and -0.5 at locations of -1/2 defect cores.
%
%   Authors: Oliver J. Meacock and Amin Doostmohammadi, (c) 2021

%Diryp and dirzp are the directors of the orientation field at a given point (x,y). Not sure why they're in (y,z) coordinates, but hey.
dry=diryp;
drz=dirzp;
[m,n]=size(dry);
wn=zeros(size(dry));

testList = find(testPoints(:));
[testX,testY] = ind2sub(size(testPoints),testList);
outerRim = or(or(testX == 1,testX == m),or(testY == 1,testY == n));
testX(outerRim) = [];
testY(outerRim) = [];

for ind = 1:size(testX,1)
    i = testX(ind);
    j = testY(ind);
    
    %Find the directors surrounding this pixel
    ax1=[dry(i+1,j) drz(i+1,j)]; %North
    ax2=[dry(i-1,j) drz(i-1,j)]; %South
    ax3=[dry(i,j-1) drz(i,j-1)]; %West
    ax4=[dry(i,j+1) drz(i,j+1)]; %East
    ax5=[dry(i+1,j-1) drz(i+1,j-1)]; %North-West
    ax6=[dry(i-1,j-1) drz(i-1,j-1)]; %South-West
    ax7=[dry(i+1,j+1) drz(i+1,j+1)]; %North-East
    ax8=[dry(i-1,j+1) drz(i-1,j+1)]; %South-East
    
    %Find the sum of the differences between adjacent pixels over
    %entire path
    dang=wang(ax1,ax5);
    dang=dang+wang(ax5,ax3);
    dang=dang+wang(ax3,ax6);
    dang=dang+wang(ax6,ax2);
    dang=dang+wang(ax2,ax8);
    dang=dang+wang(ax8,ax4);
    dang=dang+wang(ax4,ax7);
    dang=dang+wang(ax7,ax1);
    
    wn(i,j)=dang/2/pi;
end
answ=wn;
