function [procDefTracks,trackSettings] = DefectorTrack(pDposition,nDposition,pDorientation,nDorientation,tS)

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