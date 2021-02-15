function [linearFeatureMatrices,circularFeatureMatrices] = buildFeatureMatricesRedux(TrackableData,Features,possIdx,minFrame,maxFrame)
%BUILDFEATUREMATRICESREDUX converts the user-friendly feature storage
%structure into a machine readable matrix format.
%
%   INPUTS:
%       -TrackableData: A structure containing multiple fields, each
%       corresponding to a unique feature. Each consists of a tx1 cell
%       array, with each cell containing the totality of feature data for
%       that timepoint.
%       -Features: A feature matrix formatting structure, output by
%       prepareTrackStruct.m
%       -possIdx: A structure containing a unique ID for each object in the
%       dataset
%       -minFrame: The earliest frame to be included in the constructed
%       matrix set
%       -maxFrame: The latest frame to be included in the constructed
%       matrix set
%
%   OUTPUTS:
%       -linearFeatureMatrices: Feature matrices for the linear features
%       (e.g. position, length)
%       -circularFeatureMatrices: Feature matrices for the circular
%       features (e.g. orientation, direction of motion)
%
%   Author: Oliver J. Meacock, (c) 2019

linearFeatureMatrices = cell(length(possIdx),1);
circularFeatureMatrices = cell(length(possIdx),1);
featureNames = fieldnames(Features);

%Get information about the different features to be used (defined in the feature matrix)
linFeatNo = 0;
circFeatNo = 0;
for i = 1:length(featureNames)
    switch Features.(featureNames{i}).StatsType
        case 'Linear'
            for l = 1:length(Features.(featureNames{i}).Locations)
                linFeatNo = linFeatNo + 1;
            end
        case 'Circular'
            for l = 1:length(Features.(featureNames{i}).Locations)
                circFeatNo = circFeatNo + 1;
            end
    end
end

for i = minFrame:maxFrame %For each frame
    frameIdxs = possIdx{i-minFrame+1};
    for j = 1:length(frameIdxs) %For all objects in this frame
        currCell = frameIdxs(j);
        linearFeatures = zeros(1,linFeatNo + 1);
        circularFeatures = zeros(1,circFeatNo + 1);
        linearFeatures(1) = currCell;
        circularFeatures(1) = currCell;
        linFeatCount = 0;
        circFeatCount = 0;
        for l = 1:length(featureNames)
            switch Features.(featureNames{l}).StatsType
                case 'Linear'
                    for k = 1:length(Features.(featureNames{l}).Locations)
                        linFeatCount = linFeatCount + 1;
                        linearFeatures(linFeatCount+1) = TrackableData.(featureNames{l}){i}(j,k);
                    end
                case 'Circular'
                    for k = 1:length(Features.(featureNames{l}).Locations)
                        circFeatCount = circFeatCount + 1;
                        circularFeatures(circFeatCount+1) = (TrackableData.(featureNames{l}){i}(j,k) + Features.(featureNames{l}).Range(2))/(Features.(featureNames{l}).Range(2) - Features.(featureNames{l}).Range(1)); %Last bit scales values to between 0 and 1.
                    end
            end
        end
        linearFeatureMatrices{i-minFrame+1} = [linearFeatureMatrices{i-minFrame+1};linearFeatures];
        circularFeatureMatrices{i-minFrame+1} = [circularFeatureMatrices{i-minFrame+1};circularFeatures];
    end
end