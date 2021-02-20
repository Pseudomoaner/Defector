function featureStruct = prepareTrackStruct(trackSettings)
%PREPARETRACKSTRUCT creates a structure that defines how each feature
%selected by the user should be read and interpreted from the
%CellFeatures.mat file output by the feature detection module.
%
%   INPUTS:
%       -trackSettings: Structure containing user-defined settings for how
%       the diffusion tracker GUI should be applied. Includes feature
%       selections.
%
%   OUTPUTS:
%       -featureStruct: Structure defining whether each selected feature is
%       linear or circular, and where they can be found in the
%       trackableData structure of CellFeatures.mat.
%
%   Author: Oliver J. Meacock (c) 2019

%I have a general desire to incorporate velocity based tracking at some stage... but not to begin with.

featureStruct = struct();

if trackSettings.Centroid == 1
    featureStruct.('Centroid').('Locations') = [1,2]; %Locations tells it where to look in the PCs.Cells(i).(featurename)(x) call, where x is replaced by the numbers shown here.
    featureStruct.Centroid.('StatsType') = 'Linear'; %Linear or circular - alters how differences are calculated later on.
end

% Velocity tracking isn't used at the moment - reserved code for potential
% future release.
%
% if trackSettings.Velocity == 1 
%     featureStruct.('Velocity').('Locations') = [1,2]; %Locations tells it where to look in the PCs.Cells(i).(featurename)(x) call, where x is replaced by the numbers shown here.
%     if trackSettings.divDect
%         featureStruct.Centroid.('postDivScale') = @(x,c) [x(3), x(4);x(3), x(4)]; %Function handle that tells it how much to expect the value to change after division. x is the vector of linear features, c the vector of circular features.
%     end
%     featureStruct.Centroid.('StatsType') = 'Linear'; %Linear or circular - alters how differences are calculated later on.
% end

if trackSettings.Area == 1
    featureStruct.('Area').('Locations') = 1;
    featureStruct.Area.('StatsType') = 'Linear';
end

if trackSettings.Length == 1
    featureStruct.('Length').('Locations') = 1;
    featureStruct.Length.('StatsType') = 'Linear';
end

if trackSettings.Width == 1
    featureStruct.('Width').('Locations') = 1;
    featureStruct.Width.('StatsType') = 'Linear';
end

if trackSettings.Orientation == 1
    featureStruct.('Orientation').('Locations') = 1;
    featureStruct.Orientation.('StatsType') = 'Circular';
    featureStruct.Orientation.('Range') = [-90 90]; %Only needs to be defined for circular statistics - the lower and upper bounds of the statistic (wraps around from one to the other).
end

if ~isempty(trackSettings.MeanInc)
    logicAvail = false(size(trackSettings.availableMeans));
    logicUsed = false(size(trackSettings.MeanInc));
    logicAvail(trackSettings.availableMeans) = true;
    logicUsed(trackSettings.MeanInc) = true;
    
    featureStruct.('ChannelMean').('Locations') = find(logicUsed(logicAvail));
    featureStruct.ChannelMean.('StatsType') = 'Linear';
end

if ~isempty(trackSettings.StdInc)
    logicAvail = false(size(trackSettings.availableStds));
    logicUsed = false(size(trackSettings.StdInc));
    logicAvail(trackSettings.availableStds) = true;
    logicUsed(trackSettings.StdInc) = true;
    
    featureStruct.('ChannelStd').('Locations') = find(logicUsed(logicAvail));
    featureStruct.ChannelStd.('StatsType') = 'Linear';
end

if trackSettings.SpareFeat1 == 1
    featureStruct.('SpareFeat1').('Locations') = 1;
    featureStruct.SpareFeat1.('StatsType') = 'Linear';
end

if trackSettings.SpareFeat2 == 1
    featureStruct.('SpareFeat2').('Locations') = 1;
    featureStruct.SpareFeat2.('StatsType') = 'Linear';
end

if trackSettings.SpareFeat3 == 1
    featureStruct.('SpareFeat3').('Locations') = 1;
    featureStruct.SpareFeat3.('StatsType') = 'Linear';
end

if trackSettings.SpareFeat4 == 1
    featureStruct.('SpareFeat3').('Locations') = 1;
    featureStruct.SpareFeat4.('StatsType') = 'Linear';
end