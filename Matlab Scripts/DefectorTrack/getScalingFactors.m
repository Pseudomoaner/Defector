function [covDfs,covFs,linMs,circMs,trackability] = getScalingFactors(linFeatMats,circFeatMats,includeProportion,statsUse)
%GETSCALINGFACTORS calculates the covariance matrices for the instantaneous
%feature distributions (f) and displacements (Delta f) for each timepoint.
%Also calculates the average 'drift' between frames (the mean of Delta f)
%and the 'trackability score' (the amount of information available per object).
%
%   INPUTS:
%       -linFeatMats: Cell array, containing matrices of all linear
%       features for each timepoint.
%       -circFeatMats: Cell array, containing matrices of all circular
%       features for each timepoint.
%       -includeProportion: User-defined proportion of highest-scoring
%       low-quality links that should be included during the calculation of
%       summary statistics.
%       -statsUse: Whether the full range of available features should be
%       used during model training, or just the centroid
%
%   OUTPUTS:
%       -covDfs: Time-dependent covariance matrices of the feature displacements
%       -covFs: Time-dependent covariance matrices of the initial feature distribution
%       -linMs: Drifts (means) of the linear features
%       -circMs: Drifts of the circular features
%       -trackability: Trackability score for each timepoint
%
%       For more details on these statistics, please see:
%       https://mackdurham.group.shef.ac.uk/FAST_DokuWiki/dokuwiki/doku.php?id=usage:tracking_algorithm
%
%   Author: Oliver J. Meacock (c) 2019

%Find the full range of values that each of the linear variables can take
allFeats = [];
for i = 1:length(linFeatMats)
    allFeats = [allFeats;linFeatMats{i}(:,2:end),circFeatMats{i}(:,2:end)];
end
minFeats = min(allFeats(:,1:size(linFeatMats{1},2)-1),[],1);
maxFeats = max(allFeats(:,1:size(linFeatMats{1},2)-1),[],1);
noFeats = size(allFeats,2);

groupedMat = [];

%Construct the training dataset
for i = 1:length(linFeatMats) - 1 %Loop over time indices
    if ~isempty(linFeatMats{i}) && ~isempty(linFeatMats{i+1})
        linFrame1 = linFeatMats{i}(:,2:end);
        linFrame2 = linFeatMats{i+1}(:,2:end);
        if size(circFeatMats{i},2) > 1
            circFrame1 = circFeatMats{i}(:,2:end);
            circFrame2 = circFeatMats{i+1}(:,2:end);
        else
            circFrame1 = zeros(size(circFeatMats{i},1),1);
            circFrame2 = zeros(size(circFeatMats{i+1},1),1);
        end
        
        %Regularize the linear data, so it varies between 0 and 1. Is an approximate way of weighting all features equally, so you can get estimates of the statistics you need to weigh them more accurately later.
        linFrame1Reg = (linFrame1 - repmat(minFeats,size(linFrame1,1),1))./(repmat(maxFeats,size(linFrame1,1),1) - repmat(minFeats,size(linFrame1,1),1));
        linFrame2Reg = (linFrame2 - repmat(minFeats,size(linFrame2,1),1))./(repmat(maxFeats,size(linFrame2,1),1) - repmat(minFeats,size(linFrame2,1),1));
        
        %Decide if user wants to use all features or just the centroid
        switch statsUse
            case 'Centroid'
                D = pdist2(linFrame1Reg(:,1:2),linFrame2Reg(:,1:2));
            case 'All'
                D1 = pdist2(linFrame1Reg,linFrame2Reg);
                D2 = pdistCirc2(circFrame1,circFrame2,ones(size(circFrame1,2),1));
                
                D = (D1.^2 + D2.^2).^0.5;
        end
        
        %Find the minimum distance between each Frame1 point and all Frame2 points
        [distsTmp,locsF2] = min(D,[],2); %locsF2 is the row of each cell in frame 2
        locsF1 = (1:size(D,1))'; %Take a guess
        
        groupedMat = [groupedMat;distsTmp,locsF1,locsF2,i*ones(size(distsTmp))];
    end
end

%Extract the multivariate statistics required by later sections
linMs = zeros(length(linFeatMats) - 1,size(linFeatMats{1},2) - 1);
circMs = zeros(length(linFeatMats) - 1,size(circFeatMats{1},2) - 1);
covDfs = zeros(length(linFeatMats) - 1,noFeats,noFeats);
covFs = zeros(length(linFeatMats) - 1,noFeats,noFeats);
trackability = zeros(length(linFeatMats) - 1,1);

