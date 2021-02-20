function [procDefTracks,trackSettings] = DefectorTrack(pDposition,nDposition,pDorientation,nDorientation,tS,plotting,imgList,outImgDir)
%DEFECTORTRACK runs tracking on topological defect data using the FAST
%tracking framework.
%
%   INPUTS:
%       -pDposition, nDposition: Coordinates (in physical units) of the
%       positive and negative half defects. tx1 cell arrays of nx2 matrices,
%       with each of the n rows containing the x and y coordinates of a
%       given defect.
%       -pDorientation, nDorientation: Orientations (in degrees) of the
%       positive and negative half defects. tx1 cell arrays of nx1 vectors,
%       indexed in the same was as pDposition/nDposition (i.e. identical
%       indices correspond to a single defect).
%       -tS: User-defined settings for performing tracking. Structure
%       the fields incProp (training link inclusion fraction), tgtDensity
%       (the ambiguous link probability), dt (the timestep size in physical
%       units), minTrackLength (the minimum length of a track to be
%       included, in timesteps), pixSize (the physical size of a single
%       pixel) and imgHeight/imgWidth (the dimensions of the original
%       image, in physical units).
%       -plotting: Whether or not you want the output to be plotted on top
%       of the original images. Logical.
%       -imgList: Cell array containing strings defining paths to images
%       you wish to analyse. Output data will be in a set of cell arrays of
%       equal dimensions, one set of defects per image. Can be set to [] if
%       plotting is set to false.
%       -outImgDir: Location you want output overlays to be saved to. Set
%       to [] if plotting is set to false.
%
%   OUTPUTS:
%       -procDefTracks: The defect track data structure, following the
%       usual format of FAST tracks. Additional fields include population
%       (1 for +1/2 defects, 2 for -1/2 defects, 3 for inconsistent
%       topological charge) and sparefeat1, which contains the topological
%       charge data over time for the defect.
%       -trackSettings: The full trackSettings structure as used by FAST,
%       including all setting pre-defined by this function.
%
%   Author: Oliver J. Meacock, (c) 2021

%Loop over timepoints
for t = 1:size(pDorientation,1)
    %Each row of pDposition{t} and nDposition{t} contains the (x,y) coordinates of a single defect
    trackableData.Centroid{t} = [pDposition{t};nDposition{t}];
    %Similarly for defect orientation:
    trackableData.Orientation{t} = [pDorientation{t}/2;(3*nDorientation{t})/2]; %Need to adjust orientations so they vary between -90 and 90 degrees to interface with FAST (will remove transformation later) 
    %SpareFeat1 contains the defect charge information. Additional features MUST be called SpareFeat1, SpareFeat2 etc. in the trackable data structure to be read by the tracking module
    trackableData.SpareFeat1{t} = [ones(size(pDposition{t},1),1);-ones(size(nDposition{t},1),1)]; 
end

trackSettings.SpareFeat1 = 1;
trackSettings.Centroid = 1;
trackSettings.Orientation = 1;
trackSettings.Velocity = 0;
trackSettings.Length = 0;
trackSettings.Area = 0;
trackSettings.Width = 0;
trackSettings.noChannels = 0;
trackSettings.availableMeans = [];
trackSettings.availableStds = [];
trackSettings.MeanInc = [];
trackSettings.StdInc = [];
trackSettings.SpareFeat2 = 0;
trackSettings.SpareFeat3 = 0;
trackSettings.SpareFeat4 = 0;

trackSettings.incProp = tS.incProp;
trackSettings.tgtDensity = tS.tgtDensity;
trackSettings.gapWidth = 1;
trackSettings.maxFrame = size(pDorientation,1);
trackSettings.minFrame = 1;
trackSettings.minTrackLen = tS.minTrackLength;
trackSettings.frameA = 1;
trackSettings.statsUse = 'Centroid';
trackSettings.pseudoTracks = false; %Variable set to true in extractFeatureEngine.m if the 'tracks' have come from a single frame.

trackSettings.dt = tS.dt;
trackSettings.pixSize = tS.pixSize;
trackSettings.maxX = tS.imgWidth;
trackSettings.maxY = tS.imgHeight;
trackSettings.maxF = trackSettings.maxFrame;

debugSet = true; %Prevents modal locking of progress bars

[linkStats,featMats,featureStruct,possIdx] = gatherLinkStats(trackableData,trackSettings,debugSet);

%Build feature matrices
[featMats.lin,featMats.circ] = buildFeatureMatricesRedux(trackableData,featureStruct,possIdx,trackSettings.minFrame,trackSettings.maxFrame);

[Tracks,Initials] = doDirectLinkingRedux(featMats.lin,featMats.circ,featMats.lin,featMats.circ,linkStats,trackSettings.gapWidth,false,debugSet);

trackDataNames = fieldnames(trackableData);
rawTracks = struct();
for i = 1:size(trackDataNames,1)
    if i == 1
        [rawTracks.(trackDataNames{i}),trackTimes,rawToMappings,rawFromMappings] = extractDataTrack(Tracks,Initials,trackableData.(trackDataNames{i})(trackSettings.minFrame:trackSettings.maxFrame),true);
    else
        rawTracks.(trackDataNames{i}) = extractDataTrack(Tracks,Initials,trackableData.(trackDataNames{i})(trackSettings.minFrame:trackSettings.maxFrame),false);
    end
end

[procDefTracks,~,~] = processTracks(rawTracks,rawFromMappings,rawToMappings,trackSettings,trackTimes,debugSet);

%Assign tracks to two separate populations so you can easily use FAST's
%plotting methods
for i = 1:size(procDefTracks,2)
    if mean(procDefTracks(i).sparefeat1) == 1
        procDefTracks(i).population = 1;
        procDefTracks(i).phi = procDefTracks(i).phi*2; %Reverse the transformation you applied in line 8
    elseif mean(procDefTracks(i).sparefeat1) == -1
        procDefTracks(i).population = 2;
        procDefTracks(i).phi = procDefTracks(i).phi*2/3;
        procDefTracks(i).phi = procDefTracks(i).phi + (floor(rand(size(procDefTracks(i).phi))*3)-1)*120;
    else %If topological charge of tracked defect is mixed, mark as the anonymous population 3.
        procDefTracks(i).population = 3;
    end
end

progressbar(1)

if plotting
    figH = figure('Units','normalized','Position',[0.1,0.1,0.8,0.8],'visible','on');
    for i = 1:size(pDposition,1)
        drawTrackedDefectFrame(procDefTracks,tS,figH,imgList,outImgDir,i)
    end
end