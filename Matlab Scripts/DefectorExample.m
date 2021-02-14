clear all
close all

%%% START OF USER DEFINED VARIABLES %%%
Root = 'C:\Users\olijm\Desktop\DefectorTest'; %Root directory containing your raw images and 'Orientations' subdirectory.
startFrame = 0; %First timepoint to be included in analysis
endFrame = 9; %Final timepoint to be included in analysis

procSettings.minimumDist = 0; %Minimum radius for defects not to be considered annihilated. In physical units. 
procSettings.tensorSize = 2; %Spatial scale of the Gaussian filter used to define the orientation tensor.
procSettings.pixSize = 0.2; %The size of an individual pixel (on its side) in physical units

plotting = true; %Whether you wish to export overlays of defects on your original grayscale images.
plotSubDir = 'defOverlays'; %Name of the subdirectory (inside Root) you want to save the overlay images inside of
%%% END OF USER DEFINED VARIABLES %%%

noFrames = endFrame - startFrame + 1;
inDir = 'Channel_1';
imgName = 'Frame_%04d.tif';
outName = 'Defects.mat';
plotSubDir = 'DefectOverlays';

%Construct input file list
imgList = cell(endFrame-startFrame+1,1);
for i = startFrame:endFrame
    imgList{i-startFrame+1} = fullfile(Root,inDir,sprintf(imgName,i));
end

outFile = fullfile(Root,outName);

if plotting
    if ~exist(fullfile(Root,plotSubDir),'dir')
        mkdir(fullfile(Root,plotSubDir));
    end
end

[negDefCents,negDefOris,posDefCents,posDefOris] = Defector(imgList,procSettings,plotting,fullfile(Root,plotSubDir));

save(outFile,'posDefCents','negDefOris','posDefCents','posDefOris','procSettings');