for i = 1:size(linFeatMats,1) - 1 %Loop over time again
    if size(linFeatMats{i},1) <= 1 %If no (or only a single object) in frame, don't really care about doing adjustments. Tracking should be obvious. Set measures to be very unstringent (but not e.g. Inf, as they would be if you didn't deal with this special case)
        trackability(i) = NaN;
        
        covDfs(i,:,:) = eye(noFeats)*0.001;
        covFs(i,:,:) = eye(noFeats)*100;
        linMs(i,:) = 0;
        circMs(i,:) = 0;
    else
        currMatInds = groupedMat(:,4) == i;
        subMat = groupedMat(currMatInds,:);
        sortedSubMat = sortrows(subMat,1); %Sort by distance
        
        %Assume the n% closest objects are accurately linked - base extracted parameters on these links.
        goodSubInds = 1:round(size(sortedSubMat,1)*includeProportion);
        if numel(goodSubInds) < 2 %To calculate a covariance matrix, you need at least two samples.
            goodSubInds = 1:2;
        end
        goodSubF1 = sortedSubMat(goodSubInds,2);
        goodSubF2 = sortedSubMat(goodSubInds,3);
        goodSubFrameNo = sortedSubMat(goodSubInds,4);
        goodSubFeatureDiffs = zeros(length(goodSubInds),noFeats);
        goodSubFeatures = zeros(length(goodSubInds),noFeats);
        badInds = [];
        for j = goodSubInds
            %f (instantaneous feature positions)
            goodSubFeatures(j,1:size(linFeatMats{1},2)-1) = linFeatMats{goodSubFrameNo(j)}(goodSubF1(j),2:end);
            goodSubFeatures(j,size(linFeatMats{1},2):end) = circFeatMats{goodSubFrameNo(j)}(goodSubF1(j),2:end);
            
            %Delta f (feature displacements)
            goodSubFeatureDiffs(j,1:size(linFeatMats{1},2)-1) = linFeatMats{goodSubFrameNo(j)}(goodSubF1(j),2:end) - linFeatMats{goodSubFrameNo(j)+1}(goodSubF2(j),2:end);
            circSubDiff = circFeatMats{goodSubFrameNo(j)}(goodSubF1(j),2:end) - circFeatMats{goodSubFrameNo(j)+1}(goodSubF2(j),2:end);
            goodSubFeatureDiffs(j,size(linFeatMats{1},2):end) = mod(circSubDiff + 0.5,1) - 0.5;
            
            if sum(isnan(goodSubFeatureDiffs(j,:)))>0 %If you've got any NaNs in this frame, exclude them (can occur if you have badly extracted object features)
                badInds = [badInds;j];
            end
        end
        goodSubFeatureDiffs(badInds,:) = [];
        goodSubFeatures(badInds,:) = [];
        
        %Calculate and store covariance matrices
        covDfs(i,:,:) = cov(goodSubFeatureDiffs);
        covFs(i,:,:) = cov(goodSubFeatures);
        
        %Calculate and store mean vectors for Delta f
        linMs(i,:) = mean(goodSubFeatureDiffs(:,1:size(linFeatMats{1},2)-1),1);
        tmp = goodSubFeatureDiffs(:,size(linFeatMats{1},2):end);
        if ~isempty(tmp)
            circMs(i,:) = circ_mean(tmp,[],1);
        end
    end
end

%If a feature is particularly stable (often true for discrete features),
%some components of the associated covariance matrices may be zero, which
%can cause them to be singular. As we divide by their determinants later for various purposes, we
%need to avoid this. The following code removes these zero values and
%replaces them with small but finite elements.

minDf = inf;
minF = inf;
for i = 1:size(linFeatMats,1) - 1
    currDf = squeeze(covDfs(i,:,:));
    currDf(currDf == 0) = inf;
    currMinDf = min(abs(diag(currDf)));
    if currMinDf < minDf
        minDf = currMinDf;
    end
    
    currF = squeeze(covFs(i,:,:));
    currF(currF == 0) = inf;
    currMinF = min(abs(diag(currF)));
    if currMinF < minF
        minF = currMinF;
    end
end

for i = 1:size(linFeatMats,1) - 1
    currDf = squeeze(covDfs(i,:,:));
    if det(currDf) == 0
        diagZeros = find(diag(currDf) == 0);
        covDfs(i,diagZeros,diagZeros) = minDf; %Using the minimal finite diagonal value ensures artificially inserted value is of similar OOM to actual data
    end
    
    currF = squeeze(covFs(i,:,:));
    if det(currF) == 0
        diagZeros = find(diag(currF) == 0);
        covFs(i,diagZeros,diagZeros) = minF;
    end
    
    %Calculate and store trackability score
    detFrac = det(squeeze(covFs(i,:,:)))/det(squeeze(covDfs(i,:,:)));
    distFac = log2(pi*exp(1)/6);
    trackability(i) = (1/2)*log2(detFrac) - (noFeats/2)*distFac - log2(size(linFeatMats{i},1));
end