function [negDefCents,negDefOris,posDefCents,posDefOris] = DefectorFind(imgList,procSettings,plotting,outImgDir)
%DEFECTORFIND performs detection of the locations and orientations of
%half-integer defects in the specified set of input images.
%
%   INPUTS:
%       -imgList: Cell array containing strings defining paths to images
%       you wish to analyse. Output data will be in a set of cell arrays of
%       equal dimensions, one set of defects per image.
%       -procSettings: Structure containing the fields tensorSize, pixSize
%       and minDist, defining the spatial scale of the Gaussian smoothing
%       filter (physical units), the physical size of a single pixel and
%       the 
%       -plotting: Whether or not you want the output to be plotted on top
%       of the original images. Logical.
%       -outImgDir: Location you want output overlays to be saved to. Set
%       to [] if plotting is set to false.
%
%   OUTPUTS:
%       -negDefCents: Location of the cores of the negative half
%       defects, in physical units.
%       -negDefOris: Orientation of the negative half defects, in degrees.
%       Between -60 and 60 degrees.
%       -posDefCents: Location of the cores of the positive half defects,
%       in physical units.
%       -posDefOris: Orientation of the positive half defects, in degrees.
%       Betwen -180 and 180 degrees.
%
%   Author: Oliver J. Meacock, (c) 2021

negDefCents = cell(size(imgList,1),1);
posDefCents = cell(size(imgList,1),1);
posDefOris = cell(size(imgList,1),1);
negDefOris = cell(size(imgList,1),1);

if plotting
    figH = figure('Units','normalized','Position',[0.1,0.1,0.8,0.8]);
end

for i = 1:size(imgList,1)
    imgDat = imread(imgList{i});
    oriDat = findImageOrients(imgDat,procSettings.tensorSize/procSettings.pixSize);
    
    oriX = cos(oriDat);
    oriY = -sin(oriDat);
    
    if plotting
        cla
        imagesc(imgDat)
        colormap('gray')
        axis equal
        axis tight
        hold on
    end
    
    [posDefCents{i},negDefCents{i},posDefOris{i},negDefOris{i}] = analyseDefects(oriX,oriY,procSettings.tensorSize/procSettings.pixSize,plotting);
    
    if plotting
        export_fig(fullfile(outImgDir,sprintf('Frame_%04d.tif',i)),'-nocrop')
    end
    
    posDefCents{i} = flip(posDefCents{i},2)*procSettings.pixSize;
    negDefCents{i} = flip(negDefCents{i},2)*procSettings.pixSize;
    
    progressbar(i/size(imgList,1))
end

progressbar(1)