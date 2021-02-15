clear all
close all

%%% START OF USER DEFINED VARIABLES %%%

%Input file information
Root = 'C:\Users\olijm\Desktop\WT_Turbulence'; %Root directory containing your raw images and 'Orientations' subdirectory.
startFrame = 0; %First timepoint to be included in analysis
endFrame = 600; %Final timepoint to be included in analysis

%Defect detection parameters
procSettings.minimumDist = 0; %Minimum radius for defects not to be considered annihilated. In physical units. 
procSettings.tensorSize = 1.6; %Spatial scale of the Gaussian filter used to define the orientation tensor.
procSettings.pixSize = 0.0718; %The size of an individual pixel (on its side) in physical units

plotting = false; %Whether you wish to export overlays of defects on your original grayscale images.
plotSubDir = 'defOverlays'; %Name of the subdirectory (inside Root) you want to save the overlay images inside of

%Defect tracking parameters
trackSettings.incProp = 0.8; %Inclusion proportion for the model training stage of the defect tracking
trackSettings.tgtDensity = 1e-3; %Normalized displacement space distance threshold for the link assignment stage of the defect tracking.
trackSettings.minTrackLength = 10; %Minimum length of a track to be included in final version of dataset
trackSettings.pixSize = procSettings.pixSize;
trackSettings.dt = 1; %Timestep between frames, in physical units
trackSettings.imgHeight = 147.0205; %Height of the images, in physical units
trackSettings.imgWidth = 147.0205; %Width of the images, in physcical units

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

[negDefCents,negDefOris,posDefCents,posDefOris] = DefectorFind(imgList,procSettings,plotting,fullfile(Root,plotSubDir));

save(outFile,'posDefCents','posDefOris','negDefCents','negDefOris','procSettings');

[procDefTracks] = DefectorTrack(posDefCents,negDefCents,posDefOris,negDefOris,trackSettings);

save(outFile,'procDefTracks','trackSettings','-append')