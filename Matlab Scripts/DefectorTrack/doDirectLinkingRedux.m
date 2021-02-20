function [Tracks,Initials,fromLinFeatMats,fromCircFeatMats,toLinFeatMats,toCircFeatMats,acceptDiffs,rejectDiffs] = doDirectLinkingRedux(fromLinFeatMats,fromCircFeatMats,toLinFeatMats,toCircFeatMats,linkStats,gapSize,returnSteps,debugSet)
%DODIRECTLINKINGREDUX performs object-object linking based on minimisation
%of the distance between sequential objects in the normalised displacement
%space.
%
%   INPUTS:
%       -fromLinFeatMats: Feature matrices for the linear features
%       (e.g. position, length). Output from gatherLinkStats.m.
%       -fromCircFeatMats: Feature matrices for the circular features
%       (e.g. orientation, direction of motion). Output from 
%       gatherLinkStats.m.
%       -toLinFeatMats: Feature matrices for the linear features. Typically
%       identical to fromLinFeatMats initially, but is eventually modified.
%       -toCircFeatMats: Feature matrices for the circular features. Typically
%       identical to fromCircFeatMats initially, but is eventually modified.
%       -linkStats: Statistics necessary for normalisation of features
%       provided in fromLinFeatMats and fromCircFeatMats. Output from
%       gatherLinkStats
%       -gapSize: User-defined maximal gap (in frames) that can be bridged
%       by the algorithm.
%       -returnSteps: Set true to return the displacements (in the normalised
%       feature space) of the positive and negative links. Used for
%       plotting projections of the normalised displacement space.
%       -debugSet: Set true if FAST is in debug mode.
%
%   OUTPUTS:
%       -Tracks: Cell array with one cell per frame of the input dataset,
%       with each cell containing an O by 2 matrix where O is the total
%       number of objects in that frame. Column 1 indicates the frame this
%       object links to, column 2 the object index within this frame. Use
%       extractDataTrack.m to convert to a more standard data track format.
%       -Initials: Cell array with one cell per frame of the input dataset,
%       with each cell containing an O by 1 logical vector. Each element
%       indicates if the corresponding object is at the start of a track.
%       Used by extractDataTrack.m.
%       -fromLinFeatMats: Feature matrices for linear features. This
%       version has had all objects assigned FROM deleted.
%       -fromCircFeatMats: Feature matrices for circular features. This
%       version has had all objects assigned FROM deleted.
%       -toLinFeatMats: Feature matrices for linear features. This
%       version has had all objects assigned TO deleted.
%       -toCircFeatMats: Feature matrices for circular features. This
%       version has had all objects assigned TO deleted.
%       -acceptDiffs:Displacements (in normalised feature space) of the 
%       accepted links. Undefined if returnSteps is set to false.
%       -rejectDiffs: Displacements (in normalised feature space) of the 
%       rejected links. Undefined if returnSteps is set to false.
%
%   Author: Oliver J. Meacock (c) 2019

%Preallocate tracks
Tracks = cell(size(fromLinFeatMats));
Initials = cell(size(fromLinFeatMats));
for i = 1:size(fromLinFeatMats,1)
    Tracks{i} = nan(size(fromLinFeatMats{i},1),2);
    Initials{i} = true(size(fromLinFeatMats{i},1),1);
end

if returnSteps %If the user wants to inspect the (normalized) steps calculated during this part of the algorithm
    acceptDiffs = [];
    rejectDiffs = [];
end

%Unpack the linkStats structure (to reduce line lengths later)
covDfs = linkStats.covDfs; 
linMs = linkStats.linMs;
circMs = linkStats.circMs;
incRads = linkStats.incRads;

progressbar(0.4,0,0);

