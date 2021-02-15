function [dataTracks,trackTimes,toMappings,fromMappings] = extractDataTrack(Track,Initials,data,storeMappings)
%EXTRACTDATATRACK uses the output of the FAST tracking algorithm to assign
%the values in the 'slice' representation of the data to specific tracks.
%
%   INPUTS:
%       -Track: Cell array with one cell per frame of the input dataset,
%       with each cell containing an O by 2 matrix where O is the total
%       number of objects in that frame. Column 1 indicates the frame this
%       object links to, column 2 the object index within this frame.
%       Output by doDirectLinkingRedux.m
%       -Initials: Cell array with one cell per frame of the input dataset,
%       with each cell containing an O by 1 logical vector. Each element
%       indicates if the corresponding object is at the start of a track.
%       Output by doDirectLinkingRedux.m
%       -data: One field of trackableData, the main output of the feature
%       detection module (e.g. trackableData.Centroid,
%       trackableData.Orientation). Cell array with one cell per frame of
%       the input dataset, with each cell containing an O x F matrix where
%       F is the total number of values associated with the current
%       feature.
%       -storeMappings: Set true to store the forward and reverse mapping
%       structures (toMappings and fromMappings).
%
%   OUTPUTS:
%       -dataTracks: Cell array, with each cell containing a sequence of
%       values extracted from data for a single track. 
%       -trackTimes: Cell array, with each cell containing a vector for a
%       single track. This vector contains the frame indicies for each
%       timepoint in that track.
%       -toMappings and fromMappings provide the mappings to and from the
%       track representation and the frame representation. In the case of
%       this function, the following expressions should be true:
%
%           data{a}(b) = dataTracks{toMappings{a}(b,1)}(toMappings{a}(b,2))
%           dataTracks{c}(d) = data{fromMappings{c}(d,1)}(fromMappings{c}(d,2))
%
%   Author: Oliver J. Meacock (c) 2019

trackCount = 1;
dataTracks = {};
trackTimes = {};
fromMappings = {}; %Locations of each cell in the final track format in the original frame-by-frame data format

if storeMappings
    %Initialize the toMappings structure
    toMappings = cell(size(data)); %Locations of each cell in the original frame-by-frame data format in the final track format
    for i = 1:length(toMappings)
        toMappings{i} = nan(size(data{i},1),2);
    end
end

for i = 1:size(Track,1) %For each frame
    %Find the tracks starting in the current frame
    currInits = find(Initials{i});
    
    for j = 1:length(currInits) %For each track starting in this frame
        currTrack = data{i}(currInits(j),:);
        currTimes = i;
        
        if storeMappings
            toMappings{i}(currInits(j),:) = [trackCount,size(currTrack,1)]; %Format is trackID, position in list of cells in that track
        end
        
        nextPos = Track{i}(currInits(j),:);
        currMapping = [i,currInits(j)]; %Format is frame, position in list of cells at that frame
        while ~isnan(nextPos(1)) %Wind out each of those tracks to their end point
            currTrack = [currTrack; data{nextPos(1)}(nextPos(2),:)];
            
            if storeMappings
                currTimes = [currTimes, nextPos(1)];
                currMapping = [currMapping;nextPos];
                toMappings{nextPos(1)}(nextPos(2),:) = [trackCount,size(currTrack,1)];
            end
            
            nextPos = Track{nextPos(1)}(nextPos(2),:);
        end
        dataTracks{trackCount} = currTrack;
        
        if storeMappings
            trackTimes{trackCount} = currTimes;
            fromMappings{trackCount} = currMapping;
        end
        
        trackCount = trackCount + 1;
    end
end