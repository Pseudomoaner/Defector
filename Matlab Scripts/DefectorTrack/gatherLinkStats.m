function [linkStats,featMats,featureStruct,possIdx] = gatherLinkStats(trackableData,trackSettings,debugSet)
%GATHERLINKSTATS performs the model training stage of the tracking
%algorithm of FAST. 
%
%   INPUTS:
%       -trackableData: One of the elements of the CellFeatures.mat file,
%       output by the tracking module. Structure containing several cell
%       arrays, each of which contains the numerical values of a specific
%       feature for all objects in the current dataset.
%       -trackSettings: Structure created by the diffusionTracker GUI
%`      -debugSet: Set true if currently in debug mode, false if not
%   
%   OUTPUTS:
%       -linkStats: The statistics extracted from the current dataset.
%       Contains separate fields indicating the Extent, Mean displacement
%       (drift), standard Deviation and Reliability of each feature over
%       time. Circular and linear features are stored separately. Also
%       contains the trackability for the entire dataset.
%       -featMats: Slightly more neatly packaged version of the output of
%       the buildFeatureMatricesRedux function
%       -featureStruct: The output of the prepareTrackStruct function
%       -possIdx: A structure containing a unique ID for each object in the
%        dataset.
%   
%   Author: Oliver J. Meacock, (c) 2019

progressbar(0,0,0);

featureStruct = prepareTrackStruct(trackSettings);

featureNames = fieldnames(featureStruct);

%Begin by building a cell array with a unique index for each possible cell
possIdx = cell(trackSettings.maxFrame - trackSettings.minFrame + 1, 1);
for i = trackSettings.minFrame:trackSettings.maxFrame
    possIdx{i - trackSettings.minFrame + 1} = 1:size(trackableData.(featureNames{1}){i},1);
end

progressbar(0,0.2,0);

%Build feature matrices
[linFeatMats,circFeatMats] = buildFeatureMatricesRedux(trackableData,featureStruct,possIdx,trackSettings.minFrame,trackSettings.maxFrame);

progressbar(0,0.4,0);

%Get scaling factors for scoring stage
[covDfs,covFs,linMs,circMs,trackability] = getScalingFactors(linFeatMats,circFeatMats,trackSettings.incProp,trackSettings.statsUse);

progressbar(0,0.8,0);

%Pack up for export
featMats.lin = linFeatMats;
featMats.circ = circFeatMats;

linkStats.covDfs = covDfs;
linkStats.covFs = covFs;
linkStats.linMs = linMs;
linkStats.circMs = circMs;
linkStats.trackability = trackability;

%Calculate the detection thresholds
noFeats = size(covDfs,2);

linkStats.incRads = zeros(size(covDfs,1),1);
linkStats.noObj = zeros(size(covDfs,1),1);

constFac = ((12/pi)^(1/2))*(trackSettings.tgtDensity ^ (1/noFeats));
for i = 1:size(linkStats.covDfs,1)
    noObj = size(linFeatMats{i},1);
    detFac = (det(squeeze(covFs(i,:,:)))/det(squeeze(covDfs(i,:,:)))) ^ (1/(2*noFeats));
    gamFac = (gamma(1+noFeats/2))/(noObj-1) ^ (1/noFeats);
    linkStats.incRads(i) = constFac*detFac*gamFac;
    linkStats.noObj(i) = noObj;
end

progressbar(0.2,0,0);