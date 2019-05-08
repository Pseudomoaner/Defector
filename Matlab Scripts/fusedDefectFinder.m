clear all
close all

%%% START OF USER DEFINED VARIABLES %%%
Root = 'C:\Users\olijm\Desktop\Fingerprint'; %Root directory containing your raw images and 'Orientations' subdirectory.
startFrame = 0; %First timepoint to be included in analysis
endFrame = 0; %Final timepoint to be included in analysis
minimumDist = 0; %Minimum radius for defects not to be considered annihilated. In physical units. 
plotting = true; %Whether you wish to export overlays of defects on your original grayscale images.
oldOrientJ = false; %If input data is from the old version of OrientationJ (Possibly pre-v2? Certainly v2.0.4 and later produce the new format).
pxSize = 0.2; %The size of an individual pixel (on its side) in physical units
%%% END OF USER DEFINED VARIABLES %%%

noFrames = endFrame - startFrame + 1;
imgName = '\\Frame_%04d.tif';
oriName = '\\Orientations\\Frame_%04d.tif';
outName = '\Defects.mat';
plotSubDir = '\DefectOverlays';
plotName = '\\Frame_%04d.jpg';

if ~plotting
    progressbar;
end

outFile = [Root,outName];
minimumPxDist = minimumDist/pxSize;

negativeDefectStore = cell(round((endFrame-startFrame)),1);
positiveDefectStore = cell(round((endFrame-startFrame)),1);
posDefectOrientationStore = cell(round((endFrame-startFrame)),1);
negDefectOrientationStore = cell(round((endFrame-startFrame)),1);

if plotting
    if ~exist([Root,plotSubDir],'dir')
        mkdir([Root,plotSubDir]);
    end
end

for i = startFrame:endFrame
    frameInd = i - startFrame + 1;
    oriFile = [Root,sprintf(oriName,i)];
    imgFile = [Root,sprintf(imgName,i)];
    
    currOriDat = double(imread(oriFile));
    
    %Irritatingly, the new version of OrientationJ outputs in units of
    %radians (rather than degrees, as it used to). Choose trigonometric
    %functions accordingly.
    if oldOrientJ
        oriX = cosd(currOriDat);
        oriY = -sind(currOriDat);
    else
        oriX = cos(currOriDat);
        oriY = -sin(currOriDat);
    end
    
    if plotting
        %Plot the original cell image
        fig = figure(1);
        cla;
        frame = imread(imgFile);
        imshow(frame,[])
        ax = gca;
        ax.Position = [0,0,1,1];
        hold on
        fig.Position = [100,100,800,800];
        fig.Visible = 'off';
    end
    
    [positiveDefectStore{frameInd},negativeDefectStore{frameInd},posDefectOrientationStore{frameInd},negDefectOrientationStore{frameInd}] = analyseDefects(oriX,oriY,minimumPxDist,plotting);
    
    positiveDefectStore{frameInd} = positiveDefectStore{frameInd}*pxSize;
    negativeDefectStore{frameInd} = negativeDefectStore{frameInd}*pxSize;
    
    if plotting
        
        %Export the figure
        plotFile = [Root,plotSubDir,sprintf(plotName,i)];
        
        export_fig(plotFile,'-jpg','-m1','-nocrop')
        fprintf('Image %d of %d done.\n',frameInd,endFrame-startFrame+1)
    else
        progressbar((i - startFrame)/(endFrame-startFrame))
    end
    
    save(outFile,'positiveDefectStore','negativeDefectStore','posDefectOrientationStore','negDefectOrientationStore','pxSize');
end