for j = 1:gapSize
    for i = 1:length(fromLinFeatMats) - j        
        %If this is the first pass (i.e. the gap size is one) and the
        %covariance matrix is poorly constrained (here, if there are fewer
        %objects in this frame than there are independent elements of the covariance
        %matrix), just run with a nearest neighbour approach. Should be
        %sufficiently uncrowded for this to work.
        if j == 1 && (size(covDfs,2)*(size(covDfs,2)+1))/2 > size(fromLinFeatMats{i},1)
            pos1 = fromLinFeatMats{i}(:,2:3);
            pos2 = toLinFeatMats{i+j}(:,2:3);
            D = pdist2(pos1,pos2);
            
            [~,minInd] = min(D(:));
            
            while ~isempty(D)
                %Find the minimum distance between frames at the moment
                [Ind1,Ind2] = ind2sub(size(D),minInd);
                frame1Loc = fromLinFeatMats{i}(Ind1,1);
                frame2Loc = toLinFeatMats{i+j}(Ind2,1);
                
                %Eliminate from distance matrix and feature matrices, and link cells.
                fromLinFeatMats{i}(Ind1,:) = [];
                fromCircFeatMats{i}(Ind1,:) = [];
                toLinFeatMats{i+j}(Ind2,:) = [];
                toCircFeatMats{i+j}(Ind2,:) = [];
                D(Ind1,:) = [];
                D(:,Ind2) = [];
                
                Tracks{i}(frame1Loc,1) = i + j;
                Tracks{i}(frame1Loc,2) = frame2Loc;
                Initials{i+j}(frame2Loc) = 0;
                
                [~,minInd] = min(D(:));
            end
            progressbar(0.4+((j-1)/gapSize)*0.2,(i-1)/(length(fromLinFeatMats) - j),1)
        elseif ~isempty(fromLinFeatMats{i}) && ~isempty(toLinFeatMats{i+j})
            linFrame1 = fromLinFeatMats{i}(:,2:end);
            linFrame2 = toLinFeatMats{i+j}(:,2:end) + repmat(sum(linMs(i:i+j-1,:),1),size(toLinFeatMats{i+j},1),1);
            fullLin1 = repmat(reshape(linFrame1,[size(linFrame1,1),1,size(linFrame1,2)]),[1,size(toLinFeatMats{i+j},1),1]);
            fullLin2 = repmat(reshape(linFrame2,[1,size(linFrame2,1),size(linFrame2,2)]),[size(fromLinFeatMats{i},1),1,1]);
            
            if ~ isempty(circMs) %Note that buildFeatureMatricesRedux already scaled circular features between 0 and 1, so can set that as the 'seam' for the modular arithmetic
                circFrame1 = fromCircFeatMats{i}(:,2:end);
                circFrame2 = toCircFeatMats{i+j}(:,2:end) + repmat(sum(circMs(i:i+j-1,:),1),size(toCircFeatMats{i+j},1),1);
                fullCirc1 = repmat(reshape(circFrame1,[size(circFrame1,1),1,size(circFrame1,2)]),[1,size(toLinFeatMats{i+j},1),1]);
                fullCirc2 = repmat(reshape(circFrame2,[1,size(circFrame2,1),size(circFrame2,2)]),[size(fromLinFeatMats{i},1),1,1]);
            else
                fullCirc1 = zeros(size(fullLin1,1),size(fullLin1,2),0);
                fullCirc2 = zeros(size(fullLin1,1),size(fullLin1,2),0);
            end           
            deltaF = cat(3,fullLin2-fullLin1,mod(fullCirc2-fullCirc1+0.5,1)-0.5);
            
            incRad = incRads(i); %Dynamically vary inclusion radius to keep density of target volume the same
            [covEig,covDiag] = eig(squeeze(covDfs(i,:,:)));
            adjCov = covEig*(covDiag^(-1/2))*covEig'; %Principal inverse square root (equivalent to covDfs^-1/2, but we need covEig for rotating back into the feature basis later so may as well write it out in full)
            
            %Calculate the distance matrix D twice. The first is quick and
            %dirty, using only the variances of the features to rescale the
            %feature vectors. This generates a candidate list over which we
            %can apply the more accurate transformed covariance matrix to.
            invSigs = diag(squeeze(covDfs(i,:,:))).^(-1/2); %List of standard deviations of marginal distributions
            roughResc = deltaF.*repmat(reshape(invSigs,[1,1,size(deltaF,3)]),[size(deltaF,1),size(deltaF,2),1]);
            roughD = sqrt(sum(roughResc.^2,3));
            
            %For each row, we want at least one entry to not be nan, even
            %if outside the distance threshold - if visualising the
            %normalised feature space, still want to see the rejected
            %cases.
            candMtx = roughD < 2*incRad; %Scaling factor of 2 here is arbitrary, depends on how strong you expect feature correlations to be (I'm assuming fairly weak here)
            for ci = 1:size(candMtx,1)
                if sum(candMtx(ci,:)) == 0
                    [~,minInd] = min(roughD(ci,:));
                    candMtx(ci,minInd) = true;
                end
            end
            
            %Go through the candMtx matrix candidate by candidate, multiplying 
            %candidate links by the transformed covariance matrix and
            %inserting the final score, while making everything else NaN
            D = nan(size(candMtx));
            candList = find(candMtx);
            [candR,candC] = ind2sub(size(candMtx),candList);
            for ci = 1:size(candR,1)
                deltaHatF = adjCov*squeeze(deltaF(candR(ci),candC(ci),:));
                candVal = norm(deltaHatF);
                D(candR(ci),candC(ci)) = candVal;
            end
            
            %This is a hack to make sure the following code terminates if D is empty
            if isempty(D)
                D = incRad*sqrt(j) + 1;
            end
            
            %Go through each row, assigning the single available link (or
            %none at all)
            delInds1 = [];
            delInds2 = [];
            
            startObjNo = size(D,1); %Used for the progress bar
            
            nanNosDim1 = sum(~isnan(D),1);
            
            for Ind1 = 1:size(D,1) %For each row of D
                rowOpts = ~isnan(D(Ind1,:));
                if sum(rowOpts) == 1 %Just one candidate for this row...
                    colNans = nanNosDim1(rowOpts);
                    if colNans == 1 %And just one candidate for this column, so legitimate candiate for accelerated assignment. 
                        Ind2 = find(rowOpts);
                        
                        frame1Loc = fromLinFeatMats{i}(Ind1,1);
                        frame2Loc = toLinFeatMats{i+j}(Ind2,1);
                                                
                        %The below will only activate if 'Test Track' has been
                        %pushed - so don't need to worry about dealing with
                        %frame-frame linking, which is only applicable to the
                        %whole dataset tracking step.
                        if returnSteps
                            singDHF = adjCov*squeeze(deltaF(Ind1,Ind2,:));
                            
                            if D(Ind1,Ind2) < incRad
                                acceptDiffs = [acceptDiffs,covEig'*singDHF];
                            else
                                rejectDiffs = [rejectDiffs,covEig'*singDHF];
                            end
                        end
                        
                        %Accept single available link if smaller than
                        %threshold
                        if D(Ind1,Ind2) < incRad
                            Tracks{i}(frame1Loc,1) = i + j;
                            Tracks{i}(frame1Loc,2) = frame2Loc;
                            Initials{i+j}(frame2Loc) = 0;
                            delInds1 = [delInds1;Ind1];
                            delInds2 = [delInds2;Ind2];
                        end
                    end
                end
            end
            
            %Eliminate from distance matrix and feature matrices
            D(delInds1,:) = [];
            D(:,delInds2) = [];
            
            fromLinFeatMats{i}(delInds1,:) = [];
            fromCircFeatMats{i}(delInds1,:) = [];
            toLinFeatMats{i+j}(delInds2,:) = [];
            toCircFeatMats{i+j}(delInds2,:) = [];
            
            cycleCount = 0;
            
            [minD,minInd] = min(D(:));
            
            while minD < incRad*sqrt(j) %Assume 'diffusive' motion within the isotropic Gaussian feature space (displacement proportional to sqrt time).
                %Find the minimum distance between frames at the moment
                [Ind1,Ind2] = ind2sub(size(D),minInd);
                frame1Loc = fromLinFeatMats{i}(Ind1,1);
                frame2Loc = toLinFeatMats{i+j}(Ind2,1);
                
                if returnSteps
                    singDHF = adjCov*squeeze(deltaF(frame1Loc,frame2Loc,:));
                    acceptDiffs = [acceptDiffs,covEig'*singDHF];
                end
                
                %Eliminate from distance matrix and feature matrices, and link cells.
                fromLinFeatMats{i}(Ind1,:) = [];
                fromCircFeatMats{i}(Ind1,:) = [];
                toLinFeatMats{i+j}(Ind2,:) = [];
                toCircFeatMats{i+j}(Ind2,:) = [];
                D(Ind1,:) = [];
                D(:,Ind2) = [];
                
                Tracks{i}(frame1Loc,1) = i + j;
                Tracks{i}(frame1Loc,2) = frame2Loc;
                Initials{i+j}(frame2Loc) = 0;
                
                cycleCount = cycleCount + 1;
                
                %This is another hack to make sure the code terminates if you've run out of cells to assign to or from.
                if isempty(D)
                    D = incRad*sqrt(j) + 1;
                end
                
                [minD,minInd] = min(D(:));
                
                progressbar(0.4+((j-1)/gapSize)*0.2,(i-1)/(length(fromLinFeatMats) - j),cycleCount/startObjNo)
            end
            
            %Do a last sweep through the distance matrix to get all the steps that didn't quite make the cut.
            if returnSteps
                while ~isempty(D)
                    if  D == incRad*sqrt(j) + 1
                        D = [];
                    else
                        %Find the minimum distance between frames at the moment
                        [~,minInd] = min(D(:));
                        [Ind1,Ind2] = ind2sub(size(D),minInd);
                        
                        frame1Loc = fromLinFeatMats{i}(Ind1,1);
                        frame2Loc = toLinFeatMats{i+j}(Ind2,1);
                        
                        singDHF = adjCov*squeeze(deltaF(frame1Loc,frame2Loc,:));
                        rejectDiffs = [rejectDiffs,covEig'*singDHF];
                        
                        %Eliminate from distance matrix and feature matrices, and link cells.
                        fromLinFeatMats{i}(Ind1,:) = [];
                        fromCircFeatMats{i}(Ind1,:) = [];
                        toLinFeatMats{i+j}(Ind2,:) = [];
                        toCircFeatMats{i+j}(Ind2,:) = [];
                        D(Ind1,:) = [];
                        D(:,Ind2) = [];
                        
                        cycleCount = cycleCount + 1;
                    end
                end
            end
        end
    end
end
